function bool = supportsTempFiles( options )

arguments
    options( 1, 1 ){ mustBeA( options, 'comparisons.internal.TwoWayOptions' ) }
end

configIs = @( metaData )isa( options.MergeConfig, metaData.Name );

bool = configIs( ?comparisons.internal.merge.MergeIntoTarget ) ...
    || configIs( ?comparisons.internal.merge.SCMConflicts ) ...
    || configIs( ?comparisons.internal.merge.DisableMerge );
end

