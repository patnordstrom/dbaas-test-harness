FROM python:3.12-slim

ENV DB_USERNAME "akmadmin"
ENV DB_PASSWORD "placeholder"
ENV DB_HOST "placeholder.akamaidb.net"
ENV DB_PORT "27108"
ENV DB_CONNECT_TIMEOUT "5"
ENV DB_SCHEMA "testproject"

WORKDIR /test-artifacts

COPY requirements.txt .

RUN pip3 install -r requirements.txt

CMD [ "tail", "-f", "/dev/null" ]