{% from "uamsclient/map.jinja" import pkg_manager, pkg_type, config with context %}

{% set uams_access_token = salt['pillar.get']('uamsclient:uams_access_token', 'n/a') %}
{% set swo_url = salt['pillar.get']('uamsclient:swo_url', 'na-01.cloud.solarwinds.com') %}
{% set uams_metadata = salt['pillar.get']('uamsclient:uams_metadata', None) %}
{% set uams_https_proxy = salt['pillar.get']('uamsclient:uams_https_proxy', None) %}
{% set uams_override_hostname = salt['pillar.get']('uamsclient:uams_override_hostname', None) %}
{% set uams_managed_locally = salt['pillar.get']('uamsclient:uams_managed_locally', None) %}
{% set is_container = salt['pillar.get']('is_container', 'false') %}

include:
  - uamsclient.validation

{% if uams_access_token | length < 70 %}
failure:
  test.fail_without_changes:
    - name: "Please provide correct access token using your pillar"
    - failhard: True
{% endif %}

uams_local_pkg_path:
  file.directory:
    - name: {{ config.uams_local_pkg_path }}
    - mode: "0755"
    - makedirs: True

download_installation_package:
  file.managed:
    - name: "{{ config.uams_local_pkg_path }}/uamsclient.{{ pkg_type }}"
    - source: "{{ config.install_pkg_url }}/uamsclient.{{ pkg_type }}"
    - source_hash: "{{ config.install_pkg_url }}/uamsclient.{{ pkg_type }}.sha256"


setting_envs:
   environ.setenv:
     - name: setting_envs
     - value:
         UAMS_ACCESS_TOKEN: {{ uams_access_token }}
         SWO_URL: {{ swo_url }}

{%- if uams_metadata %}
setting_uams_metadata:
   environ.setenv:
     - name: setting_envs
     - value:
         UAMS_METADATA: {{ uams_metadata }}
{%- endif %}

{%- if uams_https_proxy %}
setting_https_proxy:
   environ.setenv:
     - name: setting_envs
     - value:
         UAMS_HTTPS_PROXY: {{ uams_https_proxy }}
{%- endif %}

{%- if uams_override_hostname %}
setting_override_hostname:
   environ.setenv:
     - name: setting_envs
     - value:
         UAMS_OVERRIDE_HOSTNAME: {{ uams_override_hostname }}
{%- endif %}

{%- if uams_managed_locally %}
setting_uams_managed_locally:
   environ.setenv:
     - name: setting_envs
     - value:
         UAMS_MANAGED_LOCALLY: 'true'
{%- endif %}

install_uamsclient:
  pkg.installed:
    - sources:
      - uamsclient: "{{ config.uams_local_pkg_path }}/uamsclient.{{ pkg_type }}"
    - ignore: true

{% if uams_managed_locally %}
{% set local_config_template_parameters = salt['pillar.get']('local_config_template_parameters', None) %}
{% set credentials_config_template_parameters = salt['pillar.get']('credentials_config_template_parameters', None) %}

create_local_config_linux:
  file.managed:
    - name: /opt/solarwinds/uamsclient/var/local_config.yaml
    - source: salt://uamsclient/templates/template_local_config.yaml.j2
    - template: jinja
    - context:
        data: {{ local_config_template_parameters }}
    - user: swagent
    - group: swagent
    - mode: "0660"

create_credentials_config_linux:
  file.managed:
    - name: /opt/solarwinds/uamsclient/var/credentials_config.yaml
    - source: salt://uamsclient/templates/template_credentials_config.yaml.j2
    - template: jinja
    - context:
        data: {{ credentials_config_template_parameters }}
    - user: swagent
    - group: swagent
    - mode: "0660"

{% endif %}

{% if is_container != 'true' %}
uamsclient_service_running:
  service.running:
    - name: uamsclient.service
    - enable: True
{% endif %}

{% if is_container != 'true' %}
print_service_status:
  cmd.run:
    - name: "echo {{ salt['service.status']('uamsclient') }}"
{% endif %}
