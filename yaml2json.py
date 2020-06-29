import yaml
import json
import sys

doc = yaml.safe_load(sys.stdin)
json.dump(doc, sys.stdout)

