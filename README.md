<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4" />

# Branch vlyulin_infra
vlyulin Infra repository

# Content:
* [Student](#Student)
* [Module hw03-bastion](#Module-hw03-bastion)

# Student
Student: Vadim Lyulin
Course: DevOps
Group: Otus-DevOps-2021-08

## ## Module hw03-bastion<a name="Module-hw03-bastion"></a>
### Самостоятельное задание
Исследовать способ подключения к someinternalhost в однукоманду из вашего рабочего устройства, проверить работоспособностьнайденного решения и внести его в README.md в вашем репозитории.

#### Решение
Использовать ключ -J (ssh jump host) для перепрыгивания через hosts.
Команда:
```
ssh -i ~/.ssh/vlyulin_key -J appuser@130.193.38.153 appuser@10.128.0.30
```

### Дополнительное задание:
Предложить вариант решения для подключения из консоли при помощикоманды вида ssh someinternalhost из локальной консоли рабочегоустройства, чтобы подключение выполнялось по алиасуsomeinternalhost и внести его в README.md в вашем репозитории.

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
