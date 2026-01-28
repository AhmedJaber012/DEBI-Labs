from pyspark.sql import SparkSession

def main():

    # 1️⃣ Create Spark Session
    spark = SparkSession.builder \
        .appName("Spark SQL Financial Project") \
        .enableHiveSupport() \
        .getOrCreate()

    spark.sparkContext.setLogLevel("ERROR")
    print("🚀 Spark SQL Started")

    # 2️⃣ Read CSV File
    df = spark.read \
        .option("header", "true") \
        .option("inferSchema", "true") \
        .csv("transactions.csv")

    print("📄 Source Data")
    df.show()

    # 3️⃣ Create Temp View
    df.createOrReplaceTempView("transactions")

    # 4️⃣ Total Sales
    print("💰 Total Sales")
    spark.sql("""
        SELECT SUM(amount) AS total_sales
        FROM transactions
    """).show()

    # 5️⃣ Average Transaction Value
    print("📊 Average Transaction Value")
    spark.sql("""
        SELECT AVG(amount) AS avg_transaction
        FROM transactions
    """).show()

    # 6️⃣ Top 5 Customers
    print("🏆 Top 5 Customers")
    spark.sql("""
        SELECT
            customer_id,
            SUM(amount) AS total_spent
        FROM transactions
        GROUP BY customer_id
        ORDER BY total_spent DESC
        LIMIT 5
    """).show()

    # 7️⃣ Daily Sales
    print("📆 Daily Sales")
    spark.sql("""
        SELECT
            transaction_date,
            SUM(amount) AS daily_sales
        FROM transactions
        GROUP BY transaction_date
        ORDER BY transaction_date
    """).show()

    # 8️⃣ Sales By City
    print("🏙️ Sales By City")
    spark.sql("""
        SELECT
            city,
            SUM(amount) AS total_sales
        FROM transactions
        GROUP BY city
        ORDER BY total_sales DESC
    """).show()

    # 9️⃣ Suspicious Transactions
    print("🚨 Suspicious Transactions (amount > 5000)")
    spark.sql("""
        SELECT *
        FROM transactions
        WHERE amount > 5000
    """).show()

    # 🔟 Save Results
    spark.sql("""
        SELECT *
        FROM transactions
    """).write.mode("overwrite").parquet("output/transactions_parquet")

    spark.sql("""
        SELECT
            transaction_date,
            SUM(amount) AS daily_sales
        FROM transactions
        GROUP BY transaction_date
    """).write.mode("overwrite").csv(
        "output/daily_sales", header=True
    )

    print("✅ Data Saved Successfully")

    # 🔚 Stop Spark
    spark.stop()
    print("🛑 Spark Session Stopped")


if __name__ == "__main__":
    main()
