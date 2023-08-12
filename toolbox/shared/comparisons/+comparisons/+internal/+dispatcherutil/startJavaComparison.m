function app = startJavaComparison( jDefinition, fileSources )



R36
jDefinition( 1, 1 )
end 

R36( Repeating )
fileSources( 1, 1 ){ mustBeA( fileSources, 'comparisons.internal.FileSource' ) }
end 

app = comparisons.internal.JavaApp( fileSources{ : } );

requestClose = app.getRequestClose(  );
onComparisonClose = com.mathworks.comparisons.main.MatlabCallback( requestClose );

com.mathworks.comparisons.main.ComparisonUtilities ...
.startComparisonNoMatlabDispatcher( jDefinition, onComparisonClose );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmps0xQR_.p.
% Please follow local copyright laws when handling this file.

