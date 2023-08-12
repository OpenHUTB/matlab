function result = vhdlisstdlogicvector( signal )








result = [  ];

for in = signal
vector = hdlsignalvector( in );
vtype = hdlsignalvtype( in );
sltype = hdlsignalsltype( in );
if isempty( sltype )
size = 1;
bp = 0;
signed = 0;
else 
[ size, bp, signed ] = hdlwordsize( sltype );
end 

if size == 0
result = [ result, false ];
elseif size == 1
result = [ result, false ];
elseif length( vtype ) > 16 && strcmp( vtype( 1:16 ), 'std_logic_vector' )
result = [ result, true ];
elseif vector == 0
result = [ result, false ];
elseif strcmp( vtype,  ...
[ hdlgetparameter( 'vector_prefix' ), sltype, '(0 TO ', num2str( max( vector ) - 1 ), ')' ] )
result = [ result, true ];
else 
result = [ result, false ];
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpWUWf0r.p.
% Please follow local copyright laws when handling this file.

