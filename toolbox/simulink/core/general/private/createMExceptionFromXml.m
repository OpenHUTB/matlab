function myException = createMExceptionFromXml( xmlString, varargin )









myException = MException( '', '' );
xmlString = regexp( xmlString,  ...
'(?=<diag_root\>)[\S\s]*?(?<=/diag_root>)', 'match' );
if ~isempty( xmlString )
myException = slsvInternal( 'slsvCreateMExceptionFromXml', xmlString{ 1 } );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpjtaRWn.p.
% Please follow local copyright laws when handling this file.

