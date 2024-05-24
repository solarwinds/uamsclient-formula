{% from "map.jinja" import pkg_manager, pkg_type, config with context %}

{% set uams_access_token = salt['pillar.get']('uamsclient:uams_access_token', 'n/a') %}
{% set swo_url = salt['pillar.get']('uamsclient:swo_url', 'na-01.cloud.solarwinds.com') %}
{% set uams_metadata = salt['pillar.get']('uamsclient:uams_metadata', 'n/a') %}
{% set uams_https_proxy = salt['pillar.get']('uamsclient:uams_https_proxy', None) %}
{% set is_container = salt['pillar.get']('is_container', 'false') %}

include:
  - validation 

{% if uams_access_token == 'n/a' %}
failure:
  test.fail_without_changes:
    - name: "Please provide access token using your pillar"
    - failhard: True
{% endif %}

uams_local_pkg_path:
  file.directory:
    - name: {{ config.uams_local_pkg_path }}
    - mode: 755
    - makedirs: True

download_installation_package:
  cmd.run:
    - name: "curl -o {{ config.uams_local_pkg_path }}/uamsclient.{{ pkg_type }} {{ config.install_pkg_url }}/uamsclient.{{ pkg_type }}"
    - unless: "test -f {{ config.uams_local_pkg_path }}/uamsclient.{{ pkg_type }}"

setting_envs:
   environ.setenv:
     - name: setting_envs
     - value:
         UAMS_ACCESS_TOKEN: {{ uams_access_token }}
         SWO_URL: {{ swo_url }}
         UAMS_METADATA: {{ uams_metadata }}

{%- if uams_https_proxy %}
setting_https_proxy:
   environ.setenv:
     - name: setting_envs
     - value:
         UAMS_HTTPS_PROXY: {{ uams_https_proxy }}
{%- endif %}

install_uamsclient:
  pkg.installed:
    - sources:
      - uamsclient: "{{ config.uams_local_pkg_path }}/uamsclient.{{ pkg_type }}"
    - ignore: true

{% if is_container != 'true' %}
uamsclient_service_running:
  service.running:
    - name: uamsclient.service
    - enable: True
    # - retry:
    #     attempts: 8
    #     interval: 2
{% endif %}

remove_uams_directory:
  file.absent:
    - name: {{ config.uams_local_pkg_path }}
    - recurse: True

{% if is_container != 'true' %}
print_service_status:
  cmd.run:
    - name: "echo {{ salt['service.status']('uamsclient') }}"
{% endif %}
