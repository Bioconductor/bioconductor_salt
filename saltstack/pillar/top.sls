base:
  'os:Ubuntu':
    - match: grain
    - common
  'os:Darwin':
    - match: grain
    - common
    - common.mac
