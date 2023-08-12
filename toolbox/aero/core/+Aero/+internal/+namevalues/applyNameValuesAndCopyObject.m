function objc = applyNameValuesAndCopyObject( obj, NameValues, n )
























R36
obj( 1, 1 )
NameValues( 1, 1 )struct
n cell
end 

n = cell2mat( n );
if isempty( n )
n = 1;
end 

obj = Aero.internal.namevalues.applyNameValues( obj, NameValues );


objc = repmat( obj, n );


if isa( obj, "handle" )
for i = 1:numel( objc )
objc( i ) = copy( obj );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqvgHMY.p.
% Please follow local copyright laws when handling this file.

