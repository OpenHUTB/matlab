function propNames = properties( className, passthroughArgs )
arguments
    className( 1, 1 )string
end
arguments( Repeating )
    passthroughArgs
end

propNames = getPropsAndMethods( className, 'properties', passthroughArgs{ : } );
end


