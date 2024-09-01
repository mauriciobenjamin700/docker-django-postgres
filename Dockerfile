FROM python:3.12-alpine
LABEL manteiner="mauriciobenjamin700@gmail.com"

# Essa variável de ambiente é usada para evitar que o Python escreva arquivos de byte code (.pyc) nos containers. 1 = Não escrever byte code, 0 = Escrever byte code.
ENV PYTHONDONTWRITEBYTECODE 1

# Essa variável de ambiente é usada para evitar que o Python armazene o histórico de comandos em um arquivo. Isso pode ser útil quando se cria imagens Docker para reduzir o tamanho da imagem.
ENV PYTHONUNBUFFERED 1

# Instala o curl e outras dependências necessárias
RUN apk add --no-cache curl

# Copia as pastas "app" e "scripts" para dentro do contêiner
COPY ./app /app
COPY ./scripts /scripts

# Entra na pasta "app" no contêiner
WORKDIR /app

# A porta 8000 do contêiner será exposta para permitir conexões externas ao contêiner
# 8000 é a porta padrão do servidor de desenvolvimento do Django
EXPOSE 8000

# Instala o Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
# Adiciona o executável do Poetry ao PATH
ENV PATH="/scripts:/root/.local/bin:$PATH"

# Verifica se o Poetry foi instalado corretamente
RUN poetry --version

# Copia os arquivos poetry.lock e pyproject.toml para o diretório de trabalho
COPY ./poetry.lock .
COPY ./pyproject.toml .

# Configuração do Poetry e instalação das dependências
RUN poetry config virtualenvs.create false && poetry install --no-interaction

# Cria o usuário duser
RUN adduser --disabled-password --no-create-home duser

# Ajusta as permissões dos diretórios
RUN mkdir -p /data/web/static /data/web/media && \
    chown -R duser:duser /data/web/static /data/web/media && \
    chmod -R 755 /data/web/static /data/web/media && \
    chown -R duser:duser /app /scripts && \
    chmod -R +x /scripts

# Atualizando o usuário para duser (novo usuário sem permissões importantes)
USER duser

# Executa o arquivo scripts/commands.sh
CMD ["sh", "/scripts/commands.sh"]