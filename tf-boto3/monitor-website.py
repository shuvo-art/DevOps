import requests
import smtplib
import os
import paramiko
from linode_api4 import LinodeClient, Instance
import time
import schedule

EMAIL_ADDRESS = os.environ.get("EMAIL_ADDRESS")
EMAIL_PASSWORD = os.environ.get("EMAIL_PASSWORD")
LINODE_TOKEN = os.environ.get("LINODE_TOKEN")

def restart_server_and_container():
    # restart the server
    client = LinodeClient('LINODE_TOKEN')
    nginx_server = client.load('Instance', 24810590) # Provide Created Linode Instance Id
    nginx_server.reboot()

    # restart the application
    while True:
        nginx_server = client.load('Instance', 24810590)
        if nginx_server.state == 'running':
            time.sleep(5)
            restart_container()
            break

def send_notification(email_msg):
    with smtplib.SMTP("smtp.gmail.com", 587) as smtp:
            smtp.connect()
            smtp.ehlo()
            smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            message = f"Application Down. {email_msg}"
            smtp.sendmail(EMAIL_ADDRESS, EMAIL_ADDRESS, message)

def restart_container():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname='139.162.130.236', username='root', key_filename='/Users/shuvo83qn/.ssh/id_rsa')
    stdin, stdout, stderr = ssh.exec_command('docker start 12c5878a1341')
    print(stdout.readline())
    ssh.close()
    print('Application restarted....')

def monitor_application():
    try:
        response = requests.get('http://li1299-236.members.linode.com:8080/')
        if response.status_code == 200:
            print("Application is Up!")
        else:
            print("Application is Down!")
            # send notification mail to me
            msg = f"Subject: SITE DOWN!\n Status code: {response.status_code}. Fix the issue. Restart the application."
            send_notification(msg)

            # restart the application
            restart_container()
    except Exception as ex:
        print(f"Connection Error Happend! {ex}")
        msg = f"Application not accessible at all!"
        send_notification(msg)
        restart_server_and_container()


schedule.every(5).minute.do(monitor_application)

while True:
    schedule.run_pending()
    
