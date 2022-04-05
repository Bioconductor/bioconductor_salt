# Needed by CRAN nlopter

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.cmake.split("/")[-1] %}
{% set cmake = download[-4] %}

brew_uninstall_cmake:
  cmd.run:
    - name: brew uninstall cmake
    - runas: biocbuild

download_cmake:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.cmake }}
    - cwd:  {{ machine.user.home }}/biocbuild/Downloads
    - user: biocbuild

attach_cmake:
  cmd.run:
    - name: hdiutil attach {{ download }}
    - require:
      - cmd: download_cmake

cp_cmake_to_applications:
  cmd.run:
    - name: cp -ri /Volumes/{{ cmake }}/CMake.app /Applications/
    - runas: biocbuild
    - require:
      - cmd: attach_cmake

detach_cmake:
  cmd.run:
    - name: hdiutil detach /Volumes/{{ cmake }}
    - require:
      - cmd: cp_cmake_to_applications

prepend_cmake_to_path:
  file.append:
    - name: /etc/profile
    - text: export PATH="/Applications/CMake.app/Contents/bin:$PATH"
    - require:
      - cmd: detach_cmake
