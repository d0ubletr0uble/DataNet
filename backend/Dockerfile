FROM python:3.6-slim

WORKDIR APP

COPY requirements.txt .
RUN python3.6 -m pip install -r requirements.txt

COPY . .
EXPOSE 8080

CMD ["python3.6", "main.py"]
