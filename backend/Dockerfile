FROM python:3.6-slim

WORKDIR backend
ENV PYTHONPATH /

RUN apt-get update && apt-get install -y python3-opencv

COPY requirements.txt .
RUN python3.6 -m pip install -r requirements.txt

COPY . .
EXPOSE 8080

CMD ["python3.6", "main.py"]
