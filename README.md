# uamsclient formula
Install and configure uamsclient.

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).


If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`.

## Available states

* uamsclient.validation
* uamsclient.install
* uamsclient.clean

## uamsclient.validation

Validate host OS.

## uamsclient.install

Installs the uamsclient package.

## uamsclient.clean

Uninstalls the uamsclient package.

# Usage

See pillar.example for example configuration.

To deploy UAMS Client on hosts, add `uams_access_token`, `role` and `swo_url` to your pillar.

* uams_access_token: UAMS access token taken from SWO Observability platform
* swo_url: UAMS Cluster domain name
* uams_metadata: (optional) Can be used for setting UAMS Client role e.g.`role:host-monitoring`
* uams_https_proxy: (optional) You have the option to set an HTTPS proxy through the use of the `UAMS_HTTPS_PROXY` environment variable. Simply define this variable to point to your desired HTTPS proxy. Remember that the `UAMS_HTTPS_PROXY` environmental variable sets HTTPS proxy only for the connections established by the UAMS Client and its plugins. To use HTTPS proxy during installation set up HTTPS proxy on your machine so that saltstack will be able to use it.
* uams_override_hostname: (optional) A variable to set a custom Agent name. By default, Agent name is set to the hostname.
* uams_managed_locally: (optional) A variable is used to set Agent as managed locally through a configuration file.

## Locally managed Agents
The Variable `uams_managed_locally` is used to configure the Agent to be managed locally through the configuration file. 
It Is designed to allow configuration of the UAMS Agent locally, without necessity of adding integrations manually from SWO page.

If the UAMS Agent gets installed as a **managed locally** agent then it will wait for the local configuration file to be accessible. The default local configuration is `/opt/solarwinds/uamsclient/var/local_config.yaml`

SaltStack will automatically create the file in the needed location. 
The default template of local config file is located at `templates/template_local_config.yaml.j2`.

You can use jinja2 template syntax to fill the template with appropriate variables.
To assign values to variables in the template you can use pillar variable `local_config_template_parameters` as in the example below.
Parameters are accessed by referencing the `data` variable in jinja2 template.

```sls
# Pillar file
uamsclient:
  uams_access_token: 'your-token'
  swo_url: 'na-01.solarwinds.com'
  uams_metadata: 'role:host-monitoring'
  uams_managed_locally: true
local_config_template_parameters:
  mysql_host: host
  mysql_user: juser
```

```jinja2
# Example local configuration file
integrations:
  otel/hostmetrics:
    - name: host-monitoring
  mysql:
    - name: off-host-mysql
      host: {{ data.mysql_host }}
      port: 3306
      user: {{ data.mysql_user }}
{%- raw %}
      password: "{{.creds.env.MYSQL_DB_PASWORD}}"
{% endraw %}
      packet-capture-enabled: false

```

Testing
-------

Linux testing is done with CircleCI.