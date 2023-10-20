function commits = log( repo, walkOptions )




R36( Input )
repo( 1, 1 )matlab.git.GitRepository

walkOptions.Revisions( 1, : ){ matlab.internal.git.validators.mustBeCommittish }
walkOptions.File( 1, 1 )string{ mustBeNonzeroLengthText }
end 

R36( Output )
commits table
end 

if ~isfield( walkOptions, "Revisions" )
walkOptions.Revisions = string.empty;
else 
walkOptions.Revisions = matlab.internal.git.getCommitIdentifier( walkOptions.Revisions );
end 

logManager = matlab.internal.git.GitLogManager( repo.WorkingFolder );

if isfield( walkOptions, "File" )
revisions = logManager.getCommitsContainingFile( walkOptions.Revisions, walkOptions.File );
else 
revisions = logManager.getCommits( walkOptions.Revisions );
end 

if isempty( revisions )
commits = table.empty;
return ;
end 

commits = revisions2table( logManager, revisions );
end 

function tableOfResults = revisions2table( logManager, revisions )
commitsAsStruct = [  ];
for ii = numel( revisions ): - 1:1
commit = revisions( ii );
commitsAsStruct( ii ).Message = commit.getMessage;
commitsAsStruct( ii ).Branches = logManager.getBranches( commit.getId );
commitsAsStruct( ii ).ID = commit.getId;
commitsAsStruct( ii ).AuthorName = commit.getAuthorName;
commitsAsStruct( ii ).AuthorEmail = commit.getAuthorEmail;
commitsAsStruct( ii ).AuthorDate = commit.getAuthorDate;
commitsAsStruct( ii ).CommitterName = commit.getCommitterName;
commitsAsStruct( ii ).CommitterEmail = commit.getCommitterEmail;
commitsAsStruct( ii ).CommitterDate = commit.getCommitterDate;
end 

varNames = [  ...
"Message", "Branches",  ...
"AuthorName", "AuthorEmail", "AuthorDate",  ...
"CommitterName", "CommitterEmail", "CommitterDate" ];
inputDateFormat = "uuuu-MM-dd HH:mm:ss";

tableOfResults = table(  ...
[ commitsAsStruct.Message ]', { commitsAsStruct.Branches }',  ...
categorical( [ commitsAsStruct.AuthorName ]' ), categorical( [ commitsAsStruct.AuthorEmail ]' ),  ...
datetime( [ commitsAsStruct.AuthorDate ]', InputFormat = inputDateFormat, TimeZone = "UTC" ),  ...
categorical( [ commitsAsStruct.CommitterName ]' ), categorical( [ commitsAsStruct.CommitterEmail ]' ),  ...
datetime( [ commitsAsStruct.CommitterDate ]', InputFormat = inputDateFormat, TimeZone = "UTC" ),  ...
VariableNames = varNames, RowNames = [ commitsAsStruct.ID ]' );

tableOfResults.Properties.DimensionNames{ 1 } = 'ID';
dateFormat = "dd-MMM-uuuu HH:mm:ss Z";
tableOfResults.AuthorDate.Format = dateFormat;
tableOfResults.AuthorDate.TimeZone = "UTC";
tableOfResults.CommitterDate.Format = dateFormat;
tableOfResults.CommitterDate.TimeZone = "UTC";
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpoCSjrZ.p.
% Please follow local copyright laws when handling this file.

