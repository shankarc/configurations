#!/usr/bin/env python

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