# Bem vindos ao Desafio01 Beanstalk

Neste desafio minha tarefa é colocar a BIA para rodar no Elastic Beanstalk fazendo comunicação com o RDS.
Abaixo terá as etapas com alguns prints para facilitar o entedimento.

Primeiramente o que é o Elastic Beanstalk?
O **Elastic Beanstalk** é um serviço da AWS que facilita o gerenciamento e o deploy de aplicações na nuvem. Ele permite que você faça o upload do código da sua aplicação e, automaticamente, cuida do provisionamento da infraestrutura necessária (como servidores, redes, balanceamento de carga, escalabilidade e monitoramento).

Resumidamente, ele automatiza o processo de configuração e manutenção de infraestrutura, permitindo que você se concentre mais no desenvolvimento da aplicação em vez de se preocupar com a infraestrutura subjacente.

Repositorio da BIA
https://github.com/henrylle/bia-eb



## Step1 - Criar o Ambiente (Environment)

Vamos ao painel principal do console da AWS e pesquisar por Elastic Beanstalk
![image](https://github.com/user-attachments/assets/86aed7aa-a1ed-440d-afd9-0d61409773fe)

![image](https://github.com/user-attachments/assets/45796780-0c97-4254-9873-ffc03b7d871f)


Vamos configurar o que é necessário.

- Selecionar o Tier
  - Web server environment ou Worker environment
- Application Information
  - Application name
- Environment information
  - Environment name
- Domain 
  > O proprio beanstalk cria um dns para vc
Platform
- Platform type
  > Vamos escolher o Docker e sua versão mais nova


Na proxima tela, vai aparecer essa abaixo.

<img width="804" alt="image" src="https://github.com/user-attachments/assets/a57fe5a6-52ca-4418-b3ce-7789652587ae">

Neste ponto vamos precisar, criar um nova Role. Para isso vamos em IAM(abra uma nova aba), role, create role

![image](https://github.com/user-attachments/assets/1a660c67-d502-49e2-af4c-90937dd679fe)

Eu criei a role com nome de role-instance-profile-beanstalk para facilitar no uso.
Vamos em Permissions policies -> Add permissions --> Attach policies

E adicionar a policie AWSElasticBeanstalkWebTier.

Podemos salvar e voltar na tela do beanstalk.
<img width="1440" alt="image" src="https://github.com/user-attachments/assets/45bde419-b2f0-459d-aa15-1bd86dcef892">

Na proxima tela é bem simples, vamos atachar uma VPC e uma zona, não esqueça de marcar o box para adicionar um IP Publico.

Aqui temos alguns pontos importantes, a partir de 01/10/24 a AWS não está mais dando suporte ao Lauch Configuration, vamos precisar fazer pelo Launch Configuration.
Aqui 
Precisamos se atentar a 3 configurações na tela de Configure instance traffic and scaling

Em Instances
Root Volume é GP3 (General Purpose 3)
<img width="1431" alt="image" src="https://github.com/user-attachments/assets/89992710-5691-42f4-970b-f8b1077ed125">
Instance metada service (IMDS)
desativado.
<img width="1431" alt="image" src="https://github.com/user-attachments/assets/09362b9e-7288-48a6-9097-134e51279878">
Em Auto Scaling Group 
Selecione Spot
<img width="1440" alt="image" src="https://github.com/user-attachments/assets/53a28d58-9e84-497a-90b2-2e82e577d37f">

Por fim, pode avançar as duas próximas telas, que nosso Ambiente estará configurado.



Com isso vamos ver nosso ambiente ok, marcado pelo green em Health e com um código de exemplo.
Enviroment com health green
![image](https://github.com/user-attachments/assets/90df9ea2-6b88-4afe-8dcb-c0b1dc43508a)
Código de exemplo, basta clicar no dns criando pelo beanstalk
![image](https://github.com/user-attachments/assets/a9a011cc-100f-447f-817e-39e9c339f10f)

## Step2 - Criar o Aplicação

Nesse step vamos criar a aplicação para fazer o uso do environment.
![image](https://github.com/user-attachments/assets/68d5d19d-edc0-4d6a-92ac-be7f5334f8db)

Aqui é bem simples, vamos adicionar o nome da aplicação e uma descrição(opcional)
<img width="1439" alt="image" src="https://github.com/user-attachments/assets/b94f0703-5a54-4962-99ac-9e8984bd0b82">


## Step3 - Deploy do nosso codigo

O Beanstalk necessita que você envie o codigo via console em um arquivo zipado, vá na pasta raíz da aplicação crie e um zip, faça o upload do zip e clique em deploy.
Clica no ambiente, e depois em Upload and Deploy, caso queria fazer o deploy imeadiato da aplicação
<img width="1432" alt="image" src="https://github.com/user-attachments/assets/b1aaeee0-bd19-4d4a-8e7b-9c28825262c6">

Basta adicionar o arquivo do codigo zipado como mencionado acima.
Pos o deploy podemos verificar nossa aplicação no ar
![image](https://github.com/user-attachments/assets/a08311f9-4b84-454c-8467-46575f3d30e5)

Em Application versions podemos ver as versões que já subimos anteriormente. 

Fiz uma edição, pq mudei a arquitetura que estava trabalhando, (Sai de um arm para x86 intel)
![image](https://github.com/user-attachments/assets/b7c60666-ed3b-46b5-bdc4-9330b5707303)


Agora vamos fazer a BIA persistir os dados 

Vamos criar um banco no RDS e conectar a nossa instancia

![image](https://github.com/user-attachments/assets/7ccece65-81fc-45a2-a889-1ba4f28d02e6)

Em RDS vamos em create database
![image](https://github.com/user-attachments/assets/9fb4a16c-2a75-48fd-8779-0d1fbc2a775a)

Escolher as opções
- Stardart create
- PostgreSQL
- Version 16.3-R2
- Freetier
- Single DB Instance
- Escolher usuario (usei postgres mesmo)
Em connectivity vamos associar a nossa EC2
Restante pode deixar padrão, e criar database

Com o nosso db criado
![image](https://github.com/user-attachments/assets/dd6c7cf5-2646-47c3-9d2c-da8bb940e6f4)


Vamos voltar ao nosso ec2, parar criar o db e rodar a migrate.

Acesse a ec2,(SSM, SSH ou CloudShell mesmo)
![image](https://github.com/user-attachments/assets/007b07ad-3af5-409b-b9b0-4e40981b284d)
Vamos rodar os comandos
~~~
docker ps
docker exec -it <CONTAINER ID> /bin/bash
~~~
Acessando o container vamos criar o banco e rodar a migrate

~~~
npx sequelize db:create 
npx sequelize db:migrate
~~~
PS. O meu deu erro pq já tinha feito.

![image](https://github.com/user-attachments/assets/72cabdd8-867a-40e2-9443-e529b41725ac)


Agora nossa BIA vai persistir os dados

![image](https://github.com/user-attachments/assets/62147a74-01e4-4b98-ac97-605bfa8d9ea6)


![image](https://github.com/user-attachments/assets/126ea730-86b9-4c1e-bf24-ac20db818068)


