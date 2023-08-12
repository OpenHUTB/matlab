function bool = supportsTempFiles( options )





R36
options( 1, 1 ){ mustBeA( options, 'comparisons.internal.TwoWayOptions' ) }
end 

configIs = @( metaData )isa( options.MergeConfig, metaData.Name );

bool = configIs( ?comparisons.internal.merge.MergeIntoTarget ) ...
 || configIs( ?comparisons.internal.merge.SCMConflicts ) ...
 || configIs( ?comparisons.internal.merge.DisableMerge );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptQxaUD.p.
% Please follow local copyright laws when handling this file.

