#!/usr/bin/env python

import random
import os
import mysql.connector             
from mysql.connector import Error
from faker import Faker

# Create DB connection
print("Starting script")

db_instance = mysql.connector.connect(
  host=os.environ["DB_HOST"],
  port=int(os.environ["DB_PORT"]),
  user=os.environ["DB_USERNAME"],
  password=os.environ["DB_PASSWORD"],
  connect_timeout=int(os.environ["DB_CONNECT_TIMEOUT"]),
  database=os.environ["DB_SCHEMA"]
)

db_cursor_instance = db_instance.cursor()

# Generate data
data_generator_instance = Faker()
customer_values = [ data_generator_instance.name(), 
                    data_generator_instance.ascii_email(), 
                    data_generator_instance.address(), 
                    data_generator_instance.color_name(),
                    data_generator_instance.job() ]

# Insert record
query = "INSERT INTO customers (customer_name, customer_email_address, customer_address, customer_favorite_color, customer_occupation) VALUES (%s, %s, %s, %s, %s)"
query_values = (customer_values[0], customer_values[1], customer_values[2], customer_values[3], customer_values[4])

db_cursor_instance.execute(query, query_values)

db_instance.commit()

print( "Inserted data into customer table: " + ",".join(str(s) for s in customer_values) )