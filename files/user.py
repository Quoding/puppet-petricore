import subprocess
import json
from pwd import getpwuid
from socket import gethostname
import db_access
import pymysql

LOCALHOST = gethostname()
LOCALHOST = LOCALHOST.split(".")[0]

# Create the database connection
CONNECTION = db_access.create_db_connection()


class User:
    def __init__(self, uid):
        # Declare and initalize
        self.__uid = uid
        self.__username = getpwuid(uid).pw_name
        self.__storage_info = {}
        self.__storage_info["user"] = self.__username
        self.__storage_info["uid"] = uid
        self.__jobs = []

        # Retrieve the actual storage info
        # self.retrieve_storage_info()
        self.retrieve_job_map(self.__uid)

    def get_storage_info(self):
        """Get the self.__storage_info attribute"""
        return self.__storage_info

    def retrieve_storage_info(self):
        """Function that retrieves storage data for the user, queries lfs quota on the cluster 
        (Except Graham, see retrieve_storage_info_graham())"""
        self.__storage_info["storage"] = []
        # Get /home and /scratch partition since they're based off of users.
        partitions = ("/home", "/scratch")

        for partition in partitions:

            output = subprocess.check_output(
                ["/usr/bin/lfs", "quota", "-u", self.__username, partition]
            ).decode("ascii")

            titles = output.split("\n")[1].split()
            data = output.split("\n")[2].split()
            json_dict = {}

            # Here, 8 covers all the fields we need to expose in the json
            for i in range(8):
                try:
                    actual_data = int(data[i])
                except:
                    actual_data = data[i]
                    pass

                if titles[i] == "quota":
                    titles[i] = "available_" + titles[i - 1]

                if titles[i] == "limit":
                    continue
                if data[i] != "-":
                    json_dict[titles[i].lower()] = actual_data

            self.__storage_info["storage"].append(json_dict)
        print(json.dumps(self.__storage_info))

    def retrieve_storage_info_graham(self):
        # TODO
        self.__storage_info = []
        output = subprocess.check_output(
            "/cvmfs/soft.computecanada.ca/custom/bin/diskusage_report"
        ).decode("ascii")

    def retrieve_job_map(self, id_user):
        sql_parameterized_query = (
            """SELECT id_job FROM user_job_view WHERE id_user = %s"""
        )

        with CONNECTION.cursor() as cursor:
            cursor.execute(sql_parameterized_query, (id_user,))
            result = cursor.fetchall()
            self.__jobs = list(
                [element[0] for element in result]
            )  # Convert the tuple of single element tuples to a list of elements
        return self.__jobs


if __name__ == "__main__":
    a = User(50001)

    # a.get_storage_info()
