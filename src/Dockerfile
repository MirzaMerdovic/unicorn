FROM mongo:latest

COPY ./run.sh /unicorn/run.sh

ADD VERSION .

WORKDIR /unicorn

CMD ["./run.sh"]