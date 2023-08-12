function unionedVCD = union( vcdA, vcdB, options )



































R36
vcdA Simulink.VariantConfigurationData;
vcdB Simulink.VariantConfigurationData;
options.SimplifyConditions logical = true;
end 

unionedVCD = copy( vcdA );
unionedVCD = addMissingConfigurations( unionedVCD, vcdB );
netConstraintsOfVcdB = slvariants.internal.config.utils.getNetConstraintCondition( vcdB );
if ~isempty( netConstraintsOfVcdB )
constraintExpr = [ ' || ', '(', netConstraintsOfVcdB, ')' ];
slvariants.internal.config.utils.appendToConstraintConditions( unionedVCD, constraintExpr, options.SimplifyConditions );
end 
end 

function updatedVCD = addMissingConfigurations( vcdA, vcdB )
updatedVCD = vcdA;
existingConfigs = vcdA.Configurations;
newConfigs = vcdB.Configurations;
for idxNew = 1:numel( newConfigs )
configPresent = false;
for idx = 1:numel( existingConfigs )

configPresent = slvariants.internal.config.utils.areControlVariablesEqual(  ...
newConfigs( idxNew ).ControlVariables,  ...
existingConfigs( idx ).ControlVariables );
if ( configPresent )
break ;
end 
end 
if ~configPresent
newConfig = newConfigs( idxNew );
existingConfigNames = { updatedVCD.Configurations.Name };
newConfig.Name = matlab.lang.makeUniqueStrings( newConfig.Name, existingConfigNames );
updatedVCD.Configurations( end  + 1 ) = newConfig;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9CkpLT.p.
% Please follow local copyright laws when handling this file.

