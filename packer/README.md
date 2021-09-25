
Подготовка образов с помощью packer

Возникшие проблемы:
```
==> yandex: Error creating network: server-request-id = 27eebca8-706f-4212-b2a1-a7948ac8f242 server-trace-id = e5114d186ea652c1:e5196846675842d1:e5114d186ea65
2c1:1 client-request-id = e1f3eb34-35cb-46f1-a0a7-daef57aa620d client-trace-id = c5146722-e94d-41f0-bfa9-b7b6902ea975 rpc error: code = ResourceExhausted desc
 = Quota limit vpc.networks.count exceeded
Build 'yandex' errored after 2 seconds 240 milliseconds: Error creating network: server-request-id = 27eebca8-706f-4212-b2a1-a7948ac8f242 server-trace-id = e5
114d186ea652c1:e5196846675842d1:e5114d186ea652c1:1 client-request-id = e1f3eb34-35cb-46f1-a0a7-daef57aa620d client-trace-id = c5146722-e94d-41f0-bfa9-b7b6902e
a975 rpc error: code = ResourceExhausted desc = Quota limit vpc.networks.count exceeded
```

Решение:
В template в секцию builders добавлены:
	zone": "ru-central1-a",
	"subnet_id": "e9be9todt50r72c98ftm",
	"use_ipv4_nat": "true",
Инструкция: https://cloud.yandex.com/en-ru/docs/solutions/infrastructure-management/packer-quickstart
