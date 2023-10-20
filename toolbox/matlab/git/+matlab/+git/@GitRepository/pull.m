function pull( repo, credentialOptions )




R36
repo( 1, 1 )matlab.git.GitRepository

credentialOptions.Username( 1, 1 )string
credentialOptions.Token( 1, 1 )string
end 

remote = matlab.internal.git.getUpstreamRemote( repo.WorkingFolder );
fetchCredentialOptions = namedargs2cell( credentialOptions );
fetch( repo, fetchCredentialOptions{ : }, Remote = remote );

fetchHeadForMerge = matlab.internal.git.getFetchHeadForMerge( repo.WorkingFolder );
if strlength( fetchHeadForMerge ) ~= 0
merge( repo, fetchHeadForMerge );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1z_2GY.p.
% Please follow local copyright laws when handling this file.

