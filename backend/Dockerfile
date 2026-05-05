FROM python:3.9-slim
WORKDIR /app
RUN pip install --no-cache-dir flask pymysql authlib requests python-dotenv
COPY . .
EXPOSE 5001
CMD ["python", "app.py"]
