# ------------------------------------------------------------------------------
# EFS
# ------------------------------------------------------------------------------
resource "aws_efs_file_system" "minecraft_server" {
  performance_mode = "generalPurpose"
  tags = {
    Name = var.application_name
  }
}

resource "aws_efs_mount_target" "minecraft_server" {
  count           = length(module.vpc.public_subnets)
  file_system_id  = aws_efs_file_system.minecraft_server.id
  subnet_id       = module.vpc.public_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "minecraft_server" {
  file_system_id = aws_efs_file_system.minecraft_server.id
  posix_user {
    uid = 999
    gid = 999
  }
  root_directory {
    path = "/minecraft"
    creation_info {
      owner_uid = 999
      owner_gid = 999
      permissions = 740
    }
  }
}
