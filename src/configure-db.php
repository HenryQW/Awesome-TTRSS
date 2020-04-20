#!/usr/bin/env php
<?php

$confpath = '/var/www/config.php';

$config = array();

$config['SELF_URL_PATH'] = env('SELF_URL_PATH', 'http://localhost');
$config['DB_TYPE'] = 'pgsql';
$config['DB_HOST'] = env('DB_HOST', 'database.postgres');
$config['DB_PORT'] = env('DB_PORT', 5432);
$config['DB_NAME'] = env('DB_NAME', 'ttrss');
$config['DB_USER'] = env('DB_USER');
$config['DB_PASS'] = env('DB_PASS');
$config['PLUGINS'] = env('ENABLE_PLUGINS', 'auth_internal');
$config['SESSION_COOKIE_LIFETIME'] = env('SESSION_COOKIE_LIFETIME', 24) * 3600;
$config['SINGLE_USER_MODE'] = env('SINGLE_USER_MODE', false);
$config['LOG_DESTINATION'] = env('LOG_DESTINATION', 'sql');
$config['FEED_LOG_QUIET'] = env('FEED_LOG_QUIET', false);

$log_daemon = '/etc/s6/update-daemon/run';

if($config['FEED_LOG_QUIET'] === "true"){
    $str = preg_replace('/.php$/m', '.php --quiet', file_get_contents($log_daemon));
} else {
    $str = preg_replace('/.php --quiet$/m', '.php', file_get_contents($log_daemon));
}

file_put_contents($log_daemon, $str);

if(dbcheckconn($config)){
    $pdo = dbconnect($config);

    if(!dbcheckdb($config)){

        echo 'Database not found, creating.'. PHP_EOL ;

        $pdo = dbconnect($config);
        $pdo -> exec('CREATE DATABASE ' . ($config['DB_NAME']) . ' WITH OWNER ' . ($config['DB_USER']));

        unset($pdo);

        $pdo = dbexist($config);
        try {
            $pdo->query('SELECT 1 FROM ttrss_feeds');
        }
        catch (PDOException $e) {
            echo 'Database table not found, applying schema... ' . PHP_EOL;
            $schema = file_get_contents('schema/ttrss_schema_pgsql.sql');
            $schema = preg_replace('/--(.*?);/', '', $schema);
            $schema = preg_replace('/[\r\n]/', ' ', $schema);
            $schema = trim($schema, ' ;');
            foreach (explode(';', $schema) as $stm) {
                $pdo->exec($stm);
            }

            $pdo->exec("CREATE EXTENSION IF NOT EXISTS pg_trgm");
            unset($pdo);
        }
    }
    $contents = file_get_contents($confpath);
    foreach ($config as $name => $value) {
        $contents = preg_replace('/(define\s*\(\'' . $name . '\',\s*)(.*)(\);)/', '$1"' . $value . '"$3', $contents);
    }

    if (getenv('HTTP_PROXY') !== false) {
        $contents .= "\r\n\t";
        $contents .= "define('_HTTP_PROXY', '"  . env('HTTP_PROXY') . "');";
    }

    file_put_contents($confpath, $contents);
}


function env($name, $default = null)
{
    $v = getenv($name) ?: $default;

    if ($v === null) {
        error('The env ' . $name . ' does not exist'). PHP_EOL ;
    }

    return $v;
}

function error($text)
{
    echo 'Error: ' . $text . PHP_EOL;
    exit(1);
}

function dbconnect($config)
{
    $map = array('host' => 'HOST', 'port' => 'PORT');
    $dsn = 'pgsql:dbname=postgres;';
    foreach ($map as $d => $h) {
        if (isset($config['DB_' . $h])) {
            $dsn .= $d . '=' . $config['DB_' . $h] . ';';
        }
    }
    $pdo = new \PDO($dsn, $config['DB_USER'], $config['DB_PASS']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $pdo;
}

function dbcheckconn($config)
{
    try {
        dbconnect($config);
        return true;
    }
    catch (PDOException $e) {
        echo $e;
        return false;
    }
}

function dbexist($config)
{
    $map = array('host' => 'HOST', 'port' => 'PORT' , 'dbname' =>'NAME');
    $dsn = 'pgsql:';
    foreach ($map as $d => $h) {
        if (isset($config['DB_' . $h])) {
            $dsn .= $d . '=' . $config['DB_' . $h] . ';';
        }
    }
    $pdo = new \PDO($dsn, $config['DB_USER'], $config['DB_PASS']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $pdo;
}

function dbcheckdb($config)
{
    try {
        dbexist($config);
        return true;
    }
    catch (PDOException $e) {
        echo $e;
        return false;
    }
}
