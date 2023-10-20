function merge( repo, committish )

R36( Input )
repo( 1, 1 )matlab.git.GitRepository
committish( 1, : ){ matlab.internal.git.validators.mustBeCommittish }
end 

matlab.internal.git.refreshStatusCache( repo,  ...
@(  )matlab.internal.git.mergeBranch(  ...
repo.WorkingFolder, matlab.internal.git.getCommitIdentifier( committish ) ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpufg_dU.p.
% Please follow local copyright laws when handling this file.

