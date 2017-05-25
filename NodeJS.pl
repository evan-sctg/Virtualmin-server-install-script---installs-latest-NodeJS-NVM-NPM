##
##
##Author: Evan Garcia
##
##

# script_NodeJS_desc()
sub script_NodeJS_desc
{
return "NVM - node JS";
}

sub script_NodeJS_uses
{
return ( "php" );
}

sub script_NodeJS_longdesc
{
return "Installs NodeJS with NVM For Virtual Server";
}

# script_NodeJS_versions()
sub script_NodeJS_versions
{
return ( "Latest" );
}

sub script_NodeJS_category
{
return "Framework";
}

sub script_NodeJS_php_vers
{
local ($d, $ver) = @_;
if ($ver >= 3.2) {
	return ( 5 );
	}
else {
	return ( 4, 5 );
	}
}

sub script_NodeJS_php_modules
{
return ();
}

sub script_NodeJS_php_optional_modules
{
return ("curl");
}

sub script_NodeJS_dbs
{
return ("mysql");
}

# script_NodeJS_depends(&domain, version)
sub script_NodeJS_depends
{
local ($d, $ver) = @_;
local @rv;

# Check for PHP 5.6+
local $phpv = &get_php_version(5, $d);
if (!$phpv) {
	push(@rv, "Could not work out exact PHP version");
	}
elsif ($phpv < 5.2) { 
	push(@rv, "NodeJS requires PHP version 5.3 or later");
	}

return @rv;
}

# script_NodeJS_params(&domain, version, &upgrade-info)
# Returns HTML for table rows for options for installing NodeJS
sub script_NodeJS_params
{
local ($d, $ver, $upgrade) = @_;
local $rv;
local $hdir = &public_html_dir($d, 1);
if ($upgrade) {
	# Options are fixed when upgrading
	local ($dbtype, $dbname) = split(/_/, $upgrade->{'opts'}->{'db'}, 2);
	local $dir = $upgrade->{'opts'}->{'dir'};
	$dir =~ s/^$d->{'home'}\///;
	$rv .= &ui_table_row("Install directory", $dir);
	}
else {
	# Show editable install options
	local @dbs = &domain_databases($d, [ "mysql" ]);
	}
return $rv;
}

# script_NodeJS_parse(&domain, version, &in, &upgrade-info)
# Returns either a hash ref of parsed options, or an error string
sub script_NodeJS_parse
{
local ($d, $ver, $in, $upgrade) = @_;
if ($upgrade) {
	# Options are always the same
	return $upgrade->{'opts'};
	}
else {
	local $hdir = &public_html_dir($d, 0);
	local $dir = $hdir;
	local ($newdb) = ($in->{'db'} =~ s/^\*//);
	return { 'db' => $in->{'db'},
		 'newdb' => $newdb,
		 'dir' => $dir,
		 'path' => "/", };
	}
}

# script_NodeJS_check(&domain, version, &opts, &upgrade-info)
# Returns an error message if a required option is missing or invalid
sub script_NodeJS_check
{
local ($d, $ver, $opts, $upgrade) = @_;
if (-r "$d->{'home'}/.nvm") {
	return "NodeJS appears to be already installed in the selected directory";
	}
	
return undef;
}

# script_NodeJS_files(&domain, version, &opts, &upgrade-info)
# Returns a list of files needed by NodeJS, each of which is a hash ref
# containing a name, filename and URL
sub script_NodeJS_files
{
local ($d, $ver, $opts, $upgrade) = @_;
return undef;
}

sub script_NodeJS_commands
{
return ("unzip");
}

# script_NodeJS_install(&domain, version, &opts, &files, &upgrade-info)
# Actually installs NodeJS, and returns either 1 and an informational
# message, or 0 and an error
sub script_NodeJS_install
{
local ($d, $version, $opts, $files, $upgrade) = @_;
local ($out, $ex);

	   local $url = &script_path_url($d, $opts);
	   
	   
	   

# Extract tar file to temp dir and copy to target
local $verdir = "NodeJS";

	   ##Changing shell to /bin/bash
	$shell_out = <<`SHELL`;
chsh -s /bin/bash $d->{'user'}
SHELL



if ($shell_out !~ /Changing shell for/) {
return (0, "Changing shell to /bin/bash failed: ".
		   "<pre>".&html_escape($shell_out)."</pre>");
	   }
	   



	   ##install NVM node version manager
	   local $icmd = "source ~/.bash_profile && curl https://raw.githubusercontent.com/creationix/nvm/v0.13.1/install.sh | bash";
local $out = &run_as_domain_user($d, $icmd);
	   if ($?) {
return (0, "install NVM failed: ".
		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
	   }		
		   
		
		##install nodejs and NPM  node package manager
   local $icmd = "source ~/.bash_profile && nvm install v6.10.3";
local $out = &run_as_domain_user($d, $icmd);
	   if ($?) {
return (0, "install nodejs and NPM failed: ".
		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
	   }	   
	   
	   ##append sourcing for NPM
	   local $SOURCE_STR="\nexport PATH=\$NVM_DIR/current/bin:\$PATH";	   
	   open(my $fd, ">>$d->{'home'}/.bash_profile");
		print $fd "$SOURCE_STR";
	
	   


# Return a URL for the user
local $userurl = &script_path_url($d, $opts);
local $rp = $opts->{'dir'};
$rp =~ s/^$d->{'home'}\///;
return (1, "NodeJS installation complete. It can be accessed at <a target=_blank href='$url'>$url</a>.", "Under $rp", $userurl);
}

# script_NodeJS_uninstall(&domain, version, &opts)
# Un-installs a NodeJS installation, by deleting the directory and database.
# Returns 1 on success and a message, or 0 on failure and an error
sub script_NodeJS_uninstall
{
local ($d, $version, $opts) = @_;


	   # remove any references to nvm prom bash_profile
	   local $Bprofile = "$d->{'home'}/.bash_profile";
if (-r $Bprofile) {
	local $lref = &read_file_lines_as_domain_user($d, $Bprofile);
	local $l;
	foreach $l (@$lref) {
		if ($l =~ /NVM_DIR/) {
			$l = "";
			}
		}
	&flush_file_lines_as_domain_user($d, $Bprofile);
	}
	
	

##remove nvm and npm and nodejs
local $icmd = "rm -rf $d->{'home'}/.npm && rm -rf $d->{'home'}/.nvm && rm -rf $d->{'home'}/.bower";
local $out = &run_as_domain_user($d, $icmd);
if ($?) {
return (0, "remove nvm and npm failed: ".
		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
	   }



return (1, "NodeJS deleted.");
}

# script_NodeJS_realversion(&domain, &opts)
# Returns the real version number of some script install, or undef if unknown
sub script_NodeJS_realversion
{
local ($d, $opts, $sinfo) = @_;
return undef;
}

# script_NodeJS_latest(version)
# Returns a URL and regular expression or callback func to get the version
sub script_NodeJS_latest
{
return undef;
}

sub script_NodeJS_site
{
return 'https://NodeJS.com/';
}

1;