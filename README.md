# puppet-petricore
Puppet deployment scripts for petriCORE

## Assumptions
The deployment script for jobs_exporter assumes that most packages used by the `jobs_exporter` are already installed on the machine (as with Magic Castle). For now it only installs `python36-psutil` package from the CC stack's wheels since it's the only package that was actually missing during the testing phase (on Magic Castle). Any further missing packages will be added if the need arises.

## Repo for the puppet-magic_castle that works with this module
https://github.com/calculquebec/puppet-magic_castle

```
puppetenv_git = "https://github.com/calculquebec/puppet-magic_castle.git"
puppetenv_rev = "testing"
```

Note that the magic_castle repo makes 2 new virtual hosts which redirect to Prometheus and PetriCORE. 

- petricore.yourhostname
- prometheus.yourhostname

