function mergeInDesktop( theirs, base, mine, options )



R36
theirs( 1, 1 )comparisons.internal.FileSource
base( 1, 1 )comparisons.internal.FileSource
mine( 1, 1 )comparisons.internal.FileSource
options( 1, 1 ){ mustBeThreeWayOptions } = comparisons.internal.makeThreeWayOptions(  )
end 

app = comparisons.internal.gui.merge( theirs, base, mine, options );
comparisons.internal.appstore.register( app );
end 

function mustBeThreeWayOptions( arg )
mustBeA( arg, 'comparisons.internal.ThreeWayOptions' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSouGTx.p.
% Please follow local copyright laws when handling this file.

