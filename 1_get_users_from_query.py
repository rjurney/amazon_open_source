#!/usr/bin/env python

import re

# Extract usernames from Amazon's Github query so we can search for their repos one by one
# without exceeding 1,000 repos per search.
with open('query.txt') as f:
    query = f.read()

pattern = re.compile('user%3A(.+?)\+')
users = pattern.findall(query)

# One username per line
with open('data/users.txt', 'w') as f:
    for user in users:
        f.write(user + '\n')
