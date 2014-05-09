gitpgdump
=========

Git-based PostgreSQL database backup utility.

gitpgdump
---------

It's a simple bash script that saves the SQL dump in the git.

newrelic-gitpgdump
------------------

This is a simple PHP script that also records the backup process in your New 
Relic.

You can then use New Relic to monitor your backups.

The New Relic command is actually written in PHP instead of Node.js because New 
Relic does not support it at the moment.
