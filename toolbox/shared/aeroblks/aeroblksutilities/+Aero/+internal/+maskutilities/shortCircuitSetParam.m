function shortCircuitSetParam( blk, param, value )












R36
blk
end 
R36( Repeating )
param( 1, 1 )string
value( 1, 1 )string
end 

idx = cellfun( @( p, v )get_param( blk, p ) == v, param, value );

param( idx ) = [  ];
value( idx ) = [  ];

if ~isempty( param )
p = [ param;value ];
set_param( blk, p{ : } );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIF8dwJ.p.
% Please follow local copyright laws when handling this file.

