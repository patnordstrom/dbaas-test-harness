#!/usr/bin/env python

import mysql.connector
import os

# Creata DB connection
db_instance = mysql.connector.connect(
  host=os.environ["DB_HOST"],
  port=int(os.environ["DB_PORT"]),
  user=os.environ["DB_USERNAME"],
  password=os.environ["DB_PASSWORD"],
  connect_timeout=int(os.environ["DB_CONNECT_TIMEOUT"])
)

db_schema = os.environ["DB_SCHEMA"]
db_cursor_instance = db_instance.cursor()

# Create the database
db_cursor_instance.execute( "CREATE DATABASE IF NOT EXISTS " + db_schema + ";")
db_instance.database = db_schema
print( "DB created successfully" )


# Create the table
db_cursor_instance.execute( "CREATE TABLE IF NOT EXISTS customers \
                           (  id INT AUTO_INCREMENT PRIMARY KEY, \
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, \
                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, \
                              customer_name VARCHAR(255), \
                              customer_email_address VARCHAR(255), \
                              customer_address VARCHAR(255), \
                              customer_favorite_color VARCHAR(255), \
                              customer_occupation VARCHAR(255) );" )

print( "customers table created successfully" )

