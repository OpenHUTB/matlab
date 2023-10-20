classdef GitRepository




properties ( GetAccess = public, SetAccess = immutable )
WorkingFolder( 1, 1 )string
GitFolder( 1, 1 )string
CurrentBranch( :, 1 )matlab.git.GitBranch
LastCommit( :, 1 )matlab.git.GitCommit
ModifiedFiles( :, 1 )string
UntrackedFiles( :, 1 )string
IsBare( 1, 1 )logical
IsShallow( 1, 1 )logical
IsDetached( 1, 1 )logical
IsWorktree( 1, 1 )logical
end 

properties ( Hidden, GetAccess = public, SetAccess = immutable )
RepositoryImpl
end 

methods 
function out = get.WorkingFolder( repo )
out = repo.RepositoryImpl.getWorkingFolder(  );
end 

function out = get.GitFolder( repo )
out = repo.RepositoryImpl.getGitFolder(  );
end 

function branch = get.CurrentBranch( repo )
if repo.IsDetached(  )
branch = matlab.git.GitBranch.empty;
return 
end 

try 
name = matlab.internal.git.currentBranch( repo.WorkingFolder );
branch = matlab.git.GitBranch( repo, name );
catch 
branch = matlab.git.GitBranch.empty;
end 
end 

function commit = get.LastCommit( repo )
if ~repo.RepositoryImpl.hasHead(  )
commit = matlab.git.GitCommit.empty;
return 
end 
headCommitId = matlab.internal.git.head( repo.WorkingFolder );
commit = matlab.git.GitCommit( repo, headCommitId );
end 

function out = get.ModifiedFiles( repo )
out = matlab.internal.git.getModifiedFiles( repo.WorkingFolder );
end 

function out = get.UntrackedFiles( repo )
out = matlab.internal.git.getUntrackedFiles( repo.WorkingFolder );
end 

function out = get.IsBare( repo )
out = repo.RepositoryImpl.isBare(  );
end 

function out = get.IsShallow( repo )
out = repo.RepositoryImpl.isShallow(  );
end 

function out = get.IsDetached( repo )
out = repo.RepositoryImpl.isDetached(  );
end 

function out = get.IsWorktree( repo )
out = repo.RepositoryImpl.isWorktree(  );
end 
end 

methods ( Access = public )
function repo = GitRepository( path )
R36
path( 1, 1 )string{ mustBeNonzeroLengthText } = pwd
end 
repo.RepositoryImpl = matlab.internal.git.GitRepository( path );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYv8BOC.p.
% Please follow local copyright laws when handling this file.

