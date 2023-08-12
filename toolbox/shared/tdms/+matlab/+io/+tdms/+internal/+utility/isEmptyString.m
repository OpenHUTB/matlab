function isEmpty = isEmptyString( str )



R36
str string
end 
isEmpty = all( isempty( str ) | ismissing( str ) | str == "" );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpEKegh2.p.
% Please follow local copyright laws when handling this file.

