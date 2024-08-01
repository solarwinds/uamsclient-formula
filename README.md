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

Uninstalls the uamsclient package. WIP.

### Usage

See pillar.example for example configuration.

To deploy UAMS Client on hosts, add `uams_access_token`, `role` and `swo_url` to your pillar.

* uams_access_token: UAMS access token taken from SWO Observability platform
* swo_url: UAMS Cluster domain name
* uams_metadata: (optional) Can be used for setting UAMS Client role e.g.`role:host-monitoring`
* uams_https_proxy: (optional) You have the option to set an HTTPS proxy through the use of the `UAMS_HTTPS_PROXY` environment variable. Simply define this variable to point to your desired HTTPS proxy. Remember that the `UAMS_HTTPS_PROXY` environmental variable sets HTTPS proxy only for the connections established by the UAMS Client and its plugins. To use HTTPS proxy during installation set up HTTPS proxy on your machine so that saltstack will be able to use it.
* uams_override_hostname: (optional) A customer client hostname. It is required if you want to set a specific agent hostname. 

Testing
-------

Linux testing is done with CircleCI.