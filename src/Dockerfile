FROM mongo:latest

COPY entrypoint.sh .

ADD VERSION .

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]