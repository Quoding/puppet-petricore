#! /bin/bash
#Must be run as root.
newUser='petricore'
newDbPassword='yourPassword'
host=localhost
#host='%'
 
commands="CREATE USER '${newUser}'@'${host}' IDENTIFIED BY '${newDbPassword}';USE slurm_acct_db; CREATE VIEW user_job_map AS SELECT id_user, id_job, job_name FROM dwight_job_table; GRANT SELECT ON user_job_map TO '${newUser}' IDENTIFIED BY '${newDbPassword}';"

echo "${commands}" | /usr/bin/mysql
