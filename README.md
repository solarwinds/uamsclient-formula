# uamsclient formula
Install and configure uamsclient.

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula` section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>.

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

To deploy UAMS Client on hosts, add `uams_access_token`, `role`, and `swo_url` to your pillar.

* uams_access_token: UAMS access token taken from the SWO Observability platform
* swo_url: UAMS Cluster domain name
* uams_metadata: (optional) Can be used for setting UAMS Client role, e.g., `role:host-monitoring`
* uams_https_proxy: (optional) You have the option to set an HTTPS proxy through the use of the `UAMS_HTTPS_PROXY` environment variable. Simply define this variable to point to your desired HTTPS proxy. Remember that the `UAMS_HTTPS_PROXY` environment variable sets HTTPS proxy only for the connections established by the UAMS Client and its plugins. To use HTTPS proxy during installation, set up HTTPS proxy on your machine so that SaltStack will be able to use it.
* uams_override_hostname: (optional) A variable to set a custom Agent name. By default, the Agent name is set to the hostname.
* uams_managed_locally: (optional) A variable used to set the Agent as managed locally through a configuration file.

## Locally managed Agents
The variable `uams_managed_locally` is used to configure the Agent to be managed locally through the configuration file. 
It is designed to allow configuration of the UAMS Agent locally, without the necessity of adding integrations manually from the SWO page.

If the UAMS Agent gets installed as a **locally managed** agent, then it will wait for the local configuration file to be accessible. The default local configuration is `/opt/solarwinds/uamsclient/var/local_config.yaml`.

An additional optional configuration file `credentials_config.yaml` can be used to define credentials providers. This file can be used in conjunction with `local_config.yaml` to retrieve a credential from a defined credential provider.

SaltStack will automatically create both files (`credentials_config.yaml` and `local_config.yaml`) in the needed location.

You can find default templates for these files in the locations:
- `local_config.yaml`: `templates/template_local_config.yaml.j2`
- `credentials_config.yaml`: `templates/template_credentials_config.yaml.j2`

You can use Jinja2 template syntax to fill the template with appropriate variables.
To assign values to variables in the template, you can use the pillar variables `local_config_template_parameters` and `credentials_config_template_parameters` as in the example below.
Parameters are accessed by referencing the `data` variable in the Jinja2 template.

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
  secret_name: my-secret
credentials_config_template_parameters:
  access_key_id: your-access-key-id
  secret_access_key: your-secret-access-key
```

```jinja2
# Example local configuration file
integrations:
  otel/hostmetrics:
    - name: host-monitoring
  dbo/mysql:
    - name: off-host-mysql
      host: {{ data.mysql_host }}
      port: 3306
      user: {{ data.mysql_user }}
      password:
        value-from:
          provider: aws-secrets-manager
          secret-name: {{ data.secret_name }}
      packet-capture-enabled: false
```

```jinja2
# Example credentials configuration file
credentials:
  aws-secrets-manager:
    auth:
      type: static
      access-key-id: {{ data.access_key_id }}
      secret-access-key: {{ data.secret_access_key }}
      region: us-east-1
```

Testing
-------

Linux testing is done with CircleCI.