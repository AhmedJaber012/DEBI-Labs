#!/bin/bash

# ==========================================
# STEP 1: CONFIGURATION & SETUP
# ==========================================
echo "##########################################################################--- [1/6] Setting up Environment Variables and Links ---"
export HADOOP_CLASSPATH=/usr/share/java/mysql-connector-java.jar # Set Hadoop classpath to include MySQL driver

export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:. # Link the MySQL driver to Hive (ignoring "File exists" error)
ln -sf /usr/share/java/mysql-connector-java.jar /usr/local/hive/lib/mysql-connector-java.jar # Link the MySQL driver to Hive (ignoring "File exists" error)

# Fix /etc/hosts so Hive can find 'mysql' and 'cluster-master'
# We use 'grep' to ensure we don't add the line twice
if ! grep -q "cluster-master" /etc/hosts; then
    echo "172.18.0.3 cluster-master" >> /etc/hosts
fi
if ! grep -q "mysql" /etc/hosts; then
    echo "172.18.0.2 mysql" >> /etc/hosts
fi

# ==========================================
# STEP 2: INITIALIZE HIVE METASTORE
# ==========================================
echo "##########################################################################--- [2/6] Initializing Hive Metastore ---"
# We add "|| true" so the script continues even if schema already exists
schematool -dbType mysql -initSchema || true

# ==========================================
# STEP 3: PREPARE DATA (Create CSV file)
# ==========================================
echo "##########################################################################--- [3/6] Generating Data File (employees.txt) ---"
cat > employees.txt << EOF # Sample Employee Data
1,John_Doe,IT,6000.0
2,Jane_Smith,HR,5500.0
3,Michael_Brown,Finance,7000.0
4,Emily_Davis,IT,6200.0
5,William_Wilson,Marketing,5800.0
EOF

# ==========================================
# STEP 4: HIVE OPERATIONS
# ==========================================
echo "##########################################################################--- [4/6] Running Hive Queries ---"
hive -e "
set hive.exec.mode.local.auto=true;
set hive.vectorized.execution.enabled=true;
set hive.vectorized.execution.reduce.enabled=true;
DROP TABLE IF EXISTS employees;

CREATE EXTERNAL TABLE employees (
    id INT,
    name STRING,
    dept STRING,
    salary DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/hive/warehouse/employees';

LOAD DATA LOCAL INPATH 'employees.txt' INTO TABLE employees;
"

# ==========================================
# STEP 5: CLEAN MYSQL DESTINATION
# ==========================================
echo "##########################################################################--- [5/6] Cleaning MySQL Destination Table ---"
# We use mysql client to TRUNCATE the table so Sqoop doesn't get 'Duplicate Entry' errors
mysql -h 172.18.0.2 -u root -ppassword -e "USE test; TRUNCATE TABLE employees;"

# ==========================================
# STEP 6: SQOOP EXPORT
# ==========================================
echo "##########################################################################--- [6/6] Running Sqoop Export ---"
sqoop export \
  -Dmapreduce.framework.name=local \
  --connect jdbc:mysql://172.18.0.2:3306/test \
  --username root \
  --password password \
  --table employees \
  --export-dir /user/hive/warehouse/employees \
  --input-fields-terminated-by ',' \
  --input-null-string '\\N' \
  --input-null-non-string '\\N' \
  --bindir . \
  -m 1

echo "--- PIPELINE FINISHED SUCCESSFULLY ---"