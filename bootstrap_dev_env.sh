#!/usr/bin/env bash
set -euo pipefail

# 기본 정보 출력
echo "=== Ubuntu 개발 환경 부트스트랩 시작 ==="
lsb_release -a || true
echo

# 0. 기본 업데이트
echo "[1/6] apt 업데이트 및 업그레이드..."
sudo apt update
sudo apt -y upgrade

# 1. 공통 빌드/개발 도구
echo "[2/6] 공통 개발 도구 설치..."
sudo apt install -y \
  build-essential \
  git curl wget ca-certificates gnupg \
  cmake ninja-build meson pkg-config \
  gdb gdb-multiarch \
  strace ltrace \
  python3 python3-pip python3-venv \
  libssl-dev \
  zlib1g-dev \
  libelf-dev \
  libdw-dev \
  libbfd-dev \
  flex bison \
  tree htop \
  tmux \
  ripgrep \
  fd-find \
  zip unzip \
  jq

# fd 명령어 심볼릭 링크 (Ubuntu는 기본이 fdfind)
if [ -x /usr/bin/fdfind ] && [ ! -x /usr/local/bin/fd ]; then
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
fi

# 2. LLVM/Clang (Ubuntu 기본 + 최신 버전)
echo "[3/6] LLVM/Clang 설치..."

# Ubuntu 기본 clang/llvm (백업용)
sudo apt install -y clang lldb lld llvm-dev

# apt.llvm.org를 이용해 최신 LLVM 설치 (예: 18)
# 필요 버전에 따라 숫자만 바꾸면 됨.
LLVM_VER=21

echo "  - apt.llvm.org 스크립트 다운로드..."
wget https://apt.llvm.org/llvm.sh -O /tmp/llvm.sh
chmod +x /tmp/llvm.sh

echo "  - LLVM ${LLVM_VER} 설치..."
sudo /tmp/llvm.sh ${LLVM_VER}

# 기본 clang/clang++를 최신 버전으로 바인딩
echo "  - update-alternatives로 clang 기본 버전 설정..."
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VER} 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VER} 100
sudo update-alternatives --set clang /usr/bin/clang-${LLVM_VER}
sudo update-alternatives --set clang++ /usr/bin/clang++-${LLVM_VER}

# 3. ARM/QEMU 개발 환경
echo "[4/6] ARM / QEMU 개발 환경 설치..."

sudo apt install -y \
  qemu-system \
  qemu-system-arm \
  qemu-user \
  qemu-user-static \
  binfmt-support \
  gcc-arm-none-eabi \
  gdb-multiarch \
  binutils-arm-none-eabi \
  gcc-aarch64-linux-gnu \
  gcc-arm-linux-gnueabihf \
  g++-aarch64-linux-gnu \
  g++-arm-linux-gnueabihf \
  device-tree-compiler

# 4. 성능/프로파일링 도구 (perf, bpftrace 등)
echo "[5/6] 성능 / 프로파일링 도구 설치..."

sudo apt install -y \
  linux-tools-common \
  linux-tools-generic \
  linux-tools-$(uname -r) \
  bpfcc-tools \
  bpftrace

# 5. 편의 도구 (git 설정용 템플릿, locale 등은 별도 설정)
echo "[6/6] 기타 편의 도구 설치..."

sudo apt install -y \
  net-tools \
  dnsutils \
  ncdu

echo
echo "=== 개발 환경 설치 완료 ==="
echo "clang 버전:"
clang --version || true
echo
echo "/workspace, /archive 디렉토리 상태:"
ls -ld /workspace /archive 2>/dev/null || echo "(/workspace, /archive는 나중에 생성/마운트 필요)"


