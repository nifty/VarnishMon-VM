class carbon {
    $build_dir = "/tmp"
    $carbon_url = "https://launchpad.net/graphite/0.9/0.9.10/+download/carbon-0.9.10.tar.gz"
    $carbon_loc = "$build_dir/carbon-0.9.10.tar.gz"

    package { "python-twisted":
        ensure => latest,
    }

    file { "/var/log/carbon":
        ensure => directory,
        owner => www-data,
        group => www-data,
    }

    exec { "download-carbon":
        command => "wget -O $carbon_loc $carbon_url",
        creates => "$carbon_loc",
        unless => 'test -f /opt/graphite/bin/carbon-cache.py'
    }

    exec { "unpack-carbon":
        command => "tar -zxvf $carbon_loc",
        cwd => $build_dir,
        subscribe => Exec[download-carbon],
        refreshonly => true,
    }

    exec { "install-carbon":
        command => "python setup.py install",
        cwd => "$build_dir/carbon-0.9.10",
        subscribe => Exec[unpack-carbon],
        creates => "/opt/graphite/bin/carbon-cache.py",
    }

    file { "/opt/graphite/conf/carbon.conf":
        source => "/opt/graphite/conf/carbon.conf.example",
        subscribe => Exec[install-carbon],
    }

    file { "/opt/graphite/conf/storage-schemas.conf":
        source => "/opt/graphite/conf/storage-schemas.conf.example",
        subscribe => Exec[install-carbon],
    }
}
