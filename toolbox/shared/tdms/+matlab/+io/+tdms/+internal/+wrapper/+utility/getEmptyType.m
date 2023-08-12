function type = getEmptyType( strType )



R36
strType( 1, 1 )string
end 

switch strType
case "int8"
type = int8.empty;
case "uint8"
type = uint8.empty;
case "int16"
type = int16.empty;
case "uint16"
type = uint16.empty;
case "int32"
type = int32.empty;
case "uint32"
type = uint32.empty;
case "int64"
type = int64.empty;
case "uint64"
type = uint64.empty;
case "single"
type = single.empty;
case "double"
type = double.empty;
case "string"
type = string.empty;
case "logical"
type = logical.empty;
case "datetime"
type = datetime.empty;
otherwise 
assert( false, "invalid type" );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp2hHuwx.p.
% Please follow local copyright laws when handling this file.

