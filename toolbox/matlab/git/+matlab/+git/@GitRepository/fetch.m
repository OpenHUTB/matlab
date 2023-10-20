function fetch( repo, options, credentialOptions )




R36
repo( 1, 1 )matlab.git.GitRepository

options.Remote( 1, : ){ mustBeA( options.Remote, "string" ) }

credentialOptions.Username( 1, 1 )string
credentialOptions.Token( 1, 1 )string
end 

if xor( isfield( credentialOptions, "Username" ), isfield( credentialOptions, "Token" ) )
error( message( "shared_cmlink:git:SpecifyUsernameAndTokenNVPs" ) );
end 

if isfield( options, "Remote" )
if isfield( credentialOptions, "Username" )
matlab.internal.git.fetch( repo.WorkingFolder, options.Remote,  ...
credentialOptions.Username, credentialOptions.Token );
else 
matlab.internal.git.fetch( repo.WorkingFolder, options.Remote );
end 
else 
if isfield( credentialOptions, "Username" )
matlab.internal.git.fetchAll( repo.WorkingFolder,  ...
credentialOptions.Username, credentialOptions.Token );
else 
matlab.internal.git.fetchAll( repo.WorkingFolder );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppbDNMr.p.
% Please follow local copyright laws when handling this file.

