gitpgdump
=========

Git-based PostgreSQL database backup utility.

gitpgdump
---------

It's a simple javascript/bash/PHP script that saves the SQL dump in the git.

We're using PHP for New Relic because New Relic does not support custom metrics in Node.js yet.

We're using `sh` since it's a lot easier to use to run shell scripts.

We might port it as pure JS maybe in the future when New Relic has better support for Node.js.

### Installation

`npm install -g gitpgdump`

### Usage

```
mkdir my-backup-dir
cd my-backup-dir
git init
gitpgdump --newrelic-license='my-license-key' --newrelic-appname="gitpgdump-myapp" --pg="postgres://myuser:mypass@mypghost/mydbname"
```
