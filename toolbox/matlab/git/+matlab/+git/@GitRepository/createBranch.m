function newBranch = createBranch( repo, branchName, options )

arguments( Input )
    repo( 1, 1 )matlab.git.GitRepository
    branchName( 1, 1 )string

    options.StartPoint( 1, : ){ mustBeA( options.StartPoint, [ "char", "string", "matlab.git.GitBranch" ] ) } = "HEAD"
end

arguments( Output )
    newBranch( 1, 1 )matlab.git.GitBranch
end

if isa( options.StartPoint, "matlab.git.GitBranch" )
    options.StartPoint = options.StartPoint.Name;
end

matlab.internal.git.refreshStatusCache(  ...
    repo,  ...
    @(  )matlab.internal.git.createBranch( repo.WorkingFolder, branchName, options.StartPoint ) );

newBranch = matlab.git.GitBranch( repo, branchName );
end


