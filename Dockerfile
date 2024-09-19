FROM --platform=amd64 ubuntu

ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y wget curl iputils-ping
# OS dependencies for playwright
RUN apt-get install -y libxcb-shm0\
    libx11-xcb1\
    libx11-6\
    libxcb1\
    libxext6\
    libxrandr2\
    libxcomposite1\
    libxcursor1\
    libxdamage1\
    libxfixes3\
    libxi6\
    libgtk-3-0\
    libpangocairo-1.0-0\
    libpango-1.0-0\
    libatk1.0-0\
    libcairo-gobject2\
    libcairo2\
    libgdk-pixbuf-2.0-0\
    libglib2.0-0\
    #liboss4-salsa-asound2\
    libasound2t64\
    libxrender1\
    libfreetype6\
    libfontconfig1\
    libdbus-1-3\
    libnss3\
    libnspr4\
    libdrm2\
    libgbm1

RUN wget https://downloads.robocorp.com/rcc/releases/v13.7.1/linux64/rcc && wget https://downloads.robocorp.com/rcc/releases/v13.7.1/linux64/rccremote
RUN chmod +x rcc rccremote && mv rcc rccremote /usr/bin


CMD ["tail", "-f", "/dev/null"]
