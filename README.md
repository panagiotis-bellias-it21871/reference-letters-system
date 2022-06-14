# reference-letters-system
A web system about reference letter handling in the context of DIT HUA Thesis "Use of devops methodologies and tools in development and production environment of web applications"

## Jenkins commands
```bash
sudo apt-get install default-jre
java --version # must have either version 8 or 11
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
sudo systemctl status jenkins
netstat -anlp | grep 8080
```

http://<PUBLIC-IP>:8080/

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
and copy the password and paste it in the field.
Select **Install Suggested Plugins** and when the process is finished register as a new admin user providing credentials you want. Clink on the buttons to get started with Jenkins CI/CD Tool.

We have a job for this main repository.