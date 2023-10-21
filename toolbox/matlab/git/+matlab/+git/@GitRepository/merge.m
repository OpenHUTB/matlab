function merge( repo, committish )

arguments( Input )
    repo( 1, 1 )matlab.git.GitRepository
    committish( 1, : ){ matlab.internal.git.validators.mustBeCommittish }
end

matlab.internal.git.refreshStatusCache( repo,  ...
    @(  )matlab.internal.git.mergeBranch(  ...
    repo.WorkingFolder, matlab.internal.git.getCommitIdentifier( committish ) ) );
end
