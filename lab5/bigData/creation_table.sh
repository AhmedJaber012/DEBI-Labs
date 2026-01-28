create database test ;

USE test;

CREATE TABLE employees (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  department VARCHAR(100),
  salary DECIMAL(10, 2)
);

INSERT INTO employees_exported2 (name, department, salary) VALUES
(' Salammox', 'Big DATA', 10000.00);



GRANT ALL PRIVILEGES ON test.* TO 'hive'@'%' IDENTIFIED BY 'hive_pass';

CREATE TABLE employees_exported2 (
     id INT ,
  name VARCHAR(100),
  department VARCHAR(100),
  salary DECIMAL(10, 2)
);

sqoop export \
  --connect jdbc:mysql://172.18.0.2:3306/test \
  --username root \
  --password password \
  --table employees_exported2 \
  --export-dir /employees_test_successxbb \
  --input-fields-terminated-by ',' \
  -m 1

  sqoop export \
  --connect jdbc:mysql://172.18.0.2:3306/test \
  --username root \
  --password password \
  --table default.employees_exported2 \
  --export-dir /user/hive/warehouse/employees \
  --input-fields-terminated-by ',' \
  -m 1


  sqoop export \
  --connect jdbc:mysql://172.18.0.2:3306/test \
  --username root \
  --password password \
  --table employees \
  --export-dir /user/hive/warehouse/employees_exported2 \
  --input-fields-terminated-by '\001' \
  -m 1