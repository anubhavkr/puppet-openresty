class openresty ( $version = '1.11.2.2', $pcre_version = '8.39', ) {

	file { 'openresty home':
		ensure => directory,
		path   => '/opt/openresty',
		mode   => '0755',
	}

	ensure_packages(['wget','readline-devel', 'pcre-devel', 'openssl-devel', 'gcc', 'gcc-c++'])

	exec { 'download openresty':
		cwd => '/tmp',
		path=> '/sbin:/bin',
		command => "wget https://openresty.org/download/openresty-${version}.tar.gz",
		notify  => Exec['untar openresty'],
		require => Package['wget'],
	}

	exec { 'untar openresty':
		cwd => '/tmp',
		path=> '/sbin:/bin',
		command => "tar -zxvf openresty-${version}.tar.gz",
		creates => "/tmp/openresty-${version}/configure",
		notify  => Exec['configure openresty'],
	}

	exec { 'download pcre':
		cwd     => '/tmp',
		path    => '/sbin:/bin',
		command => "wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.gz",
		notify  => Exec['untar pcre'],
    	}	

    	exec { 'untar pcre':
		cwd     => '/tmp',
		path    => '/sbin:/bin',
		command => "tar -zxvf pcre-${pcre_version}.tar.gz",
		notify  => Exec['configure openresty'],
    	}

	exec { 'configure openresty':
		cwd     => "/tmp/openresty-${version}",
		path    => '/sbin:/bin',
		command => "/tmp/openresty-${version}/configure --prefix=/opt/openresty --with-pcre --with-pcre=/tmp/pcre-${pcre_version} --with-pcre-jit --with-http_ssl_module --with-luajit",
		require => [Exec['untar openresty'], Package['gcc', 'gcc-c++', 'readline-devel', 'pcre-devel', 'openssl-devel']],
		notify  => Exec['install openresty'],
	}

	exec { 'install openresty':
		cwd     => "/tmp/openresty-${version}",
		path    => '/sbin:/bin',
		command => "make && make install; chown -R ${user}:${group} /opt/openresty ; rm -rf /tmp/openresty-${version}.tar.gz; rm -rf /tmp/pcre-${pcre_version}.tar.gz",
		require => Exec['configure openresty'],
	}
}
