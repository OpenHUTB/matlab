function mustBeCommittish( committish )
mustBeA( committish, [  ...
    "char",  ...
    "string",  ...
    "matlab.git.GitCommit",  ...
    "matlab.git.GitBranch",  ...
    "cell"
    ] );

if isstring( committish ) || ischar( committish )
    mustBeNonzeroLengthText( committish );
elseif iscell( committish )
    cellfun( @matlab.internal.git.validators.mustBeCommittish, committish );
else
    mustBeScalarOrEmpty( committish );
end
end
