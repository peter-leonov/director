FROM node:7.4.0

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

# This is the port where Director's nginx will connect to.
EXPOSE 8080
CMD ["npm", "start"]
