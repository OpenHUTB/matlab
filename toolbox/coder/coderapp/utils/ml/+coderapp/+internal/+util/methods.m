function methodNames = methods( className, passthroughArgs )
arguments
    className( 1, 1 )string
end
arguments( Repeating )
    passthroughArgs
end

methodNames = getPropsAndMethods( className, 'methods', passthroughArgs{ : } );
end


