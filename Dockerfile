FROM --platform=amd64 ubuntu

ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y wget curl vim iputils-ping
RUN wget https://downloads.robocorp.com/rcc/releases/v13.7.1/linux64/rcc && wget https://downloads.robocorp.com/rcc/releases/v13.7.1/linux64/rccremote
RUN chmod +x rcc rccremote && mv rcc rccremote /usr/bin

# shared HT are required
RUN /usr/bin/rcc ht shared -e && /usr/bin/rcc ht init

CMD ["tail", "-f", "/dev/null"]
