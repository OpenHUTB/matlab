function options = makeThreeWayOptions( args )

arguments
    args.Debug( 1, 1 ){ mustBeNumericOrLogical } = false
    args.OpenDevTools( 1, 1 ){ mustBeNumericOrLogical } = false
    args.DebugPort( 1, 1 ){ mustBeNumeric } = 0
    args.MergeConfig{ mustBeValidThreeWayMergeConfig, mustBeNonempty } = comparisons.internal.merge.ShowDialog(  )
    args.Type{ mustBeTextScalar } = ""
end
options = comparisons.internal.ThreeWayOptions(  );

propStrs = string( properties( options ) );
for propStr = propStrs.'
    options.( propStr ) = args.( propStr );
end
end

function mustBeValidThreeWayMergeConfig( arg )
validConfigs = [ "MergeIntoTarget", "SCMConflicts", "ShowDialog" ];
validConfigs = "comparisons.internal.merge." + validConfigs;
mustBeA( arg, validConfigs );
end


