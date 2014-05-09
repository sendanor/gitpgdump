#!/usr/bin/env node
var exec = require('nor-exec');
var debug = require('nor-debug');
var PATH = require('path');
var argv = require('minimist')(process.argv.slice(2));

var pgconfig = argv.pg;
var newrelic = !!(argv.newrelic);
var backup_name = argv.name || 'data';
var newrelic_name = argv['newrelic-name'] || argv['newrelic'] || '';
var newrelic_license = argv['newrelic-license'] || '';

var basedir = process.cwd();
var datafile = PATH.join(basedir, backup_name);

var cmd;
var args;

if(newrelic) {
	cmd = PATH.resolve(__dirname, 'newrelic-gitpgdump.php');
	args = [pgconfig, datafile, newrelic_name, newrelic_license];
} else {
	cmd = PATH.resolve(__dirname, 'gitpgdump.sh');
	args = [pgconfig, datafile];
}

exec(cmd, args).fail(function(err) {
	debug.error(err);
}).done();

/* EOF */
