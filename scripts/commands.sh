#!/bin/sh

# O Shell irá encerrar a execução do script se algum comando falhar
set -e

while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  echo "Aguardando o banco de dados estar disponível..($POSTGRES_HOST:$POSTGRES_PORT)" &
  sleep 1
done

echo "Banco de dados disponível! Iniciando a aplicação..($POSTGRES_HOST:$POSTGRES_PORT)"

python manage.py collectstatic
python manage.py migrate
python manage.py runserver