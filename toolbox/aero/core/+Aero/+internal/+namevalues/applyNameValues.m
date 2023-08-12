function obj = applyNameValues( obj, NameValues )




















R36
obj( 1, 1 )
NameValues( 1, 1 )struct
end 

for f = string( fields( NameValues ) ).'
obj.( f ) = NameValues.( f );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpRNJbbf.p.
% Please follow local copyright laws when handling this file.

