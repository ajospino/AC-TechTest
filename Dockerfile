FROM ubuntu:20.04

RUN apt-get update && apt-get -y install wget gpg 
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
  && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
  && sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' \
  && rm -f packages.microsoft.gpg

#RUN apt install apt-transport-https && \
       # apt update && \
        # apt install code

RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
        && dpkg -i packages-microsoft-prod.deb \
        && rm packages-microsoft-prod.deb
RUN apt-get update && \
        apt-get install -y dotnet-sdk-7.0


RUN apt-get install -y openjdk-17-jre-headless

RUN apt update && apt -y install maven \
        apache2 \
        postgresql \
        postgresql-contrib \
        git

COPY index.html /var/www/html/index.html

ENTRYPOINT [ "/usr/sbin/apache2ctl" ]
CMD [ "-D", "FOREGROUND"]