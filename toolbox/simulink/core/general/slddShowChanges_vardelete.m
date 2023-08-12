function slddShowChanges_vardelete( filename, var_name, var_key, report_id )






realFilename = urldecode( filename );

errMsg = '';
try 
ddConn = Simulink.dd.open( realFilename );
entry = ddConn.getEntryInfo( str2num( var_key ) );
if isempty( entry ) || ~isequal( entry.Name, var_name )
errMsg = DAStudio.message( 'SLDD:sldd:EntryNotFound' );
else 
ddConn.deleteEntry( str2num( var_key ) );
end 
ddConn.close(  );

catch err
errMsg = err.message;
end 

if ~isempty( errMsg )

if ~isempty( report_id )
c = com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison( report_id );
if ~isempty( c )
c.doErrorDialog( errMsg );
end 
else 
error( errMsg );
end 
end 


if ~isempty( report_id )
c = com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison( report_id );
if ~isempty( c )
c.doRefresh;
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFvWtB8.p.
% Please follow local copyright laws when handling this file.

