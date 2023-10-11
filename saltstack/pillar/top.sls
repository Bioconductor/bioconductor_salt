base:
  '*':
    - common
  'os:Ubuntu':
    - match: grain
    - common.linux
  'os:MacOS':
    - match: grain
    - common.mac
  '(nebbiolo*|lconway*|merida*|kjohnson*)':
    - common.cronjobs
  'nebbiolo*':
    - common.primary
