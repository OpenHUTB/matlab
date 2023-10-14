function out = ternary( test, first, second )
arguments
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


