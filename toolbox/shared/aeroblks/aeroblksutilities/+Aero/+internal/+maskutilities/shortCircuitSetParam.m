function shortCircuitSetParam( blk, param, value )

arguments
    blk
end
arguments( Repeating )
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
