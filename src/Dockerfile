FROM mongo:latest

COPY ./entrypoint.sh /unicorn/entrypoint.sh

ADD VERSION .

WORKDIR /unicorn

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]