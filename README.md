# Redmine Nikoca Re Plugin

![screenshot](https://raw.githubusercontent.com/yuuu/redmine_nikoca_re/master/assets/images/screenshot.png)

Niko-niko Calender plugin for Redmine.

redmine_nikoca_re is plugin to check the mood for project members.

## Installation 
```bash
$ cd /path/to/redmine/plugins
$ git clone https://github.com/yuuu/redmine_nikoca_re.git
$ cd /path/to/redmine
$ rake redmine:plugins:migrate NAME=redmine_nikoca_re RAILS_ENV=production 
(restart redmine)
```

## Uninstallation
```bash
$ cd /path/to/redmine
$ rake redmine:plugins:migrate NAME=redmine_nikoca_re VERSION=0 RAILS_ENV=production 
(restart redmine)
```
## Material sources
<http://www.emstudio.jp/>

<http://sozai.akuseru-design.com/>

## License
All the files in this distribution are covered under the MIT license.
see the file MITL.
