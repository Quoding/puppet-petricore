# puppet-jobs_exporter
Puppet deployment scripts for jobs_exporter/petriCORE

## Assumptions
The deployment script for jobs_exporter assumes that most packages used by the `jobs_exporter` are already installed on the machine (as with Magic Castle). For now it only installs `python36-psutil` package since it's the only package that was actually missing during the testing phase (on Magic Castle). Any further missing packages will be added if the need arises.

## Repo for the puppet-magic_castle that works with this module
https://github.com/Quoding/puppet-magic_castle