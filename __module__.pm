#
# AUTHOR: jan gehring <jan.gehring@gmail.com>
# REQUIRES: 
# LICENSE: Apache License 2.0
# 
# Simple Module to install MySQL on your Server.

package Rex::Database::MySQL;


use Rex -base;

# some package-wide variables

our %package = (
   debian => "mysql-server",
   ubuntu => "mysql-server",
   centos => "mysql-server",
   mageia => "mysql",
);

our %service_name = (
   debian => "mysql",
   ubuntu => "mysql",
   centos => "mysqld",
   mageia => "mysqld",
);

our $__configuration = { 
	user => 'mysql',
	data_dir => '/var/lib/mysql',
	conf_dir => '/etc/mysql/conf.d',
	log_dir => '/var/log/mysql',
	owner => 'mysql',
	group => 'mysql',
};

our @__settings = (
	{ 'log-error' => '/var/log/mysqld.log' },
);

task "setup", sub {

   my $pkg     = $package{lc(get_operating_system())};
   my $service = $service_name{lc(get_operating_system())};

   # install mysql package
   update_package_db;
   install package => $pkg;

   init();

   # ensure that mysql is started
   service $service => "ensure" => "started";

};


task "init", sub {
   initialize_configs();
};


task "start", sub {

   my $service = $service_name{lc(get_operating_system())};
   service $service => "start";

};

task "stop", sub {

   my $service = $service_name{lc(get_operating_system())};
   service $service => "stop";

};

task "restart", sub {

   my $service = $service_name{lc(get_operating_system())};
   service $service => "restart";

};

task "reload", sub {

   my $service = $service_name{lc(get_operating_system())};
   service $service => "reload";

};

sub initialize_configs {
	my $config = getConfiguration();
	my $user = $config->{user};
	my $settings = param_lookup ("settings", \@__settings);
	my $conf_dir =  $config->{conf_dir};

	# if config dir doesn't exist, create one
	if (!is_dir($conf_dir)) {
		file $conf_dir, ensure => "directory";
	}

	# ensure we don't have repeated settings, remove existing
	my %existing_keys;
	my @filtered_settings;

	foreach my $setting (@{$settings}) {
		foreach my $key (keys %$setting) {
		unless ($existing_keys{$key}) {
				$existing_keys{$key} = 1;
				push @filtered_settings, { $key => $setting->{$key} };
			}
		}
	}

	$settings = \@filtered_settings;

	file "$conf_dir/my.cnf",
		content   => template("templates/my.cnf.tpl", settings => $settings);

};

sub getConfiguration {
	return param_lookup ("configuration", $__configuration);
}

1;

=pod

=head1 NAME

Rex::Database::MySQL - Module to install MySQL Server

=head1 USAGE

Put it in your I<Rexfile>

 # your tasks
 task "one", sub {};
 task "two", sub {};
    
 require Rex::Database::MySQL;

And call it:

 rex -H $host Database:MySQL:setup

Or, to use it as a library

 task "yourtask", sub {
    Rex::Database::MySQL::setup();
 };
   
 require Rex::Database::MySQL;

=head1 TASKS

=over 4

=item setup

This task will install mysql server.

=item start

This task will start the mysql daemon.

=item stop

This task will stop the mysql daemon.

=item restart

This task will restart the mysql daemon.

=item reload

This task will reload the mysql daemon.

=back

=cut

