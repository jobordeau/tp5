FROM python:3.9-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libexpat1=2.5.0-2 \
    libgssapi-krb5-2=1.20.1-2+deb12u2 \
    libk5crypto3=1.20.1-2+deb12u2 \
    libkrb5-3=1.20.1-2+deb12u2 \
    libkrb5support0=1.20.1-2+deb12u2 \
    libsqlite3-0=3.40.1-2 \
    perl-base=5.36.0-7+deb12u1 \
    zlib1g=1:1.2.13.dfsg-1

COPY requirements.txt /tmp/

RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    pip install --upgrade pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /opt/

WORKDIR /opt

EXPOSE 8081

ENTRYPOINT ["python", "app.py"]
