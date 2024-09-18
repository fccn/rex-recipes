#
# AUTHOR: jan gehring <jan.gehring@gmail.com>
# REQUIRES: 
# LICENSE: Apache License 2.0
# 
# Simple Module to install PHP on your Server.

package Rex::Lang::PHP;


use Rex -base;

# some package-wide variables

our %schema = (
   Debian => 'php-%s',
   Ubuntu => 'php-%s',
   CentOS => 'php-%s',
   Mageia => 'php-%s',
);

our %package = (
   Debian => 'php',
   Ubuntu => 'php',
   CentOS => 'php',
   Mageia => 'php-cli',
);

our %pear_schema = (
   Debian => 'php-%s',
   Ubuntu => 'php-%s',
   CentOS => 'php-pear-%s',
   Mageia => 'php-pear-%s',
);

our %pecl_schema = (
   Debian => 'php-%s',
   Ubuntu => 'php-%s',
   CentOS => 'php-pecl-%s',
   Mageia => 'php-%s',
);

task "setup", sub {

   my $pkg     = $package{get_operating_system()};

   # install php package
   update_package_db;
   install package => $pkg;

};

1;

=pod

=head1 NAME

Rex::Lang::PHP - Module to install PHP.

=head1 USAGE

Put it in your I<Rexfile>

 # your tasks
 task "one", sub {};
 task "two", sub {};
    
 require Rex::Lang::PHP;

And call it:

 rex -H $host Lang:PHP:setup

Or, to use it as a library

 task "yourtask", sub {
    Rex::Lang::PHP::setup();
 };
   
 require Rex::Lang::PHP;

=head1 TASKS

=over 4

=item setup

This task will install PHP.

=back

=cut

