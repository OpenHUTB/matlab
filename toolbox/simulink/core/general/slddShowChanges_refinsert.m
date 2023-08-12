function slddShowChanges_refinsert( filename, ref_name, ref_key, report_id )






realFilename = urldecode( filename );

try 
ddConn = Simulink.dd.open( realFilename );
ddConn.addReference( ref_name );
ddConn.close(  );

catch err

if ~isempty( report_id )
c = com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison( report_id );
if ~isempty( c )
c.doErrorDialog( err.message );
end 
else 
error( err.message );
end 
end 


if ~isempty( report_id )
c = com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison( report_id );
if ~isempty( c )
c.doRefresh;
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYNgJYT.p.
% Please follow local copyright laws when handling this file.

