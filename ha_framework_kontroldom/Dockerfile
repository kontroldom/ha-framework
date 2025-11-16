ARG BUILD_FROM=ghcr.io/home-assistant/amd64-addon-base:15.0.6
FROM $BUILD_FROM

ENV LANG C.UTF-8

# dodajemy run.sh i szkielet frameworku
COPY run.sh /usr/local/bin/run.sh
COPY framework /opt/framework

RUN chmod +x /usr/local/bin/run.sh

CMD [ "/usr/local/bin/run.sh" ]