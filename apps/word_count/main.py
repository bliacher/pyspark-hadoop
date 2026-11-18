
import sys

from pyspark.sql import SparkSession
from pyspark.sql import functions as F


def main() -> None:
    spark = (
        SparkSession.builder
        .appName("WordCount")
        .getOrCreate()
    )

    try:
        input_path = sys.argv[1]

        df = spark.read.text(input_path)

        words = (
            df.select(
                F.explode(
                    F.split(F.lower(F.col("value")), r"\s+")
                ).alias("word")
            )
            .select(
                F.regexp_replace(
                    F.col("word"), r"[^a-z]", ""
                ).alias("word")
            )
            .filter(F.col("word") != "")
        )

        counts = (
            words.groupBy("word")
            .count()
            .orderBy(F.desc("count"), F.asc("word"))
        )

        counts.show(10, truncate=False)

    finally:
        spark.stop()


if __name__ == "__main__":
    main()

