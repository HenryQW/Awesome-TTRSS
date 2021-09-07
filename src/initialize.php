#!/usr/bin/env php
<?php

$confpath = '/var/www/config.php';

// For configs, see https://git.tt-rss.org/fox/tt-rss/src/branch/master/classes/config.php

$config = array();

$config['DB_TYPE'] = 'pgsql';
$config['DB_HOST'] = env('DB_HOST');
$config['DB_USER'] = env('DB_USER');
$config['DB_NAME'] = env('DB_NAME');
$config['DB_PASS'] = env('DB_PASS');
$config['DB_PORT'] = env('DB_PORT');
$config['SELF_URL_PATH'] = env('SELF_URL_PATH');

$config['SINGLE_USER_MODE'] = filter_var(env('SINGLE_USER_MODE'), FILTER_VALIDATE_BOOLEAN);
$config['PLUGINS'] = env('ENABLE_PLUGINS');
$config['SESSION_COOKIE_LIFETIME'] = env('SESSION_COOKIE_LIFETIME') * 3600;


$config['SIMPLE_UPDATE_MODE'] = filter_var(env('SIMPLE_UPDATE_MODE'), FILTER_VALIDATE_BOOLEAN);
$config['PHP_EXECUTABLE'] = env('PHP_EXECUTABLE');
$config['LOCK_DIRECTORY'] = env('LOCK_DIRECTORY');
$config['CACHE_DIR'] = env('CACHE_DIR');
$config['ICONS_DIR'] = env('ICONS_DIR');
$config['ICONS_URL'] = env('ICONS_URL');
$config['AUTH_AUTO_CREATE'] = filter_var(env('AUTH_AUTO_CREATE'), FILTER_VALIDATE_BOOLEAN);
$config['AUTH_AUTO_LOGIN'] = filter_var(env('AUTH_AUTO_LOGIN'), FILTER_VALIDATE_BOOLEAN);
$config['FORCE_ARTICLE_PURGE'] = env('FORCE_ARTICLE_PURGE');
$config['SMTP_FROM_NAME'] = env('SMTP_FROM_NAME');
$config['SMTP_FROM_ADDRESS'] = env('SMTP_FROM_ADDRESS');
$config['DIGEST_SUBJECT'] = env('DIGEST_SUBJECT');
$config['CHECK_FOR_UPDATES'] = filter_var(env('CHECK_FOR_UPDATES'), FILTER_VALIDATE_BOOLEAN);
$config['LOG_DESTINATION'] = env('LOG_DESTINATION');
$config['LOCAL_OVERRIDE_STYLESHEET'] = env('LOCAL_OVERRIDE_STYLESHEET');
$config['LOCAL_OVERRIDE_JS'] = env('LOCAL_OVERRIDE_JS');
$config['DAEMON_MAX_CHILD_RUNTIME'] = env('DAEMON_MAX_CHILD_RUNTIME');
$config['DAEMON_MAX_JOBS'] = env('DAEMON_MAX_JOBS');
$config['FEED_FETCH_TIMEOUT'] = env('FEED_FETCH_TIMEOUT');
$config['FEED_FETCH_NO_CACHE_TIMEOUT'] = env('FEED_FETCH_NO_CACHE_TIMEOUT');
$config['FILE_FETCH_TIMEOUT'] = env('FILE_FETCH_TIMEOUT');
$config['FILE_FETCH_CONNECT_TIMEOUT'] = env('FILE_FETCH_CONNECT_TIMEOUT');
$config['DAEMON_FEED_LIMIT'] = env('DAEMON_FEED_LIMIT');
$config['DAEMON_SLEEP_INTERVAL'] = env('DAEMON_SLEEP_INTERVAL');
$config['MAX_CACHE_FILE_SIZE'] = env('MAX_CACHE_FILE_SIZE');
$config['MAX_DOWNLOAD_FILE_SIZE'] = env('MAX_DOWNLOAD_FILE_SIZE');
$config['MAX_FAVICON_FILE_SIZE'] = env('MAX_FAVICON_FILE_SIZE');
$config['CACHE_MAX_DAYS'] = env('CACHE_MAX_DAYS');
$config['MAX_CONDITIONAL_INTERVAL'] = env('MAX_CONDITIONAL_INTERVAL');
$config['DAEMON_UNSUCCESSFUL_DAYS_LIMIT'] = env('DAEMON_UNSUCCESSFUL_DAYS_LIMIT');
$config['LOG_SENT_MAIL'] = filter_var(env('LOG_SENT_MAIL'), FILTER_VALIDATE_BOOLEAN);
$config['HTTP_PROXY'] = env('HTTP_PROXY');
$config['FORBID_PASSWORD_CHANGES'] = env('FORBID_PASSWORD_CHANGES');
$config['SESSION_NAME'] = env('SESSION_NAME');
$config['CHECK_FOR_PLUGIN_UPDATES'] = filter_var(env('CHECK_FOR_PLUGIN_UPDATES'), FILTER_VALIDATE_BOOLEAN);
$config['ENABLE_PLUGIN_INSTALLER'] = filter_var(env('ENABLE_PLUGIN_INSTALLER'), FILTER_VALIDATE_BOOLEAN);
$config['AUTH_MIN_INTERVAL'] = env('AUTH_MIN_INTERVAL');
$config['HTTP_USER_AGENT'] = env('HTTP_USER_AGENT');

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
            $schema = file_get_contents('sql/pgsql/schema.sql');

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
        if($value !== null){
            $contents .= "\tputenv('TTRSS_" . $name . '='. $value . "');";
            $contents .= "\r\n";
        }
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

    return $v;
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
