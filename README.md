# Script de Backup do MongoDB para Google Cloud Storage

Um script de shell para automatizar o backup de bancos de dados MongoDB, enviando os arquivos diretamente para um bucket no Google Cloud Storage (GCS).

## Funcionalidades

- Backup e Compressão: Utiliza mongodump com as flags **--archive** e **--gzip** para criar um único arquivo de backup compactado.

- Envia o arquivo de backup diretamente para o bucket do Google Cloud Storage através da **GoogleCLI**.

- Utiliza **mktemp** para criar um diretório de trabalho temporário com nome aleatório.

- Limpeza Automática com **trap** para garantir que o diretório temporário seja removido ao final da execução, independentemente da saída.

-----
## Pré-requisitos

  - bash: O script é escrito para o shell bash.

  - MongoDB Database Tools: É necessário ter o comando mongodump. Geralmente, ele é instalado através do pacote mongodb-database-tools ou ao instalar o Mongo diretamente.

  - [Google Cloud CLI](https://cloud.google.com/sdk/docs/install): A ferramenta gcloud é usada para fazer o upload do backup para o GCS.
  Após a instalação, você precisa autenticar e configurar o projeto:
  
```Bash
  gcloud auth login
  gcloud config set project SEU_ID_DE_PROJETO`
```

-----
## Como Usar

1. Download do Script

Clone este repositório ou baixe o arquivo backup_mongodb.sh.

```Bash
git clone https://github.com/NevaresLeo/backup_mongodb.git
cd backup_mongodb
```

2. Dar Permissão de Execução

Torne o script executável:

```Bash
chmod +x backup_mongodb.sh
```

3. Configuração

Abra o arquivo backup_mongo_gcs.sh em um editor de texto e ajuste as variáveis do banco e credencias.

> [!NOTE]
> _Recomendado utilizar variáveis de ambiente ao invés de escrevê-las diretamente no arquivo_

4. Execução

```Bash
./backup_mongodb.sh
```

5. Automação com Cron

Para automatizar a execução do backup, utilize o crontab.

```Bash
crontab -e
# Executa o backup do MongoDB todos os dias às 03:00
0 3 * * * /caminho/completo/para/backup_mongodb.sh > /var/log/mongo_backup.log 2>&1

```
## Variáveis de Configuração

**MONGO_DATABASE**	 - O nome do banco de dados que você deseja fazer backup.

**MONGO_HOST**	     - O host onde o MongoDB está rodando (localhost).

**MONGO_PORT**	     - A porta padrão do MongoDB (27017).

**MONGO_USER**	     - O usuário para autenticação.

**MONGO_PASSWORD**	 - A senha para o usuário de autenticação.

**MONGO_AUTH_DB**	   - O banco de dados de autenticação do usuário.

**GCS_BUCKET_PATH**  -  O caminho completo no GCS para onde os backups serão enviados. (gs://seu-bucket/)
