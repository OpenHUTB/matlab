classdef GitCommit < matlab.mixin.CustomCompactDisplayProvider




properties ( GetAccess = public, SetAccess = immutable )
Message( 1, 1 )string
ID( 1, 1 )string
AuthorName( 1, 1 )string
AuthorEmail( 1, 1 )string
AuthorDate( 1, 1 )datetime
CommitterName( 1, 1 )string
CommitterEmail( 1, 1 )string
CommitterDate( 1, 1 )datetime
ParentCommits( :, 1 )string
end 

methods ( Access = public )
function obj = GitCommit( repo, id )
R36
repo( 1, 1 )matlab.git.GitRepository
id( 1, 1 )string
end 

c = matlab.internal.git.GitCommitInfo( repo.WorkingFolder, id );
dateFormat = "dd-MMM-uuuu HH:mm:ss Z";
inputDateFormat = "uuuu-MM-dd HH:mm:ss";

obj.Message = c.getMessage(  );
obj.ID = c.getId(  );
obj.AuthorName = c.getAuthorName(  );
obj.AuthorEmail = c.getAuthorEmail(  );
obj.AuthorDate = datetime( c.getAuthorDate(  ), Format = dateFormat, InputFormat = inputDateFormat, TimeZone = "UTC" );
obj.CommitterName = c.getCommitterName(  );
obj.CommitterEmail = c.getCommitterEmail(  );
obj.CommitterDate = datetime( c.getCommitterDate(  ), Format = dateFormat, InputFormat = inputDateFormat, TimeZone = "UTC" );
obj.ParentCommits = c.getParents(  );
end 

function displayRep = compactRepresentationForSingleLine( obj, displayConfig, ~ )
import matlab.display.DimensionsAndClassNameRepresentation
if isempty( obj )
shortID = "";
else 
shortID = extractBefore( [ obj.ID ]', 8 );
end 
displayRep = DimensionsAndClassNameRepresentation( obj, displayConfig, Annotation = shortID );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeR8luq.p.
% Please follow local copyright laws when handling this file.

