base:
  'os:Ubuntu':
    - match: grain
    - common
  'os:MacOS':
    - match: grain
    - common
    - common.mac
