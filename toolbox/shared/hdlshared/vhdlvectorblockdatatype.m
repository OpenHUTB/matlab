function newvhdltype = vhdlvectorblockdatatype( ~, isvector, vhdltype, sltype )



if length( isvector ) == 1 || isvector( 2 ) == 0 || isvector( 1 ) == 1 || isvector( 2 ) == 1
veclen = max( isvector );
switch vhdltype
case { 'bit' }


newvhdltype = sprintf( 'bit_vector(0 TO %d)', veclen - 1 );
case { 'std_logic' }


newvhdltype = sprintf( 'std_logic_vector(0 TO %d)', veclen - 1 );
case { 'std_ulogic' }


newvhdltype = sprintf( 'std_ulogic_vector(0 TO %d)', veclen - 1 );
case { 'real' }
prototypedef = sprintf( '  TYPE %-32s IS ARRAY (NATURAL RANGE <>) OF %s;\n',  ...
[ hdlgetparameter( 'vector_prefix' ), sltype ], vhdltype );
newvhdltype = sprintf( '%s%s(0 TO %d)',  ...
hdlgetparameter( 'vector_prefix' ), sltype, veclen - 1 );
vhdlpackageaddtypedef( prototypedef );
otherwise 
[ ~, ~, token ] = regexp( vhdltype, '\((\d*) DOWNTO' );
sigwidth = num2str( str2double( vhdltype( token{ 1 }( 1 ):token{ 1 }( 2 ) ) ) + 1 );
if strcmp( vhdltype( 1:4 ), 'sign' )
prototypedef = sprintf( '  TYPE %-32s IS ARRAY (NATURAL RANGE <>) OF %s;\n',  ...
[ hdlgetparameter( 'vector_prefix' ), 'signed', sigwidth ], vhdltype );
newvhdltype = sprintf( '%s%s%s(0 TO %d)',  ...
hdlgetparameter( 'vector_prefix' ), 'signed', sigwidth, veclen - 1 );
else 
prototypedef = sprintf( '  TYPE %-32s IS ARRAY (NATURAL RANGE <>) OF %s;\n',  ...
[ hdlgetparameter( 'vector_prefix' ), 'unsigned', sigwidth ], vhdltype );
newvhdltype = sprintf( '%s%s%s(0 TO %d)',  ...
hdlgetparameter( 'vector_prefix' ), 'unsigned', sigwidth, veclen - 1 );
end 
vhdlpackageaddtypedef( prototypedef );
end 
else 
newvhdltype = [ 'VHDL vtype array of ', vhdltype ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBMsQa5.p.
% Please follow local copyright laws when handling this file.

