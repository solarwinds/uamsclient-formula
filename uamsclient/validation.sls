{% from "uamsclient/map.jinja" import pkg_manager, pkg_type, config with context %}

print_config_variables:
  cmd.run:
    - name: echo "install_pkg_url, {{ config.install_pkg_url }}, uams_local_pkg_path, {{ config.uams_local_pkg_path }}"

{% set supported_distros = {
    'Amazon': 2,
    'CentOS': 7,
    'Debian': 9,
    'Fedora': 32,
    'Kali': 2021,
    'Oracle': 8,
    'RedHat': 7,
    'Rocky': 8,
    'Ubuntu': 18,
    'OEL': 6
} %}

{% set os_full_name = grains['osfullname'] %}
{% set os_major_release = grains['osmajorrelease'] %}
{% set os_name = grains['os'] %}

debug_variables:
  cmd.run:
    - name: echo "pkg_manager {{ pkg_manager }}, pkg_type {{ pkg_type }}, os_name {{ os_full_name }}, os_major{{ os_major_release }}, os_name {{ os_name }}"

{% if os_name in supported_distros.keys() and os_major_release >= supported_distros[os_name] %}
print_supported:
  cmd.run:
    - name: echo "Supported, {{ os_full_name }}, {{ os_major_release }}"
{% else %}
print_unsupported:
  cmd.run:
    - name: echo "Unsupported, {{ os_full_name }}, {{ os_major_release }}"
failure:
  test.fail_without_changes:
    - name: "OS not supported!"
    - failhard: True
{% endif %}
