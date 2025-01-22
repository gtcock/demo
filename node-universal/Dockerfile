FROM node:slim

WORKDIR /app

COPY . .

RUN mkdir -p temp && chmod 777 temp

RUN apt-get update -y \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/* \
    && npm install

RUN chmod +x index.js

EXPOSE 3000

CMD ["node", "index.js"]