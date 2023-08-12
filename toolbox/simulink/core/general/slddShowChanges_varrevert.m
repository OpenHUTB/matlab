function slddShowChanges_varrevert( filename, var_name, var_key, report_id )






realFilename = urldecode( filename );

try 
ddConn = Simulink.dd.open( realFilename );
id = str2num( var_key );
savedInfo = ddConn.getEntryAtRevertPoint( id );

allow_revert = true;
parentName = ddConn.getEntryParentName( id );


if ~isequal( var_name, savedInfo.Name ) && ddConn.entryExists( [ parentName, '.', savedInfo.Name ], false )

existingEntryID = ddConn.getEntryID( [ parentName, '.', savedInfo.Name ] );
if ~isequal( existingEntryID, id )
allow_revert = false;
end 
end 

if ~allow_revert



if isequal( 'Global', parentName )
parentName = 'Design Data';
elseif isequal( 'Other', parentName )
parentName = 'Other Data';
end 
msg = DAStudio.message( 'SLDD:sldd:EntryAlreadyExists', savedInfo.Name, parentName );
showErr( report_id, msg );
else 
ddConn.discardEntryChanges( str2num( var_key ) );
end 

ddConn.close(  );

catch err

showErr( report_id, err.message );
end 


if ~isempty( report_id )
c = com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison( report_id );
if ~isempty( c )
c.doRefresh;
end 
end 

end 

function showErr( report_id, message )
if ~isempty( report_id )
c = com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison( report_id );
if ~isempty( c )
c.doErrorDialog( message );
end 
else 
error( message );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp1hl3qw.p.
% Please follow local copyright laws when handling this file.

