function newCommit = commit( repo, options )

arguments( Input )
    repo( 1, 1 )matlab.git.GitRepository
    options.Files( 1, : )string{ mustBeNonzeroLengthText }
    options.Message( 1, 1 )string{ mustBeNonzeroLengthText }
end

arguments( Output )
    newCommit( 1, 1 )matlab.git.GitCommit
end

if ~isfield( options, "Message" )
    error( message( "shared_cmlink:git:EmptyCommitMessageNotAllowed" ) );
end

if ~isfield( options, "Files" )
    i_doCommit( repo, options.Message );
else
    i_doCommit( repo, options.Message, options.Files );
end

headCommitId = matlab.internal.git.head( repo.WorkingFolder );
newCommit = matlab.git.GitCommit( repo.WorkingFolder, headCommitId );
end

function i_doCommit( repo, varargin )
matlab.internal.git.refreshStatusCache(  ...
    repo,  ...
    @(  )matlab.internal.git.commit( repo.WorkingFolder, varargin{ : } ) );
end



