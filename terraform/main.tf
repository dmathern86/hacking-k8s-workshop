
resource "aws_instance" "victims" {
  depends_on = [
    aws_route_table_association.workshop_route_table_association
  ]
  count         = var.instance_count
  ami           = var.ubuntu
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.workshop_sg_allowall.id]
  subnet_id                   = aws_subnet.workshop_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name  = "victim${count.index + 1}"
  }
}
resource "aws_instance" "attacker" {
  depends_on = [
    aws_route_table_association.workshop_route_table_association
  ]
  count         = var.instance_count
  ami           = var.sles
  instance_type = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.workshop_sg_allowall.id]
  subnet_id                   = aws_subnet.workshop_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name    = "attacker${count.index + 1}"
  }
}

# needs to be replaces with your public ssh key.
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGi+Nwt9smHxKy5MM1Yh1SSLdZHTdVSKoZs0cAyaLMhp6APN0PjP4JcRTJmkDhdepUzmfYjQXzSuJNprNorrqhFz4cY3kBbkbe666hsKrkAu4Duuth69jgWmiLgjgxZz4n+xVMMK3z+YgjGyEqFXCtKJrrgwzCYa7QQRrvSRbfAvjL0xVYpybZeD3enWdJ2zGWGZFp7Mf73lQh/zYI26rKvDTw0E6BFNp+gu4fVsC3Y7xS4FEORoBI5Jl4DT+9+ZlylIwK4B8tTF6rJl7Xyk3l2elh8skAF1Zlnq3lfqUnWvY6nCg27yGkkFsNwKUdOJ/SyWTeZ1ZTyCwFhpaD96NB/CGxXOhfc+AprpzQjFi/EjmgyzU/XAxt0c7QbDCjXUFAUNu4+1UZz4QMVcGW1uiZnjIa5VEUq1iQdE8EJoT028zWekRLapYnZ5BsL33jRGENt5zl9p57Dsa2ahoPlxnNpzqBI3J4wcu1b2g5wymIhuAFQlwqUFf5wlE7cDaQWPZLx6uSBLaKpWSQ4F2XL+2PIlizmXQfr7fYfogRBVv8ZOfGhG9xfbjbrjllK+vUO9YR4J2PZVdX4wSnEKHCa7OLGX6EAJkS/veNrcc4vdrXLqb5H11msXcu4wZLw1ZbkpZdJqIFxci97Wc5cWg3YRNUqyx9Ki8mlwjUk29v9RFJDw== sshkey"
}

output "workshop_victims_public_ips" {
  value = "${aws_instance.victims.*.public_ip}"
  description = "Public IP addresses of the victims VMs"
}

output "workshop_attacker_public_ips" {
  value = "${aws_instance.attacker.*.public_ip}"
  description = "Public IP addresses of the attacker VMs"
}