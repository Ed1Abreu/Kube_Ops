# Imagem base leve
FROM python:3.12-slim

# Variveis de ambiente para Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8000

WORKDIR /app

# Instalar dependncias do sistema
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copiar dependncias
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Copiar cdigo
COPY app ./app

# Expor porta
EXPOSE 8000

# Comando padro: gunicorn
CMD ["gunicorn", "-w", "2", "-b", ":8000", "app:app"]


