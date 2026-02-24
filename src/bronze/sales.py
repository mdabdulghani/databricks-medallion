from pyspark.sql.functions import current_timestamp, col

def run(spark):
    df = spark.read.option("header","true") \
      .csv("s3://mybucket4564666/raw/sales/csv/")

    bronze = df \
      .withColumn("ingestion_ts", current_timestamp()) \
      .withColumn("source_file", col("_metadata.file_path"))

    bronze.write.format("delta") \
      .mode("overwrite") \
      .save("s3://mybucket4564666/bronze/sales")