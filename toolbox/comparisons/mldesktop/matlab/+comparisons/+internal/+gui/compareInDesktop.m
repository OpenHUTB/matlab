function compareInDesktop( first, second, options )

arguments
    first( 1, 1 )comparisons.internal.FileSource
    second( 1, 1 )comparisons.internal.FileSource
    options( 1, 1 ){ mustBeTwoWayOptions } = comparisons.internal.makeTwoWayOptions(  )
end

app = comparisons.internal.gui.compare( first, second, options );
comparisons.internal.appstore.register( app );
end

function mustBeTwoWayOptions( arg )
mustBeA( arg, 'comparisons.internal.TwoWayOptions' );
end


