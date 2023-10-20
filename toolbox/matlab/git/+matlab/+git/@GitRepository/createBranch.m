function newBranch = createBranch( repo, branchName, options )




R36( Input )
repo( 1, 1 )matlab.git.GitRepository
branchName( 1, 1 )string

options.StartPoint( 1, : ){ mustBeA( options.StartPoint, [ "char", "string", "matlab.git.GitBranch" ] ) } = "HEAD"
end 

R36( Output )
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdIwgyT.p.
% Please follow local copyright laws when handling this file.

