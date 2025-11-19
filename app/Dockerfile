FROM node:18-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

COPY . .

# Requirement #3: wizexercise.txt with your name
RUN echo "Minoo Duraipandy" > wizexercise.txt

ENV NODE_ENV=production

EXPOSE 3000

CMD ["node", "app.js"]
