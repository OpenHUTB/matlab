function newvhdltype = vhdlvectorportdatatype( complexity, isvector, vhdltype, sltype )





if length( isvector ) == 1 || isvector( 2 ) == 0 || isvector( 1 ) == 1 || isvector( 2 ) == 1
veclen = max( isvector );
if veclen == 0
error( message( 'HDLShared:directemit:zerolenvector' ) );
end 
if strcmp( vhdltype, 'std_logic' )
newvhdltype = vhdlvectorblockdatatype( complexity, isvector, vhdltype, sltype );
else 
prototypedef = sprintf( '  TYPE %-32s IS ARRAY (NATURAL RANGE <>) OF %s;\n',  ...
[ hdlgetparameter( 'vector_prefix' ), sltype ], vhdltype );
vhdlpackageaddtypedef( prototypedef );
newvhdltype = sprintf( '%s%s(0 TO %d)', hdlgetparameter( 'vector_prefix' ), sltype, veclen - 1 );
end 
else 
error( message( 'HDLShared:directemit:matrixunsupported' ) );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpuKKA7A.p.
% Please follow local copyright laws when handling this file.

