function [ first, second, options ] = sanitizeFiles( first, second, options, sanitizeImpl )
% sanitize: 给...消毒
arguments
    first( 1, 1 )comparisons.internal.FileSource
    second( 1, 1 )comparisons.internal.FileSource
    options( 1, 1 )
    sanitizeImpl( 1, 1 )function_handle
end

    function [ source, sanitized ] = sanitize( source )
        startPath = source.Path;
        source = sanitizeImpl( source );
        sanitized = ~strcmp( startPath, source.Path );
    end

[ first, firstSanitized ] = sanitize( first );
[ second, secondSanitized ] = sanitize( second );

if ~firstSanitized && ~secondSanitized

    return ;
end

isJavaWorkflow = ~isa( options, 'comparisons.internal.TwoWayOptions' );
if isJavaWorkflow
    options = updateOptionsForJavaWorkflow( first, second, options );
    return ;
end

if ~comparisons.internal.supportsTempFiles( options )
    options = options.clone(  );
    options.MergeConfig = comparisons.internal.merge.DisableMerge(  );
end
end

function options = updateOptionsForJavaWorkflow( first, second, options )


params = options.ComparisonDefinition.getComparisonData(  ).getComparisonParameters(  );
s1 = com.mathworks.comparisons.source.impl.LocalFileSource( java.io.File( first.Path ), first.Path );
s2 = com.mathworks.comparisons.source.impl.LocalFileSource( java.io.File( second.Path ), second.Path );
sel = com.mathworks.comparisons.selection.ComparisonSelection( s1, s2 );
sel.setComparisonType(  ...
    comparisons.internal.dispatcherutil.getJComparisonType( options.Type ) );

builder = com.mathworks.comparisons.compare.ComparisonDefinitionBuilder(  );
builder.addComparisonParameters( params );
builder.addComparisonSources( sel.getComparisonSources(  ) );
builder.setAutoTypeSelection( false );
builder.setComparisonType( sel.getComparisonType(  ) );

if ~comparisons.internal.supportsTempFiles( options.twoWayOptions )


    options.twoWayOptions = options.twoWayOptions.clone(  );
    options.twoWayOptions.MergeConfig = comparisons.internal.merge.DisableMerge(  );
    builder.addComparisonParameter( com.mathworks.comparisons.param.parameter ...
        .ComparisonParameterAllowMerging.getInstance(  ), java.lang.Boolean( false ) );
end

options.ComparisonDefinition = builder.build(  );
end


