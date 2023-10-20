function push( repo, options, credentialOptions )




R36
repo( 1, 1 )matlab.git.GitRepository

options.Remote( 1, : ){ mustBeA( options.Remote, "string" ) }
options.RemoteBranch( 1, 1 ){ mustBeA( options.RemoteBranch, "string" ) }

credentialOptions.Username( 1, 1 )string
credentialOptions.Token( 1, 1 )string
end 

if ~isfield( options, "Remote" ) && isfield( options, "RemoteBranch" )
error( message( "shared_cmlink:git:SpecifyRemoteAndRemoteBranchNVPs" ) );
end 

if xor( isfield( credentialOptions, "Username" ), isfield( credentialOptions, "Token" ) )
error( message( "shared_cmlink:git:SpecifyUsernameAndTokenNVPs" ) );
end 

if isfield( options, "Remote" )
if ~isfield( options, "RemoteBranch" )
options.RemoteBranch = repo.CurrentBranch.Name;
end 

if isfield( credentialOptions, "Username" )
matlab.internal.git.pushToRemote(  ...
repo.WorkingFolder, options.Remote, options.RemoteBranch,  ...
credentialOptions.Username, credentialOptions.Token );
else 
matlab.internal.git.pushToRemote(  ...
repo.WorkingFolder, options.Remote, options.RemoteBranch );
end 
else 
if isfield( credentialOptions, "Username" )
matlab.internal.git.push(  ...
repo.WorkingFolder,  ...
credentialOptions.Username, credentialOptions.Token );
else 
matlab.internal.git.push( repo.WorkingFolder );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzAvjEA.p.
% Please follow local copyright laws when handling this file.

