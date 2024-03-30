# pull official base image
FROM python:3.12.0

# set working directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONBREAKPOINT pudb.set_trace

# install system dependencies
# RUN apt-get update \
#   && apt-get -y install gcc postgresql \
#   && apt-get clean

# Base apt dependencies
RUN <<EOF
set -e
apt-get update
apt-get install -y netcat-traditional gcc

# Install postgresql-client-16
apt-get install -y lsb-release wget
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt update
apt-get install -y postgresql-client-16
rm -rf /var/lib/apt/lists/*

EOF

# install poetry and dependencies
RUN pip install --upgrade pip poetry
COPY ./pyproject.toml ./poetry.lock* /usr/src/app/
RUN poetry config virtualenvs.create false && poetry install --no-interaction

# # add and install requirements
# COPY ./requirements.txt .
# RUN pip install -r requirements.txt

# add app
COPY . .

# add entrypoint.sh
COPY ./entrypoint.sh .
RUN chmod +x /usr/src/app/entrypoint.sh
