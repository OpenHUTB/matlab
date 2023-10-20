function id = getCommitIdentifier( committish )

R36( Input )
committish( 1, : ){ matlab.internal.git.validators.mustBeCommittish }
end 

R36( Output )
id( 1, : )string
end 

if isa( committish, 'matlab.git.GitCommit' )
id = committish.ID;
elseif isa( committish, 'matlab.git.GitBranch' )
id = committish.Name;
elseif iscell( committish )
id = cellfun( @matlab.internal.git.getCommitIdentifier, committish );
else 
id = committish;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_Bg2zj.p.
% Please follow local copyright laws when handling this file.

