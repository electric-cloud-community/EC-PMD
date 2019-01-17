    # -------------------------------------------------------------------------
	# Package
	#    pmdDriver.pl
	#
	# Dependencies
	#    None
	#
	# Purpose
	#    Template for Single Command-line Plug-ins
	#
	# Template Version
	#    1.0
	#
	# Date
	#    07/13/2011
	#
	# Engineer
	#    Carlos Rojas
	#
	# Copyright (c) 2010 Electric Cloud, Inc.
	# All rights reserved
	# -------------------------------------------------------------------------

	# -------------------------------------------------------------------------
	# Includes
	# -------------------------------------------------------------------------
	use ElectricCommander;
	use warnings;
	use strict;
    use Cwd;
    use utf8;
	$|=1;
	
	# -------------------------------------------------------------------------
	# Constants
	# -------------------------------------------------------------------------
	use constant {
	   SUCCESS => 0,
	   ERROR   => 1,
	   
	   PLUGIN_NAME => 'EC-PMD',
	   EXECUTABLE => 'plugin',
	   
	   GENERATE_REPORT => 1,
	   DO_NOT_GENERATE_REPORT => 0,
	   REPORT_NAME => 'PMD Result',

	};
	
	########################################################################
	# trim - deletes blank spaces before and after the entered value in 
	# the argument
	#
	# Arguments:
	#   -untrimmedString: string that will be trimmed
	#
	# Returns:
	#   trimmed string
	#
	########################################################################  
	sub trim {
	  my ($untrimmedString) = @_;
	  my $string = $untrimmedString;
	  $string =~ s/^\s+//;
	  $string =~ s/\s+$//;
	  return $string;
	}
	
	# -------------------------------------------------------------------------
	# Variables
	# -------------------------------------------------------------------------
    # If property or parameter might contain high Unicode get the value from the property via the EC API:
    # my $foo = ($ec->getProperty( "foo" ))->findvalue("//value");
    my $ec = new ElectricCommander;
    my $pluginKey = 'EC-PMD';
    my $xpath = $ec->getPlugin($pluginKey);
    my $pluginName = $xpath->findvalue('//pluginVersion')->value;
    print "Using plugin $pluginKey version $pluginName\n";
	$::gJavaPath = trim(q($[javapath]));
	$::gPMDPath = trim(($ec->getProperty("pmdpath"))->findvalue("//value"));
	$::gAuxClasspath = trim(q($[classpath]));
	$::gTargetAnalize = trim(($ec->getProperty("target"))->findvalue("//value"));
	$::gWorkingDir = trim("$[workingdir]");
	$::gCommands = trim("$[javacommands]");
	$::gReportFormat = trim("$[reportformat]");
	$::gReportFile = trim("$[reportfile]");
	$::gRulesets = trim("$[rulesets]");
	
	#more global variables to be added here

	# -------------------------------------------------------------------------
	# Main functions
	# -------------------------------------------------------------------------


	########################################################################
	# main - contains the whole process to be done by the plugin, it builds 
	#        the command line, sets the properties and the working directory
	#
	# Arguments:
	#   none
	#
	# Returns:
	#   none
	#
	########################################################################
	sub main {
    
    # create args array
    my @args = ();
    
    #properties' map
    my %props;
    
	#setting the executable file
    my $copyReportCommand = '';
    my $reportPathToCopy;
    
    #add path to exec if entered
    my $executable = "";
    
    if($::gJavaPath && $::gJavaPath ne ""){
        $executable = $::gJavaPath;
    }
    
    #argument passing to the args array
    push(@args, $executable);
    
    if($::gPMDPath && $::gPMDPath ne "") {
        push(@args, '-jar "' . $::gPMDPath . '"' );
    }
    
    if($::gTargetAnalize && $::gTargetAnalize ne "") {
        push(@args, '"' . $::gTargetAnalize . '"');
    }
    
    if($::gReportFormat && $::gReportFormat ne "") {
        push(@args, $::gReportFormat);
    }
    
    if($::gRulesets && $::gRulesets ne "") {
        push(@args, $::gRulesets);
    }
    
    if($::gReportFile && $::gReportFile ne "") {
        if($::gWorkingDir && $::gWorkingDir ne ""){
            push(@args, '-reportfile "' . $::gWorkingDir . '/' . $::gReportFile . '"');
        }else{
            push(@args, '-reportfile "' . $::gReportFile . '"');
        }
    }
    
    if($::gAuxClasspath && $::gAuxClasspath ne "") {
        push(@args, '-auxclasspath "' . $::gAuxClasspath . '"');
    }

    if($::gCommands  && $::gCommands  ne "") {
        foreach my $command (split(' +', $::gCommands)) {
             push(@args, "$command");
        }
    }
    
    #In case the user define a custom wk we need to copy the reportfile 
    if($::gWorkingDir && $::gWorkingDir ne "" && $::gReportFile && $::gReportFile ne "")
    {
        if($^O eq 'linux'){
            $props{'copyCommand'} = 'cp "'. $::gWorkingDir . "/" . $::gReportFile . '" '. '"' . cwd . '"';
        }else{
            $props{'copyCommand'} = 'copy "'. $::gWorkingDir . "/" . $::gReportFile . '" '. '"' . cwd . '"';
        }
    }
    else
    {
        $props{'copyCommand'} = "";
    }
    
    #generate the command to execute in console
    $props{"copyReportCommand"} = $copyReportCommand;
    $props{"commandLine"} = createCommandLine(\@args);
    $props{"workingdir"} = $::gWorkingDir;
    
    registerReports();
    
    setProperties(\%props);
    
	}

	########################################################################
	# createCommandLine - creates the command line for the invocation
	# of the program to be executed.
	#
	# Arguments:
	#   -arr: array containing the command name and the arguments entered by 
	#         the user in the UI
	#
	# Returns:
	#   -the command line to be executed by the plugin
	#
	########################################################################
	sub createCommandLine {

		my ($arr) = @_;

		my $commandName = @$arr[0];

		my $command = $commandName;

		shift(@$arr);

		foreach my $elem (@$arr) {
            $command .= " $elem";
		}

		return $command;
		
	}

	########################################################################
	# setProperties - set a group of properties into the Electric Commander
	#
	# Arguments:
	#   -propHash: hash containing the ID and the value of the properties 
	#              to be written into the Electric Commander
	#
	# Returns:
	#   -nothing
	#
	########################################################################
	sub setProperties {

		my ($propHash) = @_;

		# get an EC object
		my $ec = new ElectricCommander();
		$ec->abortOnError(0);

		foreach my $key (keys % $propHash) {
			my $val = $propHash->{$key};
			$ec->setProperty("/myCall/$key", $val);
		}

	}

	########################################################################
	# registerReports - creates a link for registering the generated report
	# in the job step detail
	#
	# Arguments:
	#   -none
	#
	# Returns:
	#   -nothing
	#
	########################################################################
	sub registerReports{
	 
		# get an EC object
		my $ec = new ElectricCommander();
		$ec->abortOnError(0);
	 
		$ec->setProperty("/myJob/artifactsDirectory", "");
		
		#mkdir('artifacts-dir');
		#registerArtifactsDirectory($ec, "$[jobId]", 'artifacts-dir');
		
		my $ext = '';
		
		if($::gReportFile ne ""){
		 
			 if ($::gReportFormat eq 'nicehtml'){
				 $ext = 'html';
			 }elsif($::gReportFormat eq 'text'){
				 $ext = 'txt';
			 }else{
				 $ext = $::gReportFormat;
			 }
			 
			 $ec->setProperty("/myJob/report-urls/PMD Report", 
				   "jobSteps/$[jobStepId]/" . $::gReportFile);

		}

	}

	main();