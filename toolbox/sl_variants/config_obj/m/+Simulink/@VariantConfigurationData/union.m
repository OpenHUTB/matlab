function unionedVCD = union( vcdA, vcdB, options )

arguments
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



