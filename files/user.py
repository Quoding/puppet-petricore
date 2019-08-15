import subprocess
import json
from pwd import getpwuid
from socket import gethostname

LOCALHOST = gethostname()
LOCALHOST = LOCALHOST.split(".")[0]


class User:
    def __init__(self, uid):
        # Declare and initalize
        self.__uid = uid
        self.__username = getpwuid(uid).pw_name
        self.__storage_info = {}
        self.__storage_info["user"] = self.__username
        self.__storage_info["uid"] = uid

        # Retrieve the actual storage info
        # self.retrieve_storage_info()

    def get_storage_info(self):
        """Get the self.__storage_info attribute"""
        return self.__storage_info

    def retrieve_storage_info(self):
        """Function that retrieves storage data for the user, queries lfs quota on the cluster 
        (Except Graham, see retrieve_storage_info_graham()"""
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


if __name__ == "__main__":
    a = User(3083770)
    string = """                             Description                Space           # of files
    Home (user alarouch)              17k/53G              21/500k
 Scratch (user alarouch)             4000/20T              1/1000k
/project (group alarouch)              0/2048k               0/500k
/project (group def-alarouch)            16k/1000G               6/500k
/project (group def-jfaure)           361G/1000G             90k/500k
/nearline (group def-alarouch)            16k/1000G               6/500k
/nearline (group def-jfaure)           361G/1000G             90k/500k
"""
    # a.get_storage_info()
