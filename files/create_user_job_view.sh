#! /bin/bash
#Must be run as root.
newUser='petricore'
newDbPassword='yourPassword'

domain="$(< webapp_config)"
 
IFS='=' # = is set as delimiter
read -ra ADDR <<< "$str" # str is read into an array as tokens separated by IFS
host="mgmt01.int."${ADDR[1]} #Host is equal to the mgmt01 node on the domain name we just retrieved

commands="CREATE USER '${newUser}'@'${host}' IDENTIFIED BY '${newDbPassword}';USE slurm_acct_db; CREATE VIEW user_job_view AS SELECT id_user, id_job, job_name FROM dwight_job_table; GRANT SELECT ON user_job_view TO '${newUser}'@'${host}' IDENTIFIED BY '${newDbPassword}';"

echo "${commands}" | /usr/bin/mysql
