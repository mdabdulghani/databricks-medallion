from bronze.sales import run as bronze
from silver.sales import run as silver
from gold.revenue import run as gold

bronze(spark)
silver(spark)
gold(spark)s