
import argparse
import os
import subprocess
import sys
from pathlib import Path
from typing import Any

import yaml


PROJECT_ROOT = Path(__file__).resolve().parents[2]


def load_config(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as file:
        config = yaml.safe_load(file)

    if not isinstance(config, dict):
        raise ValueError("YAML configuration must be a mapping")

    return config


def build_command(
    config: dict[str, Any],
    job_name: str,
    job_args: list[str],
) -> list[str]:
    spark = config["spark"]
    runtime = config["runtime"]
    jobs = config["jobs"]

    if job_name not in jobs:
        available = ", ".join(sorted(jobs))
        raise ValueError(
            f"Unknown job '{job_name}'. Available: {available}"
        )

    job = jobs[job_name]
    mode = runtime["mode"]

    if mode not in ("local", "docker"):
        raise ValueError(f"Unsupported runtime mode: {mode}")

    script = Path(job["script"])

    if script.is_absolute() or ".." in script.parts:
        raise ValueError("Job script must be relative to apps/")

    # Prevent executing arbitrary paths from job configuration.
    if script.suffix != ".py":
        raise ValueError("Job script must be a Python file")

    apps_dir = runtime["apps_dir"]
    application_path = str(Path(apps_dir) / script)

    if mode == "local":
        local_app = (PROJECT_ROOT / application_path).resolve()
        if not local_app.is_relative_to(
            (PROJECT_ROOT / "apps").resolve()
        ):
            raise ValueError("Job script must remain inside apps/")
        if not local_app.is_file():
            raise FileNotFoundError(local_app)

    spark_submit = (
        runtime.get("spark_submit", "/opt/spark/bin/spark-submit")
        if mode == "docker"
        else "spark-submit"
    )

    command = [
        spark_submit,
        "--master",
        str(spark["master"]),
        "--deploy-mode",
        str(spark.get("deploy_mode", "client")),
    ]

    for key, value in spark.get("properties", {}).items():
        command.extend(["--conf", f"{key}={value}"])

    command.append(application_path)
    command.extend(str(arg) for arg in job.get("args", []))
    command.extend(job_args)

    if mode == "docker":
        command = [
            "docker",
            "compose",
            "exec",
            "-T",
            runtime.get("service", "spark-client"),
            *command,
        ]

    return command


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run a configured PySpark job"
    )

    parser.add_argument(
        "job",
        help="Job name defined in the YAML configuration",
    )

    parser.add_argument(
        "--config",
        required=True,
        type=Path,
        help="Path to Spark YAML configuration",
    )

    parser.add_argument(
        "job_args",
        nargs="*",
        help="Additional arguments passed to the job",
    )

    args = parser.parse_args()

    config_path = (
        args.config
        if args.config.is_absolute()
        else PROJECT_ROOT / args.config
    )

    config = load_config(config_path)
    command = build_command(config, args.job, args.job_args)

    print("Running Spark job:", args.job)
    print("Configuration:", config_path)
    print("Command:", " ".join(command), flush=True)

    env = os.environ.copy()

    if config["runtime"]["mode"] == "local":
        python_path = PROJECT_ROOT / ".venv/bin/python"
        if not python_path.is_file():
            raise FileNotFoundError(
                "uv virtual environment not found. Run uv sync."
            )
        env["PYSPARK_PYTHON"] = str(python_path)
        env["PYSPARK_DRIVER_PYTHON"] = str(python_path)

    result = subprocess.run(
        command,
        cwd=PROJECT_ROOT,
        env=env,
        check=False,
    )

    sys.exit(result.returncode)


if __name__ == "__main__":
    main()

