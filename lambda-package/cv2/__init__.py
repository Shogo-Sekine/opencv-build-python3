import importlib
from pprint import pprint
pprint(importlib.import_module('cv2.cv2').__dict__)
globals().update(importlib.import_module('cv2.cv2').__dict__)
