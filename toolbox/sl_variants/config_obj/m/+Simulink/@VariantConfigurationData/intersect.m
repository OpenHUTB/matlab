function intersectVCD = intersect( vcdA, vcdB, options )



































R36
vcdA Simulink.VariantConfigurationData;
vcdB Simulink.VariantConfigurationData;
options.SimplifyConditions logical = true;
end 

intersectVCD = Simulink.VariantConfigurationData;
intersectVCD.DataDictionaryName = vcdA.DataDictionaryName;
intersectVCD.DataDictionarySection = vcdA.DataDictionarySection;

intersectVCD = addCommonConfigurations( intersectVCD, vcdA, vcdB );
if isempty( intersectVCD.Configurations )
return ;
end 
intersectVCD.setConstraints( vcdA.Constraints );
netConstraintsOfVcdB = slvariants.internal.config.utils.getNetConstraintCondition( vcdB );
if ~isempty( netConstraintsOfVcdB )
constraintExpr = [ ' && ', '(', netConstraintsOfVcdB, ')' ];
slvariants.internal.config.utils.appendToConstraintConditions( intersectVCD, constraintExpr, options.SimplifyConditions );
end 

configNames = intersectVCD.getConfigurationNames(  );
if ~isempty( vcdA.PreferredConfiguration ) &&  ...
ismember( vcdA.PreferredConfiguration, configNames )
intersectVCD.setPreferredConfiguration( vcdA.PreferredConfiguration );
end 

if ~isempty( vcdA.DefaultConfigurationName ) &&  ...
ismember( vcdA.DefaultConfigurationName, configNames )
intersectVCD.setDefaultConfigurationName( vcdA.DefaultConfigurationName );
end 

intersectVCD.AreSubModelConfigurationsMigrated = vcdA.AreSubModelConfigurationsMigrated;
end 

function updatedVCD = addCommonConfigurations( vcdInitial, vcdA, vcdB )
updatedVCD = vcdInitial;
vcdAConfigs = vcdA.Configurations;
vcdBConfigs = vcdB.Configurations;
for idxA = 1:numel( vcdAConfigs )
for idxB = 1:numel( vcdBConfigs )

configPresent = slvariants.internal.config.utils.areControlVariablesEqual(  ...
vcdAConfigs( idxA ).ControlVariables,  ...
vcdBConfigs( idxB ).ControlVariables );
if ( configPresent )
updatedVCD.Configurations( end  + 1 ) = vcdAConfigs( idxA );
break ;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIyIA5p.p.
% Please follow local copyright laws when handling this file.

