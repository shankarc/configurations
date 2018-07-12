#!/usr/bin/env python
# May 12,2018

# TIP 1
# Using any, or all for boolean evaluation
a = 10
b = 20

if (all([a == 10, b == 20])):
    print ("True")
else:
    print ("False")

if (any([a < 10, b > 10])):
    print ("True")
else:
    print ("False")


##################################################
# Concat
class Config:
    def __init__(self, **entries):
        self.entries = entries

    def __add__(self, other):
        entries = dict(self.entries.items()
                       + other.entries.items())
        return Config(**entries)

    def __repr__(self):
        return '{}({})'.format(self.__class__.__name__,
                               self.entries.items())


# Usage
default_config = Config(color=False, port=8080)
print (default_config)
config = default_config + Config(color=True)
print (config)
##################################################
# https://github.com/brandon-rhodes/python-bookbinding
# The modern json Standard Library module is an example of good practice
import json
json.loads(...)
json.dumps(...)
# not json_load() or jdump()

# Naming intermediate values
canvas.drawString(x, y,
    'Please press {}'.format(key))
#to
message = 'Please press {}'.format(key)
canvas.drawString(x, y, message)
# Removes ugly hanging indent
# Provides extra documentation

#1 Use continue
for item in sequence:
    if is_valid(item):
        if not is_inconsequential(item):
            item.do_something()
for item in sequence:
    if not is_valid(item):
        continue
    if is_inconsequential(item):
        continue
    item.do_something()
