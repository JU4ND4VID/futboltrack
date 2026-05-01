import mysql.connector
from config import Config

def get_mysql():
    return mysql.connector.connect(
        host=Config.MYSQL_HOST, port=Config.MYSQL_PORT,
        user=Config.MYSQL_USER, password=Config.MYSQL_PASSWORD,
        database=Config.MYSQL_DB, charset="utf8mb4"
    )
