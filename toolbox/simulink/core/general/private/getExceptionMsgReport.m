function report = getExceptionMsgReport( ex )


report = ex.message;

if ~isempty( ex.cause )
report = [ report, sprintf( '\n' ), DAStudio.message( 'MATLAB:MException:CausedBy' ) ];
report = buildReport( ex, report, 1 );
end 


function report = buildReport( ex, report, level )

causes = ex.cause;
for i = 1:length( causes )
report = [ report, repmat( ' ', [ 1, level * 4 ] ), causes{ i }.message, sprintf( '\n' ) ];%#ok
report = buildReport( causes{ i }, report, level + 1 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyd_Ucs.p.
% Please follow local copyright laws when handling this file.

