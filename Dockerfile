# Version: 1.111.0 (l)
FROM n8nio/n8n:1.111.0

###############################
# 1. Permissões root
###############################
USER root

###############################
# 2. Dependências do sistema
###############################
RUN apk update && apk add --no-cache \
    ffmpeg \
    php \
    python3 \
    py3-pip \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    wqy-zenhei \
    font-noto \
    font-noto-cjk \
    git \
    nano \
    bash \
    libc6-compat \
    sqlite \
 && ln -sf /usr/bin/chromium /usr/bin/chromium-browser

###############################
# 3. Python / yt-dlp
###############################
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install -U "yt-dlp[default]"

###############################
# 4. Variáveis de versão
###############################
ARG PUPPETEER_VERSION=22.15.0
ARG LIGHTHOUSE_VERSION=12.1.0
ARG AXIOS_VERSION=1.7.7
ARG ICONV_VERSION=0.6.3
ARG JSDOM_VERSION=22.1.0
ARG PLURALIZE_VERSION=8.0.0
ARG TOUGH_COOKIE_VERSION=4.1.4
ARG IMAP_VERSION=0.8.19
ARG MAILPARSER_VERSION=3.7.1
ARG COOKIE_AGENT_VERSION=5.0.3

###############################
# 5. Instalação libs Node.js
###############################
RUN npm install \
    puppeteer@${PUPPETEER_VERSION} \
    lighthouse@${LIGHTHOUSE_VERSION} \
    axios@${AXIOS_VERSION} \
    iconv-lite@${ICONV_VERSION} \
    jsdom@${JSDOM_VERSION} \
    pluralize@${PLURALIZE_VERSION} \
    axios-cookiejar-support@6.0.4 \
    tough-cookie@${TOUGH_COOKIE_VERSION} \
    imap@${IMAP_VERSION} \
    mailparser@${MAILPARSER_VERSION} \
    http-cookie-agent@${COOKIE_AGENT_VERSION} \
    --prefix /data --legacy-peer-deps

RUN npm install -g \
    puppeteer@${PUPPETEER_VERSION} \
    lighthouse@${LIGHTHOUSE_VERSION} \
    axios@${AXIOS_VERSION} \
    iconv-lite@${ICONV_VERSION} \
    jsdom@${JSDOM_VERSION} \
    pluralize@${PLURALIZE_VERSION} \
    axios-cookiejar-support@6.0.4 \
    tough-cookie@${TOUGH_COOKIE_VERSION} \
    imap@${IMAP_VERSION} \
    mailparser@${MAILPARSER_VERSION} \
    http-cookie-agent@${COOKIE_AGENT_VERSION} \
    --legacy-peer-deps

###############################
# 6. Extras multimídia
###############################
RUN npm install -g ytdl-core@latest youtube-transcript-api

###############################
# 7. Segurança + Config
###############################
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

###############################
# 8. Volta para usuário padrão
###############################
USER node
WORKDIR /data

###############################
# 9. Entrypoint
###############################
CMD ["n8n"]
