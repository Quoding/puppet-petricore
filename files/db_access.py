import pymysql.cursors

SLURM_DB_HOST_IP = "192.168.159.15"


def create_db_connection():
    connection = pymysql.connect(
        host=SLURM_DB_HOST_IP,
        port=3306,
        user="petricore",
        password="yourPassword",
        db="slurm_acct_db",
    )
    print("[+] DB connection is up! [+]")
    return connection
