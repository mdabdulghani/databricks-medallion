from delta.tables import DeltaTable
from pyspark.sql.functions import col, to_date

def run(spark):

    source = spark.read.format("delta") \
        .load("s3://mybucket4564666/bronze/sales")

    silver_path = "s3://mybucket4564666/silver/sales"

    clean = source \
        .drop("ingestion_ts","source_file") \
        .withColumn("amount", col("amount").cast("double")) \
        .withColumn("sale_date", to_date(col("sale_date"))) \
        .filter(col("amount") > 0) \
        .dropDuplicates(["sale_id"])

    if DeltaTable.isDeltaTable(spark, silver_path):
        target = DeltaTable.forPath(spark, silver_path)

        target.alias("t").merge(
            clean.alias("s"),
            "t.sale_id = s.sale_id"
        ).whenMatchedUpdateAll() \
         .whenNotMatchedInsertAll() \
         .execute()

    else:
        clean.write.format("delta").save(silver_path)