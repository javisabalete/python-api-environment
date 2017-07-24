FROM tiangolo/uwsgi-nginx-flask:flask

RUN apt-get update \
	&& apt-get install -y openssh-server git sudo

#sshd config for supervisor
RUN echo " \n\
[program:sshd] \n\
command=/usr/sbin/sshd -D -f /etc/ssh/sshd_config \n\
stdout_logfile=/dev/stdout \n\
stdout_logfile_maxbytes=0 \n\
stderr_logfile=/dev/stderr \n\
stderr_logfile_maxbytes=0 \n\
" >> /etc/supervisor/conf.d/supervisord.conf

#Python things :)
RUN echo "py-autoreload = 1" >> /etc/uwsgi/uwsgi.ini
RUN echo "pidfile = /var/run/uwsgi.pid" >> /etc/uwsgi/uwsgi.ini

#SSH
RUN sed -i -r 's/.?UseDNS\syes/UseDNS no/' /etc/ssh/sshd_config \
	&& sed -i -r 's/.?PasswordAuthentication.+/PasswordAuthentication yes/' /etc/ssh/sshd_config \
	&& sed -i -r 's/.?ChallengeResponseAuthentication.+/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config \
	&& sed -i -r 's/.?PermitRootLogin.+/PermitRootLogin no/' /etc/ssh/sshd_config
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

#Fix Debian-Ubuntu issue https://bugs.launchpad.net/ubuntu/+source/openssh/+bug/45234
RUN mkdir /var/run/sshd

#Set user
ENV USER api

#Create and configure user with ansible public key
RUN useradd -ms /bin/bash $USER
ADD ansible.pub /tmp
RUN mkdir -p /home/$USER/.ssh
RUN cat /tmp/ansible.pub >> /home/$USER/.ssh/authorized_keys
RUN chown -R $USER:$USER /home/$USER
RUN rm /tmp/ansible.pub

#Git perms and key
ADD git /
RUN chmod 400 /git
RUN chown $USER:$USER /git
RUN mkdir /root/.ssh
RUN echo " \n\
Host            python-api \n\
    Hostname        github.com \n\
    IdentityFile    /git \n\
    IdentitiesOnly yes \n\
" >> /root/.ssh/config

RUN cp /root/.ssh/config /home/$USER/.ssh/config
RUN chown -R $USER:$USER /home/$USER/.ssh

#Set root password in order to allow became_user
RUN echo "root:root" | chpasswd

#Install python-redis
RUN pip install redis

#Remove default main.py
RUN rm -rf /app

#Init script
ADD init-api /usr/local/bin
RUN chmod +x /usr/local/bin/init-api
CMD ["/usr/local/bin/init-api"]
