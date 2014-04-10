class graphite {
    $build_dir = '/tmp'
    $graphite_url = 'https://launchpad.net/graphite/0.9/0.9.10/+download/graphite-web-0.9.10.tar.gz'
    $graphite_loc = '/tmp/graphite-web-0.9.10.tar.gz'

    $dependecies = [
        'python-cairo', 'libapache2-mod-python', 'python-django',
        'python-memcache', 'python-django-tagging', 'sqlite3',
        'python-pysqlite2', 'libapache2-mod-wsgi'
    ]

    package { $dependecies:
        ensure => 'latest'
    }

    exec { 'download-graphite':
        command => "wget -O $graphite_loc $graphite_url",
        creates => "$graphite_loc",
        unless => 'test -d /opt/graphite/webapp'
    }

    exec { 'unpack-graphite':
        command => "tar -zxvf graphite-web-0.9.10.tar.gz",
        cwd => "$build_dir",
        subscribe => Exec[download-graphite],
        refreshonly => true,
    }

    exec { 'install-graphite':
        command => "python setup.py install",
        cwd => "$build_dir/graphite-web-0.9.10",
        require => Exec[unpack-graphite],
        creates => '/opt/graphite/webapp',
    }

    file { ['/opt/graphite/storage', '/opt/graphite/storage/whisper']:
        owner => 'www-data',
        group => 'www-data',
        subscribe => Exec[install-graphite],
        mode => '0775',
    }

    file { 'local-settings':
        name => '/opt/graphite/webapp/graphite/local_settings.py',
        source => 'puppet:///modules/graphite/local_settings.py',
    }

    file { 'initial-data':
        name => '/opt/graphite/webapp/graphite/initial_data.json',
        source => 'puppet:///modules/graphite/initial_data.json',
    }

    exec { 'init-db':
        command => 'python manage.py syncdb --noinput',
        cwd => '/opt/graphite/webapp/graphite',
        creates => '/opt/graphite/storage/graphite.db',
        subscribe => Exec[install-graphite],
        require => [File['local-settings'], File['initial-data']],
    }

    file { 'graphite-wsgi':
        name => '/opt/graphite/conf/graphite.wsgi',
        source => '/opt/graphite/conf/graphite.wsgi.example',
    }

    file { 'graphite-vhost':
        name => '/etc/apache2/sites-enabled/graphite',
        source => 'puppet:///modules/graphite/graphite.vhost',
        require => [Package['apache2'], File['graphite-wsgi']],
        notify => Service['apache2'],
    }
}
