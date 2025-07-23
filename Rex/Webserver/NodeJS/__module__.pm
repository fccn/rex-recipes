package Rex::Webserver::NodeJS;

use strict;
use warnings;
use Rex -base;

my %NODEJS_CONF = ();

# node version manager
our $nvm_address = "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh";
our $version = 22;


Rex::Config->register_set_handler("nodejs" => sub {
	my ($name, $value) = @_;
	$NODEJS_CONF{$name} = $value;
});

task "setup",
	sub {
		my $service;
		my $OS = lc(get_operating_system());
		my $dep_function = 'install_deps_'.$OS;
		my $nvm;

		# install node version manager
		$nvm = $NODEJS_CONF{nvm_address}->{$OS} ? 
			$NODEJS_CONF{nvm_address}->{$OS} : $nvm_address;

		no strict 'refs';
		&$dep_function();

		# setup a different node repository
		run "curl -o- $nvm | sudo -E bash -";
		run "\. \"\$HOME/.nvm/nvm.sh\"";
		run "nvm install $version"

	};

sub install_deps_centos {
	pkg "curl", ensure    => "present";
};

sub install_deps_debian {
	pkg "curl", ensure    => "present";
};

sub install_deps_ubuntu {
	pkg "curl", ensure    => "present";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Rex::Development::Maven/;

 task yourtask => sub {
    Rex::Development::Maven::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
