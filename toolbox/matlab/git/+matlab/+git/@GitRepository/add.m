function add( repo, files )

arguments
    repo( 1, 1 )matlab.git.GitRepository
    files( 1, : )string{ matlab.internal.git.validators.mustBeFileOrFolder, mustBeNonempty }
end

matlab.internal.git.refreshStatusCache(  ...
    repo,  ...
    @(  )matlab.internal.git.add( repo.WorkingFolder, files ) );
end
