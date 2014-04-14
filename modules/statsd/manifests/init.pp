class statsd {
    exec { 'install_statsd':
        command => 'git clone https://github.com/etsy/statsd.git',
        cwd => '/usr/share',
        creates => '/usr/share/statsd',
        path => ['/usr/bin'],
        require => Package[git]
    }

    file { '/var/log/statsd':
        ensure => 'directory'
    }

    user { '_statsd':
        ensure => 'present',
        system => true,
        home => '/nonexistent',
        managehome => false,
        shell => '/bin/false',
        comment => 'StatsD User'
    }
}
