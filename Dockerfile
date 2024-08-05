FROM python:3.9-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libexpat1 \
    libgssapi-krb5-2 \
    libk5crypto3 \
    libkrb5-3 \
    libkrb5support0 \
    libsqlite3-0 \
    perl-base \
    zlib1g

COPY requirements.txt /tmp/

RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    pip install --upgrade pip && \
    pip install --upgrade Werkzeug==3.0.3 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /opt/

WORKDIR /opt

EXPOSE 8081

ENTRYPOINT ["python", "app.py"]
