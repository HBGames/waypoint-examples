FROM node:12-alpine as build

# Create app directory
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install --omit=dev
# If you are building your code for production
# RUN npm ci --omit=dev
# Bundle app source
COPY . .

ARG PORT=3000
ENV PORT=$PORT

EXPOSE $PORT

CMD [ "/waypoint-entrypoint" "node", "index.js" ]