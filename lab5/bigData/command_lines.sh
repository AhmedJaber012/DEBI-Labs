

docker exec -it mysql mysql -u root -p

docker exec -it sqoop bash 
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';

# export HADOOP_CLASSPATH=/usr/share/java/mysql-connector-java.jar
# وبعدين شغّل:

sqoop import \
  --connect jdbc:mysql://mysql:3306/test \
  --username root \
  --password hive_pass \
  --table employees \
  --database test \
  --target-dir /user/hive/employees \
  --m 1


sqoop import \
  -Dmapreduce.jobtracker.address=resourcemanager:8032 \
  -Dyarn.resourcemanager.address=resourcemanager:8032 \
  --driver com.mysql.jdbc.Driver \
  --connect jdbc:mysql://mysql:3306/test \
  --username root \
  --password password \
  --table employees \
  --hive-import \
  --hive-database test \
  --hive-table employees \
  --m 1




--sed -i 's/cluster-master/namenode/g' /usr/local/hive/conf/core-site.xml

---grep -r cluster-master /usr/local/hive/conf/
sqoop eval \
  --connect jdbc:mysql://mysql:3306/test \
  --username root \
  --password password \
  --driver com.mysql.jdbc.Driver \
  --query "SELECT * from employees"

hdfs dfs -ls /
sed -i 's/cluster-master/namenode/g' /usr/local/hadoop/etc/hadoop/yarn-site.xml
hadoop fs -fs hdfs://namenode:8020 -ls /
grep -r cluster-master /usr/local/hadoop/etc/
cat > core-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:9000</value>
  </property>
</configuration>
EOF

cat > hdfs-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>

  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///hadoop/dfs/name</value>
  </property>

  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///hadoop/dfs/data</value>
  </property>
</configuration>
EOF

cat > yarn-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>

  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>namenode</value>
  </property>

  <property>
    <name>yarn.resourcemanager.address</name>
    <value>namenode:8032</value>
  </property>

  <property>
    <name>yarn.resourcemanager.scheduler.address</name>
    <value>namenode:8030</value>
  </property>
</configuration>
EOF








#
#
#  mv mysql-connector-java.jar /usr/local/sqoop/lib/
#
#  mv mysql-connector-java.jar /usr/local/hive/lib/


GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';

# to run sqoop import

# 1. Set the classpath to include the current directory

export HADOOP_CLASSPATH=/usr/share/java/mysql-connector-java.jar
# 2. Run the import again (using a specific class name we know exists)
rm -f employees_manual*.java employees_manual*.class employees_manual*.jar

sqoop codegen \
  --connect jdbc:mysql://mysql:3306/test \
  --username root \
  --password password \
  --table employees \
  --outdir /dataops \
  --bindir /dataops \
  --class-name employees_manualuu
#>>>>  export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:.
sqoop import \
  -Dmapreduce.framework.name=local \
  --connect jdbc:mysql://mysql:3306/metastore_db \
  --username root \
  --password password \
  --table employees \
  --target-dir /employees_test_successxbb \
  --delete-target-dir \
  --bindir . \
  -m 1

  sqoop eval \
  --connect jdbc:mysql://mysql:3306/test \
  --username root \
  --password password \
  --driver com.mysql.jdbc.Driver \
  --query "SELECT * from employees"

schematool -dbType mysql -initSchema
# to run hive
-- امسح الجدول القديم عشان نصلح المسار
DROP TABLE employees_final;

-- اعمل الجدول تاني بالمسار اللي الـ HDFS قالهولنا
CREATE EXTERNAL TABLE employees_final (
    id INT,
    name STRING,
    dept STRING,
    salary DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/employees_test_successxbb';


#hdfs dfs -cat /employees_test_successxbb/part-m-00000 
vi /etc/hosts
172.18.0.2  namenode cluster-master mysql
172.18.0.3  mysql

for i in {2..10}; do (timeout 1 bash -c "cat < /dev/null > /dev/tcp/172.18.0.$i/3306") && echo "MySQL is at 172.18.0.$i" && break; done