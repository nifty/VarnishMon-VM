class whisper {
    $build_dir = "/tmp"
    $whisper_url = "https://launchpad.net/graphite/0.9/0.9.10/+download/whisper-0.9.10.tar.gz"
    $whisper_loc = "$build_dir/whisper-0.9.10.tar.gz"

    exec { "download-whisper":
        command => "wget -O $whisper_loc $whisper_url",
        creates => "$whisper_loc",
        unless => 'test -d /opt/graphite/storage/whisper'
    }

    exec { "unpack-whisper":
        command => "tar -zxvf $whisper_loc",
        cwd => $build_dir,
        subscribe => Exec[download-whisper],
        refreshonly => true,
    }

    exec { "install-whisper":
        command => "python setup.py install",
        cwd => "$build_dir/whisper-0.9.10",
        subscribe => Exec[unpack-whisper],
        refreshonly => true,
    }
}
