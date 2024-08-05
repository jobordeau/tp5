FROM python:3.11.4

RUN pip install flask

COPY . /opt/

EXPOSE 8081

WORKDIR /opt

ENTRYPOINT ["python", "app.py"]
