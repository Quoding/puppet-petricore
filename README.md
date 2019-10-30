# puppet-jobs_exporter
Puppet deployment scripts for jobs_exporter/petriCORE

## Assumptions
The deployment script for jobs_exporter assumes that most packages used by the `jobs_exporter` are already installed on the machine (as with Magic Castle). For now 
it only installs `python36-psutil` package since it's the only package that was actually missing during the testing phase (on Magic Castle). Any further missing packages
will be added if the need arises.


##Checklist
- Go to `/etc/puppetlabs/code/environments/production/`
- Clone this repo inside `modules/`
- Rename it to `jobs_exporter/` instead of `puppet-jobs_exporter/`
- Modify `site/profile/metrics.pp` to add the pushgateway
- Modify `manifest/site.pp`, under `login` add `include jobs_exporter::webapp`, under `node` (regex, at the bottom, NOT DEFAULT), add `include jobs_exporter`
- Restart `puppetserver` (mgmt) and `puppet` agents (nodes) to recompile catalog and apply changes
- Modify nginx config so it either bypasses JupyterHub or it redirects to port :5000 (or the webapp port you chose) on desired path name (e.g. example.server/logic -> 127.0.0.1:5000)
- Restart nginx
- Disable puppet agents (nodes) so they don't mess up the new nginx config.
- You should be done by now, hopefully it works.