import sys

from pyspark.sql import SparkSession
from pyspark.sql import functions as F


def main() -> None:
    spark = SparkSession.builder.appName("AirportApp").getOrCreate()
    try:
        input_path = sys.argv[1]
        df = spark.read.csv(input_path, header=True)
        print("Original schema:")
        df.printSchema()

        df = (df.withColumn("airport_id", F.col("airport_id").cast("int"))).select(
            "airport_id", "city", "state", "name"
        )

        print("Transformed schema:")
        df.printSchema()

        print("Top 10 rows:")
        df.show(10)
    finally:
        spark.stop()


if __name__ == "__main__":
    main()
