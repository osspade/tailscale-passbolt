FROM passbolt/passbolt:latest-ce
WORKDIR /root
RUN mkdir -p /run/openrc/
RUN touch /run/openrc/softlevel
RUN curl https://tailscale.com/install.sh > install_tailscale.sh
RUN chmod 0777 /root/install_tailscale.sh 
RUN echo "Ensure the tailscale env TSKEY is set: $TSKEY"
RUN /root/install_tailscale.sh 

RUN echo $'#!/bin/sh \n\
tailscaled > /tmp/tailscaled.log & \n\
sleep 3 \n\
tailscale up --auth-key=$TSKEY > /tmp/tailscaleup.log & \n\
/usr/bin/wait-for.sh -t 0 $DATASOURCES_DEFAULT_HOST:3306 -- /docker-entrypoint.sh \n\
' > /root/passbolt-tailscale.sh
RUN chmod 0777 /root/passbolt-tailscale.sh 
ENTRYPOINT ["/root/passbolt-tailscale.sh"]

