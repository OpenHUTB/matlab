function app = startJavaComparison( jDefinition, fileSources )

arguments
    jDefinition( 1, 1 )
end

arguments( Repeating )
    fileSources( 1, 1 ){ mustBeA( fileSources, 'comparisons.internal.FileSource' ) }
end

app = comparisons.internal.JavaApp( fileSources{ : } );

requestClose = app.getRequestClose(  );
onComparisonClose = com.mathworks.comparisons.main.MatlabCallback( requestClose );

com.mathworks.comparisons.main.ComparisonUtilities ...
    .startComparisonNoMatlabDispatcher( jDefinition, onComparisonClose );
end
