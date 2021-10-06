output "myvpc" {
  value = aws_vpc.myvpc.id
}
output "public-subnet1" {
  value = aws_subnet.my-pubsubnet1.id
}
output "private-subnet1" {
  value = aws_subnet.my-privsubnet1.id
}
output "private-subnet2" {
  value = aws_subnet.my-privsubnet2.id
}