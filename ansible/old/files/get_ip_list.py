import sys, json
import fnmatch
import objectpath

if len(sys.argv) == 1:
    print("{}")
    exit;

# grps = dict.fromkeys(sys.argv[1:],[])
grps = json.loads(sys.argv[1])
out_grps = {}

json_data = json.load(sys.stdin)
tree = objectpath.Tree(json_data)

for key in grps.keys():
    ips = tree.execute('$.*[@.labels.tags is "' + key + '"].network_interfaces..primary_v4_address.one_to_one_nat.address')
    ipsl = list(ips)
    out_grps[key.replace("reddit-","")] = {"hosts": ipsl}

print(json.dumps(out_grps, indent=4, sort_keys=True))
