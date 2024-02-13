import numpy as np
import pandas as pd
import requests
import json

url = 'https://www.fema.gov/api/open/v1/MissionAssignments'

resp = requests.get(url)

raw = resp.json()
print(raw.keys())

dat = raw['MissionAssignments']