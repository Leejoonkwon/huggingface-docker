FROM nvidia/cuda:11.8.0-devel-ubuntu20.04

ENV TZ=Asia/Seoul
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common tzdata &&\
    add-apt-repository ppa:deadsnakes/ppa &&\
    apt-get update -y \
    && apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
    liblzma-dev python-openssl git vim less python3-venv unzip &&\
    apt install locales && locale-gen en_US.UTF-8 && dpkg-reconfigure locales


ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv

ENV POETRY_HOME=/opt/poetry \
    POETRY_VENV=/opt/poetry-venv \
    POETRY_CACHE_DIR=/opt/.cache

ENV PATH $PYENV_ROOT/bin:$PATH
ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# PYENV
ARG PYTHON_VERSION="3.10.4"

RUN curl https://pyenv.run | bash &&\
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc &&\
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc &&\
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc &&\
    pyenv install $PYTHON_VERSION &&\
    pyenv global $PYTHON_VERSION

ENV PATH="${PATH}:$(poetry env info --path)/bin/python"


RUN $(pyenv which python3.10) -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools \
    && $POETRY_VENV/bin/pip install poetry

ENV POETRY_VIRTUALENVS_IN_PROJECT=true \
    PATH="${PATH}:${POETRY_VENV}/bin"

RUN pyenv global system
WORKDIR /app
COPY . ./

RUN pyenv local $PYTHON_VERSION &&\
    poetry lock --no-update &&\
    poetry install --no-root
