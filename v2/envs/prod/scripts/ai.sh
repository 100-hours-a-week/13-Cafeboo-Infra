#!/bin/bash

set -e  # 오류 발생 시 즉시 종료
log_file="/tmp/setup_fastapi.log"
exec > >(tee -a "$log_file") 2>&1

echo "🔧 [1] apt update 및 python 환경 설치"
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

echo "📦 [2] 가상환경 생성"
python3 -m venv /home/$USER/venv

echo "🐍 [3] 패키지 설치"
source /home/$USER/venv/bin/activate
pip install --upgrade pip
pip install fastapi uvicorn

echo "📁 [4] FastAPI 앱 생성"
mkdir -p /home/$USER/ai_app

cat <<EOF > /home/$USER/ai_app/main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/ai/test")
def test():
    return {"message": "AI is working"}
EOF

echo "🚀 [5] Uvicorn 백그라운드 실행 (포트 8000)"
cd /home/$USER/ai_app
nohup /home/$USER/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 > /tmp/uvicorn.log 2>&1 &