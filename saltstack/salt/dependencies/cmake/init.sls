# Needed by CRAN nloptr

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.cmake.split("/")[-1] %}

brew_uninstall_cmake:
  cmd.run:
    - name: brew uninstall cmake
    - runas: {{ machine.user.name }}
    - unless:
      - brew info cmake

download_cmake:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.cmake }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

remove_old_cmake:
  cmd.run:
    - name: rm -rf /Applications/CMake.app
    - require:
      - cmd: download_cmake

untar_cmake_to_applications:
  archive.extracted:
    - name: /Applications
    - source: /tmp/{{ download }}
    - require:
      - cmd: remove_old_cmake

prepend_cmake_to_path:
  file.append:
    - name: /etc/profile
    - text: export PATH="/Applications/CMake.app/Contents/bin:$PATH"
    - require:
      - archive: untar_cmake_to_applications
