import argparse
from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType

parser = argparse.ArgumentParser(description='Spark Job Arguments')
parser.add_argument("--num-range")
parser.add_argument("--output-file")
args = parser.parse_args()

num_range = int(parser.num_range)
output_file = parser.output_file

spark = SparkSession.builder.appName("sample").getOrCreate()

df = spark.createDataFrame([_ for _ in range(num_range)], IntegerType()).toDF("num")

df.write.save(output_file)
spark.stop()