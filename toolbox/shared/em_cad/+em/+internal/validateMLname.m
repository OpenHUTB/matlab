function validateMLname( Name, Description )





R36
Name
Description( 1, : )char = 'name'
end 


if ~isvarname( Name )



validateattributes( Name, { 'char' }, { 'row' }, '', Description );





error( message( 'antenna:antennaerrors:ValidateMLNameNotAVarName', Description, Name ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpKY331r.p.
% Please follow local copyright laws when handling this file.

