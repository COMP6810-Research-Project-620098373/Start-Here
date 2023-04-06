FROM node:18.15-alpine3.17 as base

WORKDIR /app
COPY ./Marketplace ./Marketplace
COPY ./Marketplace-Backend ./Marketplace-Backend


FROM base as dev
WORKDIR /app/Marketplace
RUN npm install --silent
RUN npm run build
WORKDIR /app
RUN rm -rf ./Marketplace-Backend/www
RUN cp -R ./Marketplace/www ./Marketplace-Backend
WORKDIR /app/Marketplace-Backend
RUN npm install --silent
RUN npm run build
CMD ["npm", "start"]


FROM base as prod
# TODO: Configure production build