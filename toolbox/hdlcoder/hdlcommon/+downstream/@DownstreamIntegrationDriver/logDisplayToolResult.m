function result = logDisplayToolResult( obj, status, result, taskName, fileName, linkOnlyMsg, validateCell )












if nargin < 7
validateCell = {  };
end 

if nargin < 6
linkOnlyMsg = false;
end 


hDI = obj;


if status

msg = message( 'hdlcommon:workflow:WorkflowStagePass', taskName );
else 

msg = message( 'hdlcommon:workflow:WorkflowStageError', taskName );
end 





file = hDI.getToolLogFileName( fileName );
[ link, result ] = hdllog( msg, result, file, linkOnlyMsg );



resultStrT = result;
if ( ~isempty( obj.hToolDriver.hTool.cmd_logRegExp ) )
allLines = regexp( resultStrT, '([^\n]*)', 'match' );
matchingLines = regexp( allLines, obj.hToolDriver.hTool.cmd_logRegExp, 'match' );
resultStrT = '';
for i = 1:numel( matchingLines )
tstring = strjoin( matchingLines{ i } );
if ( ~isempty( tstring ) )
resultStrT = sprintf( '%s%s\n', resultStrT, tstring );
end 
end 
end 
result = resultStrT;








if hDI.cmdDisplay
hdldisp( link );


downstream.tool.displayValidateCell( validateCell );


if status
hdldisp( msg );
else 
error( msg );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpaxzcG6.p.
% Please follow local copyright laws when handling this file.

