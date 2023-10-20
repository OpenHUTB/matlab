classdef GitBranch < matlab.mixin.CustomCompactDisplayProvider




properties ( GetAccess = public, SetAccess = immutable )
Name( 1, 1 )string
LastCommit( 1, : )matlab.git.GitCommit
end 

properties ( Hidden, GetAccess = public, SetAccess = immutable )
RepoLocation
end 

methods ( Access = public )
function obj = GitBranch( repo, name )
R36
repo( 1, 1 )matlab.git.GitRepository
name( 1, 1 )string
end 

obj.Name = name;
branchCommitID = matlab.internal.git.getCommitIdForBranch( repo.WorkingFolder, name );
obj.LastCommit = matlab.git.GitCommit( repo, branchCommitID );
obj.RepoLocation = repo.WorkingFolder;
end 

function displayRep = compactRepresentationForSingleLine( branch, displayConfig, ~ )
import matlab.display.DimensionsAndClassNameRepresentation
if isempty( branch )
name = "";
else 
name = branch.Name;
end 
displayRep = DimensionsAndClassNameRepresentation( branch, displayConfig, Annotation = name );
end 

function commits = log( branch, varargin )
commits = log( gitrepo( branch.RepoLocation ), "Revisions", branch.LastCommit.ID, varargin{ : } );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBBTti8.p.
% Please follow local copyright laws when handling this file.

