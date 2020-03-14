FROM madnight/docker-alpine-wkhtmltopdf as wkhtmltopdf_image

FROM openfaas/classic-watchdog:0.18.1 as watchdog

FROM node:12.13.0-alpine as ship

RUN apk update freetype freetype-dev ttf-freefont

COPY --from=wkhtmltopdf_image /bin/wkhtmltopdf /usr/bin/
RUN chmod +x /usr/bin/wkhtmltopdf

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

RUN addgroup -S app && adduser app -S -G app

WORKDIR /root/

# Turn down the verbosity to default level.
ENV NPM_CONFIG_LOGLEVEL warn

RUN mkdir -p /home/app

# Wrapper/boot-strapper
WORKDIR /home/app
COPY package.json ./

# This ordering means the npm installation is cached for the outer function handler.
RUN npm i --production

# Copy outer function handler
COPY . .

# chmod for tmp is for a buildkit issue (@alexellis)
RUN chmod +rx -R ./function \
    && chown app:app -R /home/app \
    && chmod 777 /tmp

USER app

ENV cgi_headers="true"
ENV fprocess="node index.js"
EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
