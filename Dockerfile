FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y python-dev curl && \
    curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python && \
    apt-get install -y pkg-config && \
    apt-get remove -y python-pycparser

COPY src /src

WORKDIR /src

RUN pip install -r requirements.txt -r test_requirements.txt

COPY README.md /src