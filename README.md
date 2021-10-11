<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4" />

#vlyulin Infra repository

#Content:
* [Student](#Student)
* [Module hw03-bastion](#Module-hw03-bastion)
* [Module hw04-cloud-testapp](#Module-hw04-cloud-testapp)
* [Module hw05-packer](#Module-hw05-packer)
* [Module hw06-terraform-1](#Module-hw06-terraform-1)
* [Module hw07-terraform-2](#Module-hw07-terraform-2)

# Student
`
Student: Vadim Lyulin
Course: DevOps
Group: Otus-DevOps-2021-08
`

## Module hw03-bastion "Запуск VM в Yandex Cloud,  управление правилами фаервола, настройка SSH подключения, настройка SSH подключения через Bastion Host, настройка VPN сервера и VPN-подключения" <a name="Module-hw03-bastion"></a>
> Цель:
> В данном дз студент создаст виртуальные машины в YC. Настроит bastion host и ssh.
> В данном задании тренируются навыки: создания виртуальных машин, настройки bastion host, ssh
> Все действия описаны в методическом указании.

### Самостоятельное задание
Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства,
проверить работоспособность найденного решения и внести его в README.md в вашем репозитории.

#### Решение
Использовать ключ -J (ssh jump host) для перепрыгивания через hosts.
Команда:
```
ssh -i ~/.ssh/vlyulin_key -J appuser@130.193.38.153 appuser@10.128.0.30
```

### Дополнительное задание:
Предложить вариант решения для подключения из консоли при помощикоманды вида ssh someinternalhost из локальной консоли рабочегоустройства,
чтобы подключение выполнялось по алиасуsomeinternalhost и внести его в README.md в вашем репозитории.

#### Решение
Настроить Static jumphost list.
Для этого сощдается файл ~/.ssh/config, где указываются переходы
```
### Первый переход к host, который доступен напрямую.
Host bastion
  User appuser
  HostName 130.193.38.153

### Host для последующего перехода
Host someinternalhost
  User appuser
  HostName 10.128.0.30
  ProxyJump bastion
```

Выполнить команду:
```
ssh -i ~/.ssh/vlyulin_key someinternalhost
```
### Дополнительное задание
С помощью сервисов / и реализуйте
использование валидного сертификата для панели управления VPN-сервера

#### Решение

![](images/LetsEncript.png)

https://130.193.37.127.sslip.io

## Описание конфигурации
bastion_IP = 130.193.37.12
someinternalhost_IP = 10.128.0.30

## Module hw04-cloud-testapp "Практика управления ресурсами yandex cloud через YC" <a name="Module-hw04-cloud-testapp"></a>
> Цель:
> В данном дз произведет ручной деплой тестового приложения. Напишет bash скрипт для автоматизации задач настройки VM и деплоя приложения.
> В данном задании тренируются навыки: деплоя приложения на сервер, написания bash скриптов.
> Ручной деплой тестового приложения. Написание bash скриптов для автоматизации задач настройки VM и деплоя приложения.
> Все действия описаны в методическом указании.

Деплой тестового приложения reddit

1) Установлен YC CLI
2) Создана ВМ
2) Созданы скрипты для установки:
        - Ruby и Bundler (install_ruby.sh),
        - MongoDB (install_mongo.sh),
        - Reddit (deploy.sh)
3) Скриптам install_ruby.sh, install_mongo.sh, deploy.sh установлен флаг исполнения +x
4) Проверена работа приложения http://62.84.116.223:9292
5) Предпринята попытка выполнения дополнительного задания

testapp_IP=62.84.116.223
testapp_port=9292

Создание ключей:
```
ssh-keygen -t rsa -b 2048 -f ~/.ssh/appuser -C appuser -P ""
```

Команда создания ВМ (файл yc-create-instance.sh):
```
#!/bin/bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/appuser.pub
```

Соединение с rabbit-app:
ssh -i ~/.ssh/appuser yc-user@62.84.116.223

Дополнительное задание:
`
В качестве доп. задания используйте созданные ранее скрипты длясоздания,
который будет запускаться при создании инстанса.В результате применения данной команды CLI
мы должны получать инстанс с уже запущенным приложением. Startup скрипт
необходимо закомитить, а используемую команду CLI добавить в описание репозитория(README.md)
`

Конфигурационный файл (cloud-config.yml):
```
#cloud-config

users:
  - name: appuser
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL:ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjk1hL2RJ/cLvzmBZ4dsRGKmceEh+x5VxMPY09/wG/yiv7j2gm+flQQ4bRZfQwmEPsVW8OflQPBfyVsttXoilG0Q5xO2hT1Kgjr/RMGW6LghXOZFSTFLEZ+OAXgf89W3RyYIMgsJti7qNTHJSqsq1CrxNm8fCVdU1h//+YOoYQUgEZ25uOHPm/agByptI4Icqv/0u5pYpu2IJHo4ko/D3uVwsc9WRPyFt73uPW/EGgOCjVWTvNxuGxb6S7f1KMHuKrf4vrjeuO7YfklCldnjhnULLj0SV1LhdmRzkNNAU8WZdw/HCyRKpUmY5aM6UlkayI0x+plFMQE4ODj7yQaJ0r appuser

bootcmd:
  # install ruby
  - sudo apt update
  - sudo apt install -y ruby-full ruby-bundler build-essential
  # install mongo
  - wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
  - echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
  - sudo apt-get update
  - sudo apt-get install -y mongodb-org
  - sudo systemctl start mongod
  - sudo systemctl enable mongod
  # install reddit
  - cd ~
  - apt install git
  - git clone -b monolith https://github.com/express42/reddit.git
  - cd reddit && bundle install
  - puma -d
```

Другой вариант конфигаруционного файла cloud-config_sudoers.d.yml:
```
#cloud-config

bootcmd:
  - echo "======Put public key to authorized_keys======"
  - PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjk1hL2RJ/cLvzmBZ4dsRGKmceEh+x5VxMPY09/wG/yiv7j2gm+flQQ4bRZfQwmEPsVW8OflQPBfyVsttXoilG0Q5xO2hT1Kgjr/RMGW6LghXOZFSTFLEZ+OAXgf89W3RyYIMgsJti7qNTHJSqsq1CrxNm8fCVdU1h//+YOoYQUgEZ25uOHPm/agByptI4Icqv/0u5pYpu2IJHo4ko/D3uVwsc9WRPyFt73uPW/EGgOCjVWTvNxuGxb6S7f1KMHuKrf4vrjeuO7YfklCldnjhnULLj0SV1LhdmRzkNNAU8WZdw/HCyRKpUmY5aM6UlkayI0x+plFMQE4ODj7yQaJ0r appuser"
  - sudo echo $PUBKEY > ~/.ssh/authorized_keys
  - echo "======Create user======"
  - USERNAME="appuser"
  - adduser --disabled-password --gecos "" $USERNAME
  - echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USERNAM
  - echo "install ruby"
  - sudo apt update
  - sudo apt install -y ruby-full ruby-bundler build-essential
  - echo "install mongo"
  - wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
  - echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
  - sudo apt-get update
  - sudo apt-get install -y mongodb-org
  - sudo systemctl start mongod
  - sudo systemctl enable mongod
  - echo "install reddit"
  - cd ~
  - apt install git
  - git clone -b monolith https://github.com/express42/reddit.git
  - cd reddit && bundle install
  - puma -d
```

Команда создания ВМ (файл yc-create-instance-with-cloud-config.sh):
```
#!/bin/bash
yc compute instance create \
  --name reddit-app2 \
  --hostname reddit-app2 \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=cloud-config.yml

```

Передать файлы в git как выполняемые (+x):
```
git update-index --chmod=+x
```

## Module hw05-packer: Подготовка образов с помощью packer <a name="Module-hw05-packer"></a>
> Цель:
> В данном дз студент произведет сборку готового образа с уже установленным приложением при помощи Packer.
> Задеплоит приложение в Yandex compute cloud при помощи ранее подготовленного образа.
> В данном задании тренируются навыки: работы с Packer, работы с YC.
> Все действия описаны в методическом указании.

Выполненные работы

1. Создана ветка packer-base
2. Наработки с предыдущего ДЗ перенесены в директорию config-scripts
3. Установлена и проверена установка программы parcker
4. Создан сервисный аккаунт.
   Для этого:

    4.1 Получен folder-id - ID каталога в Yandex.Cloud:
    ```
    yc config list
    ```

    4.2 Создан сервисный аккаунт (скрипт create_service_account.sh)
    ```
    #!/bin/bash
    SVC_ACCT=vl71
    FOLDER_ID=b1g97nk43unle0o4u325
    yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
    ```

    4.3 Созданному сервисному аккаунту vl71 даны права editor (скрипт grant_rights.sh)
    ```
    #!/bin/bash
    SVC_ACCT=vl71
    FOLDER_ID=b1g97nk43unle0o4u325
    ACCT_ID=$(yc iam service-account get $SVC_ACCT |  grep ^id | awk '{print $2}')
    yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCT_ID
    ```

5. Создан IAM ключ
```
yc iam key create --service-account-id $ACCT_ID --output /home/appuser/key.json
```

6. Создана директория packer. В директории parker создан Parker шаблон ubuntu16.json, содержащий описание образа VM.

>**_Note_**: Документация https://cloud.yandex.com/en-ru/docs/solutions/infrastructure-management/packer-quickstart

```
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "../../key.json",
            "folder_id": "b1g97nk43unle0o4u325",
            "zone":      "ru-central1-a",
            "source_image_family": "ubuntu-1604-lts",
            "subnet_id":           "e9be9todt50r72c98ftm",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "ssh_username": "ubuntu",
            "use_ipv4_nat": "true",
            "platform_id": "standard-v1"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
При этом в последствии была решена проблема:
```
==> yandex: Error creating network: server-request-id = 27eebca8-706f-4212-b2a1-a7948ac8f242 server-trace-id = e5114d186ea652c1:e5196846675842d1:e5114d186ea65
2c1:1 client-request-id = e1f3eb34-35cb-46f1-a0a7-daef57aa620d client-trace-id = c5146722-e94d-41f0-bfa9-b7b6902ea975 rpc error: code = ResourceExhausted desc
 = Quota limit vpc.networks.count exceeded
Build 'yandex' errored after 2 seconds 240 milliseconds: Error creating network: server-request-id = 27eebca8-706f-4212-b2a1-a7948ac8f242 server-trace-id = e5
114d186ea652c1:e5196846675842d1:e5114d186ea652c1:1 client-request-id = e1f3eb34-35cb-46f1-a0a7-daef57aa620d client-trace-id = c5146722-e94d-41f0-bfa9-b7b6902e
a975 rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
```

<b>Решение:</b>
В template в секцию builders добавлены:
```
    zone": "ru-central1-a",
    "subnet_id": "e9be9todt50r72c98ftm",
    "use_ipv4_nat": "true",
```

>**_NOTE_:** Сделано на основе: https://cloud.yandex.com/en-ru/docs/solutions/infrastructure-management/packer-quickstart

7. В директорию scripts были скопированы скрипты install_ruby.sh и install_mongodb.sh из предыдущего ДЗ.

8. Выполнена проверка шаблона командой
```
packer validate ./ubuntu16.json
```
9. Выполнена сборка образа reddit-base
```
packer build ./ubuntu16.json
```

10. Создана ВМ (скрипт yc-create-instance.sh)
```
#!/bin/bash
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=b1g97nk43unle0o4u325,image-family=reddit-base,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/appuser.pub
```

11. Внешний IP адрес созданной ВМ сделан статическим
>**_NOTE_:** документация https://cloud.yandex.com/en-ru/docs/vpc/operations/set-static-ip
```
yc vpc address list
```
Вывод:
```
+----------------------+------+---------------+----------+------+
|          ID          | NAME |    ADDRESS    | RESERVED | USED |
+----------------------+------+---------------+----------+------+
| e9bqjk6mvujdfci9i68l |      | 62.84.117.216 | true     | true |
+----------------------+------+---------------+----------+------+
```
Установить как статический:
```
yc vpc address update --reserved=true e9bqjk6mvujdfci9i68l
```
Вывод:
```
id: e9bqjk6mvujdfci9i68l
folder_id: b1g97nk43unle0o4u325
created_at: "2021-09-25T07:41:43Z"
external_ipv4_address:
  address: 62.84.117.216
  zone_id: ru-central1-a
  requirements: {}
reserved: true
used: true
type: EXTERNAL
ip_version: IPV4
```

12. Установлен reddit
```
ssh -i ~/.ssh/appuser appuser@62.84.117.216
sudo apt-get update
sudo apt-get install -y
gitgit clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
```

13. Проверена работоспособность reddit: http://62.84.117.216:9292

### Параметризирование шаблона

14. Созданы файлы с переменными variables.json и variables.json.example

15. На базе ubuntu16.json создан immutable.json
```
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{user `key`}}",
            "folder_id": "{{user `folder_id`}}",
            "zone":      "{{user `zone`}}",
            "source_image_family": "{{user `source_image_family`}}",
            "subnet_id":           "{{user `subnet_id`}}",
            "image_name": "{{user `image_family`}}-{{timestamp}}",
            "image_family": "{{user `image_family`}}",
            "ssh_username": "{{user `ssh_username`}}",
            "use_ipv4_nat": "true",
            "platform_id": "standard-v1"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "file",
            "source": "files/puma.service",
            "destination": "/tmp/puma.service"
        },
        {
            "type": "shell",
            "inline": [
                "sudo mv /tmp/puma.service /etc/systemd/system/puma.service",

                "cd /opt",
                "sudo apt-get install -y git",
                "sudo chmod -R 0777 /opt",
                "git clone -b monolith https://github.com/express42/reddit.git",
                "cd reddit && bundle install",
                "sudo systemctl daemon-reload && sudo systemctl start puma && sudo systemctl enable puma"
            ]
        }
    ]
}
```
где в качестве базового image указан ранее созданный image reddit-base.
Для установки reddit создан скрипт scripts/install_reddit.sh

16. На основе ресурса https://github.com/puma/puma/blob/master/docs/systemd.md в директории files создан файл puma.service

17. Файл puma.service включается в образ с помощью provisioner https://www.packer.io/docs/provisioners/file
Далее уже с помощью provisioner shell при создании image устанавливается из директории /tmp в нужную директорию /etc/systemd/system/

18. Проверка и создание образа reddit-full
```
packer validate -var-file=./variables.json ./immutable.json
packer build -var-file=./variables.json ./immutable.json
```

19. Создан скрипт create-reddit-vm.sh  в  директории config-scripts для создания ВМ из образа reddit-full
```
yc compute instance create --name reddit-full --hostname reddit-full --memory=4 --create-boot-disk image-folder-id=b1g97nk43unle0o4u325,image-family=reddit-full,size=10GB --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 --metadata serial-port-enable=1 --ssh-key C:\Users\vlulin\.ssh\appuser.pub
```
20. Внешний IP адрес созданной ВМ сделан статическим
```
yc vpc address list
yc vpc address update --reserved=true ...
```
21. Проверена работа приложения в ВМ созданного из образа reddit-full: http://62.84.116.36:9292/

## Module hw06-terraform-1 "Декларативное описание в виде кода инфраструктуры YC, требуемой для запуска тестового приложения, при помощи Terraform." <a name="Module-hw06-terraform-1"></a>
> Цель:
> В данном дз студент опишет всю инфраструктуру в Yandex Cloud при помощи Terraform.
> В данном задании тренируются навыки: создания и описания инфраструктуры при помощи Terraform. Принципы и подходы IaC.
> Все действия описаны в методическом указании.

1. В инфраструктурном репозитории для выполнения данного создана ветка terraform-1
2. Установлен terraform v.0.12.8
3. Создана директория terraform и файл main.tf
4. В .gitignore добавлены шаблоны файлов terrfarom
5. В Yandex Cloud создан сервисный account terraform, которому дана роль editor
6. Создан авторизованный ключ для сервисного аккаунта terraform
```
yc iam key create --service-account-name terraform --output terraform-key.json
```
7. Создан профиль для выполнения команд от имени сервисного аккаунта terraform
```
yc config profile create terraform-profile
```
8. В конфигурации профиля указан авторизованный ключ сервисного аккаунта:
```
yc config set service-account-key key.json
```
9. В файл main.tf добавлено описания провайдера и ресурса.
10. Создана ВМ с помощью команды:
```
terraform apply -auto-approve
```
11. В ответ на ошибку 'the specified number of cores is not available on platform "standard-v1"' сделано следующее:
11.1 Добавлен атрибут platform_id = "standard-v2"
11.2 Установлен атрибут resources.0.cores = 2
11.3 Установлен атрибут resources.0.core_fraction = 5
12. Сгенерированы ключи для пользователя ubuntu
13. Добавлена секция metadata для описания ssh-ключа для пользователя ubuntu в main.tf
14. Выполнено пересоздание ВМ с помощью команд terraform destroy и terraform apply
15. Выполнено успешное присоединение к созданноё ВМ с пользователем ubuntu с помощью команд
```
terraform show | grep nat_ip_address
ssh -i ~/.ssh/ubuntu/ubuntu ubuntu@62.84.117.150
```
16. Создан файл output.tf
17. Получен ip с помощью команд
```
terraform refresh
terraform output
```
18. Создан файл files/puma.service
19. В файл main.tf добавлен provisioner "remote-exec"
20. Создан файл files/deploy.sh
21. В файл main.tf добавлена секция connection для возможности соединения provisioners к ВМ
22. Отмечаем ВМ как ресурс, который требуется пересоздать при следующем применении изменений
```
terraform taint yandex_compute_instance.app
```
23. Применены изменения, т.е. пересоздана ВМ и выполнены provisioners
24. Проверена работоспособность приложения reddit по выведенному external_ip_address_app = 130.193.39.109
25. Создан файл variables.tf для входных переменных для параметризации входных переменных
26. В файле main.tf определение ресурсов сделано через переменные
27. Определены переменные в файле terraform.tfvars
28. Пересоздана ВМ. external_ip_address_app = 130.193.48.249. Проверена работоспособность приложения reddit.

### Самостоятельные задания
29. Определена переменная для приватного ключа private_key_path
30. Определены входные переменные:
```
variable "zones" - тип map, список возможных зон
variable "zone"  - выбранная зона из списка
```
31. Выполнено форматирование файлов main.tf, terraform.tfvars, variables.tf с помощью команды terraform fmt
32. Создан файл terraform.tfvars.example

### Задание **
33. Cоздан файл lb_target_group.tf с описанием target group, которая будет подключена к load balancer.
```
resource "yandex_lb_target_group" "vl-lb-target-group" {
  name      = "vl-target-group"
  folder_id = var.folder_id
  region_id = var.region_id

  target {
    address = yandex_compute_instance.app.network_interface.0.ip_address
      subnet_id = var.subnet_id
  }
}

```

34. Создан файл lb.tf с описанием load balancer
```
resource "yandex_lb_network_load_balancer" "vllb" {
  name = "vl-network-load-balancer"
  type = "external"

  listener {
    name = "vl-listener"
    port = 80
    target_port = 9292

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.vl-lb-target-group.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 9292
      }
    }
  }
}
```

35. Добавлена переменная lb_network_ip_address в output.tf
```
output "lb_network_ip_address" {
  value = yandex_lb_network_load_balancer.vllb.listener.*.external_address_spec[0].*.address
}
```

36. Созданы target group и load balancer с помощью команд
```
terraform plan
terraform apply -auto-approve
```

37. Создано второе приложение reddit-app2
```
resource "yandex_compute_instance" "app2" {
  name = "reddit-app2"
  ...
}
```

Второе приложение добавлено в target group "vl-lb-target-group"
```
  target {
    address = yandex_compute_instance.app2.network_interface.0.ip_address
      subnet_id = var.subnet_id
  }
```

Внесены изменения в output.tf
```
output "external_ip_addresses_app" {
  value = yandex_compute_instance.app[*].network_interface.0.nat_ip_address
}
```

38. Проверена работоспособность запросов к приложению через load balancer при остановке одного из приложений (команда 'systemctl stop puma')

39. Ответ на вопрос "Какие проблемы вы видите в такой конфигурации приложения?"
При выполненном вышеописанном подходе при необходимости добавления дополнительной ноды,
требуется копирование описания настроек resource "yandex_compute_instance"
и правка описания target group. Что не есть хорошо, так как требуется копирование кода.

40. Реализован подход с заданием количества инстансов через параметр ресурса count.

В файл variables.tf добавлено описание переменной количество требуемых инстансов
```

Удалены настройки второго приложения app2.
Внесены изменения в настройки приложения app учитывающие количество создаваемых инстансов.
```
resource "yandex_compute_instance" "app" {
  iter        = var.required_number_instances
  name        = "reddit-app-${iter.index}"
  platform_id = "standard-v2"
```

Изменено описание target group, чтобы приложения включались в группу динамически
```
dynamic "target" {
    for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
    content {
      subnet_id = var.subnet_id
      address   = target.value
    }
  }
```

40. Пересоздано и проверено приложение с помощью команд:
```
terraform plan -var="required_number_instances=2"
terraform apply -auto-approve -var="required_number_instances=2"
```
вывод:
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_app = [
  "62.84.112.13",
  "62.84.114.78",
]
lb_network_ip_address = [
  "62.84.118.205",
]
```

## Module hw07-terraform-2 "Создание Terraform модулей для управления компонентами инфраструктуры." <a name="Module-hw07-terraform-2"></a>
> Цель:
> В данном дз студент продолжит работать с Terraform.
> Опишет и произведет настройку нескольких окружений при помощи Terraform. Настроит remote backend.
> В данном задании тренируются навыки: работы с Terraform, использования внешних хранилищ состояния инфраструктуры.
> Описание и настройка инфраструктуры нескольких окружений. Работа с Terraform remote backend.

1. В инфраструктурном репозитории для выполнения данного создана ветка terraform-2
2. В конфигурационный файл main.tf добавлены ресурсы yandex_vpc_network и yandex_vpc_subnet
3. При попытке выполнения команды terraform apply получена ошибка "Quota limit vpc.networks.count exceeded".
Решение удаление сети по умолчанию.
Cloud monitor > Virtual Private Cloud > Cloud Networks > (B) Delete
Или через CLI:
Получить идентификатор сети:
```
yc vpc net list --folder-id "b1g97nk43unle0o4u325"
```
Получить идентификаторы подсетей:
```
yc vpc net list-subnets --id enpen3usuf0mpovt2h1u
```
Удаление подсетей:
```
yc vpc subnet delete --id <subnet id>
```
Удаление сети:
```
yc vpc net delete --id <net id>
```
4. ... паралельное создание
5. В main.tf добавлено создание network_interface. Выполнен перезапуск, где ВМ стала создаваться после создания подсети.
6. В директории packer созданы два новых шаблона db.json и app.json в которые скопировано и подкорректировано содержимое файла ubuntu16.json.
7. В файлы apps.json и db.json внесены изменения. Создан соответствующий файл с переменными variables_for_terraform.json
8. Созданы образы приложения и базы:
```
packer validate -var-file=./variables_for_terraform.json db.json
packer build -var-file=./variables_for_terraform.json db.json
packer validate -var-file=./variables_for_terraform.json app.json
packer build -var-file=./variables_for_terraform.json app.json
```
9. В директории teraforms создан файл app.tf
10. В файле variables.tf объявлены новые переменные app_disk_image и db_disk_image для указания id образов.
11. В файле terraform.tfvars переменным app_disk_image и db_disk_image даны значения.
12. В файле variables.tf объявлена новая переменная required_db_number_instances определяющая количество инстансов с базой данных.
13. Создан файл vpc.tf куда вынесено описание конфигурации сети. Разнесены другие ресурсы в соответствии с заданием.
14. Выполнена установка измененной конфигурации с помощью команды terraform apply. Выполнена проверка и удаление с помощью команды terraform destroy.
15. Создана директория modules
16. В директории terraform/modules
17. Создана директория db в которой созданы файлы: main.tf, outputs.tf и variables.tf. В файлы main.tf, outputs.tf и variables.tf перенесена соответствующая информация.
18. Создана директория app в которой созданы файлы: main.tf, outputs.tf и variables.tf. В файлы main.tf, outputs.tf и variables.tf перенесена соответствующая информация.
19. Создана директория vpc куда перенесены настройки сети.
20. Для использования модулей загружаем их командой terraform get.
21. В файле terraform/outputs.tf исправлено определение переменных для вывода с ссылкой на модули.
22. Переустановлено приложение и проверена его работоспособность.
23. В директории terrafrom созданы две директории: stage и prod.
24. Скопированы файлы main.tf, variables.tf, outputs.tf, terraform.tfvars, key.json из директории terraform в директории stage и prod.
25. В каждой директории stage и prod выполнено terraform init и terraform apply.

### Самостоятельные задания:
26. Удалены из папки terraform файлы main.tf, outputs.tf, terraform.tfvars, variables.tf
27. Параметризированы конфигурации модулей. Добавлено значение количества создаваемых инстансов app
28. Отформатированы файлы *.fmt с помощью команды terraform fmt

### Задание со * "Настройка хранения state файла в удаленном хранилище Yandex Object Storage"
29. Создана директория storage-backet
30. В файле main.tf указан yandex провайдер.
31. В файле terraform-account.tf указаны команды определения account terraform.
32. А так как account terraform уже был создан, то выполнен импорт ресурса командой
```
terraform import yandex_iam_service_account.terraform <id terraform account>
```
33. Создан файл storage-backet.tf с определением хранилища.
34. Создано хранилище командой terraform apply.
35. В папках prod и stage созданы файлы:
- credentials.aws - с ключами для доступа к bucket
- backend.tf - для определения удаленного хранилища состояния terraform со следующим содержанием:
```
terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "vltf-state-bucket"
    region     = "ru-central1"
    key        = "prod/terraform.tfstate"
    shared_credentials_file = "./credentials.aws"

    skip_region_validation      = true
    skip_credentials_validation = true
   }
}
```
>**_Note_**: При этом при определении backend нельзя указывать пременные.
36. После создания файлов для опеределения backend выполнена команда terraform init
37. После выполнения команд terraform init и terraform plan в bucket новых объектов не появилось.
В bucket файл terraform.tfstate появился только после выполнения команды terraform apply -auto-approve.
38. Удаляем terraform.tfstate в локальной директории у выполняем команду terraform plan.
39. Файл credentials.aws добавлен в .gitignore

### Задание с ** "Добавление provisioner в модули"
40. Для deploy приложения в каждом из модулей создан каталог files куда скопированы файлы для конфигураций и деплоев приложений.
41. Создан шаблон puma.service.tmpl конфигурации приложения app, где добавлена передача адреса для подключения к базе данных:
```
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=ubuntu
Environment=DATABASE_URL=${database_ip}
WorkingDirectory=/home/ubuntu/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target
```
42. В файл modules/app/main.tf добавлены provisioners
```
  provisioner "file" {
    content     = templatefile("${path.module}/files/puma.service.tmpl", { database_ip = var.database_ip })
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
```
43. В файле modules/app/main.tf сделана явная зависимость между модулями app и db.
```
 depends_on = [var.database_ip]
```
44. Добавлен модуль lb с описанием конфигурации load balancer.
#### Реализация отключения provisioners в зависимости от значения переменной provisioners_required
45. В каждом модуле prod и stage создана переменная provisioners_required в файлах variables.tf:
```
variable provisioners_required {
  description = "Enabling and disabling provosioners"
  type = bool
  default = true
}
```
Такое же определение добавлено в файл определения переменных в модуле .\modules\app\variables.tf

46. В файлах prod\terraform.tfvars и stage\terraform.tfvars определено значение переменной required_provisioners
```
required_provisioners = true
```
47. Реализована передача значения переменной в модуль app.
Для этого внесены изменения в файлы prod\main.tf и stage\main.tf
```
module "app" {
  source                    = "../modules/app"
  public_key_path           = var.public_key_path
  private_key_path          = var.private_key_path
  app_disk_image            = var.app_disk_image
  required_number_instances = var.required_number_instances
  subnet_id                 = "${module.vpc.subnet_id}"
  database_ip               = "${module.db.external_ip_address_db}"
  required_provisioners     = var.required_provisioners
}
```
47. Для реализации исполнения/не исполнения provisioners в зависимости от переменной используется null_resource для которого
количество (count) экземпляров (1 или 0) определяется в зависимости от значения переменной provisioners_required.
Данный ресурс должен быть исполнен для каждого создаваемого экземпляра app.
```
resource "null_resource" "inst_reddit" {
    count = var.provisioners_required ? 1 : 0
    triggers = {
      cluster_instance_ids = join(",", yandex_compute_instance.app.*.id)
    }

    connection {
      type  = "ssh"
      # host  = self.network_interface.0.nat_ip_address
      host  = "${yandex_compute_instance.app.*.id}"
      user  = "ubuntu"
      agent = false
      # путь до приватного ключа
      private_key = file(var.private_key_path)
    }

    provisioner "file" {
      content     = templatefile("${path.module}/files/puma.service.tmpl", { database_ip = var.database_ip })
      destination = "/tmp/puma.service"
    }

    provisioner "remote-exec" {
      script = "${path.module}/files/deploy.sh"
    }
}
```
48. После добавления null_resource потребовалось повторная инициализация terraform init
49. Установлена и проверена измененная версия приложения с помощью команлы
```
terraform apply -auto-approve
```
