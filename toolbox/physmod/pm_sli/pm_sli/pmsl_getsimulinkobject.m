function obj = pmsl_getsimulinkobject( block )
















if isempty( block )
obj = [  ];

elseif iscell( block )
obj = block( : );


idx = cellfun( 'isclass', obj, 'char' );
if any( idx )
if isscalar( find( idx ) )
obj( idx ) = { get_param( block( idx ), 'Object' ) };
else 
obj( idx ) = get_param( block( idx ), 'Object' );
end 
end 


idx = cellfun( 'isclass', obj, 'double' );
if any( idx )
if isscalar( find( idx ) )
obj( idx ) = { get_param( [ block{ idx } ], 'Object' ) };
else 
obj( idx ) = get_param( [ block{ idx } ], 'Object' );
end 
end 

else 


if isa( block( 1 ), 'Simulink.Object' )
obj = block;
else 
obj = get_param( block, 'Object' );
end 
end 


if iscell( obj )
obj = [ obj{ : } ];
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpWqn6XN.p.
% Please follow local copyright laws when handling this file.

