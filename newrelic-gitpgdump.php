#!/usr/bin/env php5
<?php
try {
	if(!extension_loaded('newrelic')) {
		throw new Exception('No newrelic loaded!');
	}

	if(!(isset($argv[1]) && $argv[2])) {
		throw new Exception('USAGE: newrelic-gitpgdump.php PGCONFIG DATAFILE [NAME] [LICENSE]');
	}

	$pgconfig = $argv[1];
	$datafile = $argv[2];
	$name     = 'gitpgdump';
	$license  = '';

	if(isset($argv[3]) && (strlen($argv[3]) !== 0)) {
		$name = $argv[3];
	}

	if(isset($argv[4]) && (strlen($argv[4]) !== 0)) {
		$license = $argv[4];
	}

	$time     = round(microtime(true) * 1000);

	if(strlen($license) !== 0) {
		newrelic_set_appname($name, $license);
	} else {
		newrelic_set_appname($name);
	}

	newrelic_background_job(true);
	newrelic_name_transaction ("/background/gitpgdump");
	newrelic_custom_metric('Custom/Backup/time', $time );

	$return_var = -1;
	passthru( dirname(__FILE__) . "/gitpgdump.sh " . escapeshellarg($pgconfig) . " " . escapeshellarg($datafile), $return_var);

	$file_size = filesize($datafile . ".sql");
	newrelic_custom_metric('Custom/Backup/file_size', $file_size );

	$last_line = system("du -bsx " . escapeshellarg(dirname($datafile)) . "|tr '\n\t' '  '" );
	$parts = explode(" ", $last_line);
	$dir_size = intval($parts[0], 10);
	newrelic_custom_metric('Custom/Backup/dir_size', $dir_size );

	if($return_var != 0) {
		throw new Exception('Failed to execute backup!');
	}

} catch(Exception $e) {
	echo 'gitpgdump: error: ', $e->getMessage(), "\n";
	if(extension_loaded('newrelic')) {
		newrelic_notice_error($e->getMessage(), $e);
	}
	exit(1);
}
?>
