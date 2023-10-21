function pull( repo, credentialOptions )

arguments
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
