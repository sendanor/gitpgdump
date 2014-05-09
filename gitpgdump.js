#!/usr/bin/env node
var exec = require('nor-exec');
var debug = require('nor-debug');
var PATH = require('path');
var argv = require('minimist')(process.argv.slice(2));

var pgconfig = argv.pg;
var backup_name = argv.name || 'data';

var newrelic = !!( argv.newrelic || argv['newrelic-appname'] || argv['newrelic-name'] || argv['newrelic-license'] );
var newrelic_name = argv['newrelic-appname'] || argv['newrelic-name'] || argv['newrelic'] || '';
var newrelic_license = argv['newrelic-license'] || '';

var basedir = process.cwd();
var datafile = PATH.join(basedir, backup_name);

if(process.env.GITPGDUMP_DEBUG !== undefined) {
	debug.log('pgconfig: ', pgconfig);
	debug.log('backup_name: ', backup_name);
	debug.log('newrelic: ', newrelic);
	debug.log('newrelic_name: ', newrelic_name);
	debug.log('newrelic_license: ', newrelic_license);
	debug.log('basedir: ', basedir);
	debug.log('datafile: ', datafile);
}

var cmd;
var args;

if(newrelic === true) {
	cmd = PATH.resolve(__dirname, 'newrelic-gitpgdump.php');
	args = [pgconfig, datafile, newrelic_name, newrelic_license];
} else {
	cmd = PATH.resolve(__dirname, 'gitpgdump.sh');
	args = [pgconfig, datafile];
}

exec(cmd, args).then(function(results) {
	if(process.env.GITPGDUMP_DEBUG !== undefined) {
		console.log(results.stdout);
		console.error(results.stderr);
	}
}).fail(function(err) {
	console.error('gitpgdump: error: ' + (err.stderr || err));
	if(process.env.GITPGDUMP_DEBUG !== undefined) {
		if(err.stdout) {
			debug.log('stdout = ', err.stdout);
		}
		if(err.stdout) {
			debug.log('retval = ', err.retval);
		}
	}
}).done();

/* EOF */
