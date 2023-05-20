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

ARG WAYPOINT_VERSION=0.11.1

RUN wget -O /tmp/waypoint-entrypoint.zip https://releases.hashicorp.com/waypoint-entrypoint/0.11.1/waypoint-entrypoint_0.11.1_linux_arm64.zip
RUN unzip /tmp/waypoint-entrypoint.zip -d /
RUN rm /tmp/waypoint-entrypoint.zip

ARG PORT=3000
ENV PORT=$PORT

EXPOSE $PORT

ENTRYPOINT [ "/waypoint-entrypoint", "node", "index.js" ]