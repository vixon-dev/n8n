# Usar a imagem oficial do n8n como base
FROM n8nio/n8n

# Altera para root para instalar as dependências
USER root

# Instalar FFMPEG, PHP, e Python
RUN apk add ffmpeg php python3 py3-pip

# Instalar YTDL
RUN npm install -g ytdl-core

# Permite usar ytdl-core e outras bibliotecas nos Function Nodes
ENV NODE_FUNCTION_ALLOW_EXTERNAL=ytdl-core,axios,lodash,moment,jimp,csv-parser,fs

# Define variáveis de ambiente necessárias
ENV NODE_PATH=/usr/local/lib/node_modules

# Volta para o user node
USER node

# Definir o diretório de trabalho
WORKDIR /data
