#!/bin/bash

# 시스템 패키지 업데이트
sudo apt-get update -y

# 간단한 HTTP 서버 실행용 패키지 설치 (Python3 기본 제공 가정)
sudo apt-get install -y python3

# HTML 파일 생성
echo "<h1>Welcome to Cafeboo Backend</h1>" | sudo tee /var/www/index.html

# HTTP 서버 실행 (포트 80)
nohup python3 -m http.server 80 --directory /var/www > /dev/null 2>&1 &