Exec {
    path => ["/usr/bin", "/usr/sbin", '/bin']
}

include git

class { 'apache':  }

class { 'nodejs':
    version => 'stable',
}

class { 'varnish':
    varnish_listen_port => 8080,
    varnish_storage_size => '1G',
}

class { 'whisper': }
class { 'carbon': }
class { 'graphite': }
class { 'statsd': }

