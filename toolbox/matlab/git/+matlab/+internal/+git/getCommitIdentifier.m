function id = getCommitIdentifier( committish )

arguments( Input )
    committish( 1, : ){ matlab.internal.git.validators.mustBeCommittish }
end

arguments( Output )
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

