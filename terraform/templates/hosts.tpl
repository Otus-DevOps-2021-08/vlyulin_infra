[app]
%{ for ip in app_ips ~}
${ip}
%{ endfor ~}

[db]
%{ for ip in db_ips ~}
${ip}
%{ endfor ~}
