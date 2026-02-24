from pyspark.sql.functions import sum

def run(spark):

    silver = spark.read.format("delta") \
        .load("s3://mybucket4564666/silver/sales")

    gold = silver.groupBy("sale_date") \
        .agg(sum("amount").alias("daily_revenue"))

    gold.write.format("delta") \
        .mode("overwrite") \
        .save("s3://mybucket4564666/gold/daily_revenue")