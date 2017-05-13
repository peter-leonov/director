FROM node:7.4.0

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE 8080
CMD ["npm", "start"]
