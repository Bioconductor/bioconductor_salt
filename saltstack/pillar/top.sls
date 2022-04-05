base:
  'os:Ubuntu':
    - match: grain
    - common
    - common.linux
  'os:MacOS':
    - match: grain
    - common
    - common.mac
