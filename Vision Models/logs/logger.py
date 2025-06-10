from datetime import datetime
import os

class App_logger:

    def __init__(self):
        pass

    def log(self, file_path, log_message):
        """
        Log a message to the specified file path
        This method handles opening and closing the file for each log operation
        
        """

        try:
            self.now = datetime.now()
            self.date = self.now.date()
            self.current_time = self.now.strftime("%H:%M:%S")

            os.makedirs(os.path.dirname(file_path),exist_ok=True)

            with open(file_path,'a+') as file_object:
                file_object.write(
                    str(self.date) + "/" + str(self.current_time) + "\t\t" + log_message + "\n"
                    
                )

        except Exception as e:
            print(f"ERROR: Logging to {file_path} failed: {str(e)}")
            print(f"Original message: {self.date}/{self.current_time}\t\t{log_message}")
