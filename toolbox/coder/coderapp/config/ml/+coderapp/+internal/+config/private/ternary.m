function out = ternary( test, first, second )
R36
test( 1, 1 ){ mustBeNumericOrLogical( test ) }
first{ mustBeTextScalar( first ) }
second{ mustBeTextScalar( second ) }
end 



if test
out = evalin( 'caller', first );
else 
out = evalin( 'caller', second );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUNSqbc.p.
% Please follow local copyright laws when handling this file.

