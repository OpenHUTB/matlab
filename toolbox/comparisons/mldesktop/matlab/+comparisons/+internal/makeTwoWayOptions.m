function options = makeTwoWayOptions( args )

arguments
    args.Debug( 1, 1 ){ mustBeNumericOrLogical } = false
    args.OpenDevTools( 1, 1 ){ mustBeNumericOrLogical } = false
    args.DebugPort( 1, 1 ){ mustBeNumeric } = 0
    args.EnableSwapSides{ mustBeNumericOrLogical } = true
    args.MergeConfig{ mustBeValidTwoWayMergeConfig, mustBeNonempty } = comparisons.internal.merge.ShowDialog(  )
    args.Type{ mustBeTextScalar } = ""
end
options = comparisons.internal.TwoWayOptions(  );

propStrs = string( properties( options ) );
for propStr = propStrs.'
    options.( propStr ) = args.( propStr );
end
end

function mustBeValidTwoWayMergeConfig( arg )
validConfigs = [ "DisableMerge", "MergeIntoRight", "MergeIntoTarget", "SCMConflicts", "ShowDialog" ];
validConfigs = "comparisons.internal.merge." + validConfigs;
mustBeA( arg, validConfigs );
end


