output "db_username" {
  value = linode_database_mysql_v2.mysql_db_test.root_username
  sensitive = true
}

output "db_password" {
  value = linode_database_mysql_v2.mysql_db_test.root_password
  sensitive = true
}

output "db_host" {
  value = linode_database_mysql_v2.mysql_db_test.host_primary
}

output "db_port" {
  # workaround for current known issue so we default to known good port number
  value = linode_database_mysql_v2.mysql_db_test.port == 0 ? 27108 : linode_database_mysql_v2.mysql_db_test.port
}