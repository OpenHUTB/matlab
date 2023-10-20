function switchedBranch = switchBranch( repo, branch )




R36( Input )
repo( 1, 1 )matlab.git.GitRepository
branch( 1, : ){ mustBeA( branch, [ "char", "string", "matlab.git.GitBranch" ] ) }
end 

R36( Output )
switchedBranch( 1, 1 )matlab.git.GitBranch
end 

if isstring( branch ) || ischar( branch )
branch = matlab.git.GitBranch( repo, branch );
end 

matlab.internal.git.refreshStatusCache(  ...
repo,  ...
@(  )matlab.internal.git.switchBranch( repo.WorkingFolder, branch.Name ) );

switchedBranch = matlab.git.GitBranch( repo, branch.Name );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBcFQue.p.
% Please follow local copyright laws when handling this file.

