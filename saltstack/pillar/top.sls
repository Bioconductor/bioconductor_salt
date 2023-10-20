base:
  '*':
    - common
  'os:Ubuntu':
    - match: grain
    - common.linux
  'os:MacOS':
    - match: grain
    - common.mac
  'nebbiolo*':
    - common.primary
  'nebbiolo* or lconway* or merida* or kjohnson*':
    - common.cronjobs
