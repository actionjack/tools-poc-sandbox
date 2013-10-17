#
# Todo
# - Merge wget of jar file into puppet-jira module
# - Handle /opt/jira directory creation in puppet-jira module
#
group{ 'puppet': ensure => present }
stage { 'first': before => Stage['main'] }
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

node 'tools-poc' {
  file {'/opt/jira':
    ensure => 'directory',
    mode   => '0755'
  }

  class {'java':}

  class {'deploy':}

  class {'jira':
    javahome => '/usr/lib/jvm/java-7-openjdk-amd64',
    version  => '6.1',
    user     => 'jira',
    group    => 'jira',
    db       => 'mysql',
    dbport   => '3306',
    dbdriver => 'com.mysql.jdbc.Driver',

  }

  include wget

  wget::fetch { 'MySQL java connector':
    source      => 'http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.26/mysql-connector-java-5.1.26.jar',
    destination => '/opt/jira/atlassian-jira-6.1-standalone/lib/mysql-connector-java-5.1.26.jar',
    timeout     => 0,
    verbose     => false,
  }

  class { 'mysql::server':
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  mysql::db { 'jira':
    user     => 'jiraadm',
    password => 'mypassword',
    host     => 'localhost',
    charset => 'utf8',
    collate => 'utf8_bin',
    grant    => ['SELECT','INSERT','UPDATE','DELETE','CREATE','DROP','ALTER','INDEX'],
  }

}
