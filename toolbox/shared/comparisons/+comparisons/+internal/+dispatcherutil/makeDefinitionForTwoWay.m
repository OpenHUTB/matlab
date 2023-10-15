function definition = makeDefinitionForTwoWay( first, second, options )

arguments
    first{ mustBeTextScalar }
    second{ mustBeTextScalar }
    options{ mustBeA( options, 'comparisons.internal.TwoWayOptions' ) }
end

import comparisons.internal.merge.*
if isa( options.MergeConfig, class( ShowDialog.empty(  ) ) )
    definition = makeShowDialogDefinition( first, second, options );
elseif isa( options.MergeConfig, class( DisableMerge.empty(  ) ) )
    definition = makeDisableMergeDefinition( first, second, options );
elseif isa( options.MergeConfig, class( MergeIntoTarget.empty(  ) ) )
    definition = makeMergeIntoTargetDefinition( first, second, options );
else
    throwUnexpectedConfigError( class( options.MergeConfig ) );
end
end

function definition = makeShowDialogDefinition( first, second, options )
builder = setUpBuilderForBasicTwoWay( first, second, options );
definition = builder.build(  );
end

function definition = makeDisableMergeDefinition( first, second, options )
builder = setUpBuilderForBasicTwoWay( first, second, options );

import com.mathworks.comparisons.param.parameter.ComparisonParameterAllowMerging
builder.addComparisonParameter(  ...
    ComparisonParameterAllowMerging.getInstance(  ), java.lang.Boolean( false ) );

definition = builder.build(  );
end

function definition = makeMergeIntoTargetDefinition( first, second, options )
builder = comparisons.internal.dispatcherutil.MergeIntoTargetDefinitionBuilder(  );

builder.setTheirs( first );
builder.setMine( second );
builder.setType( options.Type );
builder.setConfig( options.MergeConfig );

definition = builder.build(  );
end

function builder = setUpBuilderForBasicTwoWay( first, second, options )
import com.mathworks.comparisons.source.impl.LocalFileSource %#ok<*JAPIMATHWORKS>
import com.mathworks.comparisons.selection.ComparisonSelection
import com.mathworks.comparisons.compare.ComparisonDefinitionBuilder

s1 = LocalFileSource( java.io.File( first ), first );
s2 = LocalFileSource( java.io.File( second ), second );
sel = ComparisonSelection( s1, s2 );
sel.setComparisonType(  ...
    comparisons.internal.dispatcherutil.getJComparisonType( options.Type ) );

builder = ComparisonDefinitionBuilder(  );
builder.addComparisonParameters( sel );
builder.addComparisonSources( sel.getComparisonSources(  ) );
builder.setAutoTypeSelection( false );
builder.setComparisonType( sel.getComparisonType(  ) );
end

function throwUnexpectedConfigError( configName )
error( 'MakeDefinitionForTwoWay:UnexpectedConfig', [ 'Unexpected options.MergeConfig: ', configName ] );
end

