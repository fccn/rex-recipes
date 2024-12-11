#
# AUTHOR: jan gehring <jan.gehring@gmail.com>
# REQUIRES: 
# LICENSE: Apache License 2.0
# 
# Simple Module to install Apache on your Server.

package Rex::Webserver::Apache;


use Rex -base;

# some package-wide variables

our %package = (
   debian => "apache2",
   ubuntu => "apache2",
   centos => "httpd",
   mageia => "apache-base",
);

our %service_name = (
   debian => "apache2",
   ubuntu => "apache2",
   centos => "httpd",
   mageia => "httpd",
);

our %document_root = (
   debian => "/var/www",
   ubuntu => "/var/www",
   centos => "/var/www/html",
   mageia => "/var/www/html",
);

our %vhost_path = (
   debian => "/etc/apache2/sites-available",
   ubuntu => "/etc/apache2/sites-available",
   centos => "/etc/httpd/conf.d",
   mageia => "/etc/httpd/conf.d",
);

task "setup", sub {

   my $pkg     = $package{lc(get_operating_system())};
   my $service = $service_name{lc(get_operating_system())};

   # install apache package
   update_package_db;
   install package => $pkg;

   # ensure that apache is started
   service $service => "ensure" => "started";

};

task "vhost", sub {
   
   my $param = shift;

   file $vhost_path{lc(get_operating_system())} . "/" . $param->{name} . ".conf",
      content => $param->{conf},
      owner   => "root",
      group   => "root",
      mode    => 644,
      on_change => sub {
         my $enable_method = 'enable_vhost_'.lc(get_operating_system());
         &{ \&$enable_method }($param->{name});
         service $service_name{lc(get_operating_system())} => "restart";
      };

};

sub enable_vhost_debian {
    my $name = shift;
    run "a2ensite $name";
}

sub enable_vhost_ubuntu {
    my $name = shift;
    enable_vhost_debian($name);
}

sub enable_vhost_centos {
    my $name = shift;
}
sub enable_vhost_mageia {
    my $name = shift;
}

sub getConfig {
    my $myConf = {
        'package' => $package{lc(get_operating_system())},
        'service_name' => $service_name{lc(get_operating_system())},
        'document_root' => $document_root{lc(get_operating_system())},
        'vhost_path' => $vhost_path{lc(get_operating_system())},
    };
    return $myConf;
}

# Create service actions like start, stop...
my @service_actions = qw( start stop restart reload );
foreach my $service_action (@service_actions) {
    task "$service_action" => sub {
        my $service = $service_name{lc(get_operating_system())};
        service $service => "$service_action";
    };
}


1;

=pod

=head1 NAME

Rex::Webserver::Apache - Module to install Apache

=head1 USAGE

Put it in your I<Rexfile>

 # your tasks
 task "one", sub {};
 task "two", sub {};
    
 require Rex::Webserver::Apache;

And call it:

 rex -H $host Webserver:Apache:setup

Or, to use it as a library

 task "yourtask", sub {
    Webserver::Apache::setup();
 };
   
 require Rex::Webserver::Apache;

=head1 TASKS

=over 4

=item setup

This task will install apache httpd.

=item vhost

This task will create a vhost.

 task "yourtask", sub {
    Rex::Webserver::Apache::vhost({
      name => "foo",
      conf => template("files/foo.conf"),
    });
 };

=item start

This task will start the apache daemon.

=item stop

This task will stop the apache daemon.

=item restart

This task will restart the apache daemon.

=item reload

This task will reload the apache daemon.

=back

=cut

