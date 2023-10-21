function repo = gitclone( url, folder, options, credentialOptions )

arguments( Input )
    url( 1, 1 )string
    folder( 1, 1 )string = fullfile( pwd, i_getRepositoryName( url ) )

    options.depth( 1, 1 ){ mustBeNonnegative, mustBeInteger } = 0
    options.recursesubmodules( 1, 1 )logical = true

    credentialOptions.username( 1, 1 )string
    credentialOptions.token( 1, 1 )string
end

arguments( Output )
    repo( 1, 1 )matlab.git.GitRepository
end

if xor( isfield( credentialOptions, "username" ), isfield( credentialOptions, "token" ) )
    error( message( "shared_cmlink:git:SpecifyUsernameAndTokenNVPs" ) );
end

if isfield( credentialOptions, "username" )
    matlab.internal.git.clone( url, folder,  ...
        options.depth, options.recursesubmodules,  ...
        credentialOptions.username, credentialOptions.token );
else
    matlab.internal.git.clone( url, folder,  ...
        options.depth, options.recursesubmodules );
end

repo = gitrepo( folder );
end


function repositoryName = i_getRepositoryName( url )
url = strtrim( url );
url = strip( url, '/' );
url = erase( url, ".git" + lineBoundary( "end" ) );
components = strsplit( url, [ "\", "/" ] );
repositoryName = components{ end  };
end


