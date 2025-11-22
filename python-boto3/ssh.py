import paramiko

ssh = paramiko.SSHClient()
ssh.connect('139.162.130.236', 22, 'root') 