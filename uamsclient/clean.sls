{% from "uamsclient/map.jinja" import pkg_manager, pkg_type, config with context %}

{% set is_container = salt['pillar.get']('is_container', 'false') %}

uams_local_pkg_path:
  file.absent:
    - name: {{ config.uams_local_pkg_path }}

uninstall_uamsclient:
  pkg.removed:
    - name: uamsclient

{% if is_container != 'true' %}
uamsclient_service_running:
  service.dead:
    - name: uamsclient.service
    - enable: false
{% endif %}

