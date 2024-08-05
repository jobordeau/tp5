FROM python:3.6

COPY requirements.txt /tmp/

RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY . /opt/

WORKDIR /opt

EXPOSE 8081

ENTRYPOINT ["python", "app.py"]
