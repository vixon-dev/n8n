# Usar a imagem oficial do n8n como base
FROM n8nio/n8n

# Instalar Python
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install --upgrade pip \
    npm install -g ytdl-core

# Instalar PHP
RUN apt-get install -y php-cli

# Instalar FFmpeg
RUN apt-get install -y ffmpeg

# Limpar o cache do apt para reduzir o tamanho da imagem
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Definir o diretório de trabalho
WORKDIR /data

# Executar o n8n na inicialização do container
CMD ["n8n", "start"]
