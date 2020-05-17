FROM node:8-alpine
ARG port
EXPOSE $port
COPY db.js .
ENTRYPOINT ["node", "db.js"]
CMD []
