FROM python:3.11-slim

# Install system dependencies for:
# - Tesseract OCR (pytesseract)
# - poppler-utils (pdf2image)
# - ffmpeg (audio handling for Whisper)
# - fonts & basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    libtesseract-dev \
    poppler-utils \
    ffmpeg \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy requirements first for better Docker cache usage
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Streamlit & Python runtime settings
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Cloud Run will set PORT 
ENV PORT=8080

# Expose the port (for local runs; Cloud Run uses PORT env)
EXPOSE 8080

# IMPORTANT: make Streamlit listen on $PORT and 0.0.0.0
CMD ["sh", "-c", "streamlit run app/main.py --server.port=$PORT --server.address=0.0.0.0"]

