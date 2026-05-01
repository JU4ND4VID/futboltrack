import os
from dotenv import load_dotenv
load_dotenv()

class Config:
    MYSQL_HOST     = os.getenv("MYSQL_HOST",     "127.0.0.1")
    MYSQL_PORT     = int(os.getenv("MYSQL_PORT", 3306))
    MYSQL_USER     = os.getenv("MYSQL_USER",     "root")
    MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "root")
    MYSQL_DB       = os.getenv("MYSQL_DB",       "mydb")
    MONGO_URI = os.getenv("MONGO_URI", "mongodb://127.0.0.1:27017")
    MONGO_DB  = os.getenv("MONGO_DB",  "futboltrack")
    FLASK_PORT  = int(os.getenv("FLASK_PORT", 5000))
    FLASK_DEBUG = os.getenv("FLASK_DEBUG", "True") == "True"
