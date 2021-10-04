# MongoDB - PKI

Estes arquivos auxiliam a criação de CSRs ou mesmo de certificados autoassinados para utilizar nos servidores MongoDB em ReplicaSet.

## CSR

Para gerar os pedidos de assinatura é preciso criar um arquivo com seus valores separados por vírgula contendo o IP da máquina, o nome do host e o nome do replicaset:

**hosts.csv**

```csv
# ip,host,replicaset
172.27.11.10,db1.example.com,rs0
172.27.11.20,db2.example.com,rs0
172.27.11.30,db3.example.com,rs0
```

> # pode ser utilizado para comentários em linhas sozinhas

Com o arquivo pronto, basta executar o script de criação de CSR:

```bash
bash generate-csr.sh hosts.csv
```

Neste exemplo acima, o diretório terá 3 duplas de arquivos:

- db1.csr e db1.key
- db2.csr e db2.key
- db3.csr e db3.key

Basta enviar estes arquivos para a CA interna pedindo o certificado.

Para verificar se o arquivo gerado atende as exigências, basta utilizar o seguinte comando:

```bash
openssl req -in db1.csr -noout -text
```

## CRT

Para gerar certificados autoassinados, para propósitos de testes, basta executar o script `sign-certs.sh`:

```bash
bash sign-certs.sh hosts.csv
```

Ao criar/assinar os certificados o script já concatena o certificado junto a chave privada em um arquivo `.pem`.
