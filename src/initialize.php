#!/usr/bin/env php
<?php

$confpath = '/var/www/config.php';

$config = array();

$config['SELF_URL_PATH'] = env('SELF_URL_PATH');

$config['DB_TYPE'] = 'pgsql';
$config['DB_HOST'] = env('DB_HOST');
$config['DB_PORT'] = env('DB_PORT');
$config['DB_NAME'] = env('DB_NAME');

$config['DB_USER'] = env('DB_USER');
$config['DB_PASS'] = env('DB_PASS');

$config['PLUGINS'] = env('ENABLE_PLUGINS');
$config['SESSION_COOKIE_LIFETIME'] = env('SESSION_COOKIE_LIFETIME') * 3600;
$config['SINGLE_USER_MODE'] = filter_var(env('SINGLE_USER_MODE'), FILTER_VALIDATE_BOOLEAN);
$config['LOG_DESTINATION'] = env('LOG_DESTINATION');


// Wait for the db connection
$i = 1;
while (!checkConnection(true) && $i <= 10) {
    sleep(3);
    $i++;
}
if (checkConnection(true)) {
    $pdo = connectDatabase(true);

    if (!checkConnection(false)) {
        echo 'Database not found, creating.'. PHP_EOL ;

        $pdo = connectDatabase(true);
        $pdo -> exec('CREATE DATABASE ' . ($config['DB_NAME']) . ' WITH OWNER ' . ($config['DB_USER']));

        unset($pdo);

        $pdo = connectDatabase(false);

        try {
            $pdo->query('SELECT 1 FROM ttrss_feeds');
        } catch (PDOException $e) {
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
    $contents = "<?php\r\n\r\n";
    foreach ($config as $name => $value) {
        $contents .= "\tputenv('TTRSS_" . $name . '='. $value . "');";
        $contents .= "\r\n";
    }

    if (getenv('HTTP_PROXY') !== false) {
        $contents .= "\tputenv('TTRSS_HTTP_PROXY="  . env('HTTP_PROXY') . "');";
        $contents .= "\r\n";
    }

    if (getenv('DISABLE_USER_IN_DAYS') !== false) {
        $contents .= "\tputenv('TTRSS_DAEMON_UPDATE_LOGIN_LIMIT="  . env('DISABLE_USER_IN_DAYS') . "');";
        $contents .= "\r\n";
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

function connectDatabase($create)
{
    // Create the database
    if ($create) {
        $map = array('host' => 'HOST', 'port' => 'PORT');
        $dsn = 'pgsql:dbname=postgres;';
    }
    // Seed tables
    else {
        $map = array('host' => 'HOST', 'port' => 'PORT' , 'dbname' =>'NAME');
        $dsn = 'pgsql:';
    }
    
    foreach ($map as $d => $h) {
        if (getenv('DB_' . $h)!==null) {
            $dsn .= $d . '=' . getenv('DB_' . $h) . ';';
        }
    }

    $pdo = new PDO($dsn, getenv('DB_USER'), getenv('DB_PASS'));
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    return $pdo;
}

function checkConnection($create)
{
    try {
        connectDatabase($create);
        return true;
    } catch (PDOException $e) {
        echo $e;
        return false;
    }
}
