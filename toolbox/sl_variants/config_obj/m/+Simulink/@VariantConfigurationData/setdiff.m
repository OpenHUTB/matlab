function diffVcd = setdiff( vcdA, vcdB, options )

arguments
    vcdA Simulink.VariantConfigurationData;
    vcdB Simulink.VariantConfigurationData;
    options.SimplifyConditions logical = true;
end

diffVcd = copy( vcdA );
diffVcd = removeConfigurations( diffVcd, vcdB );

configNames = diffVcd.getConfigurationNames(  );
if ~isempty( diffVcd.PreferredConfiguration ) &&  ...
        ~ismember( diffVcd.PreferredConfiguration, configNames )
    diffVcd.setPreferredConfiguration( '' );
end

if ~isempty( diffVcd.DefaultConfigurationName ) &&  ...
        ~ismember( diffVcd.DefaultConfigurationName, configNames )
    diffVcd.setDefaultConfigurationName( '' );
end

if isempty( diffVcd.Configurations )
    diffVcd.setConstraints( [  ] );
    return ;
end
netConstraintsOfVcdB = slvariants.internal.config.utils.getNetConstraintCondition( vcdB );
if ~isempty( netConstraintsOfVcdB )
    constraintExpr = [ ' && ', '~(', netConstraintsOfVcdB, ')' ];
    slvariants.internal.config.utils.appendToConstraintConditions( diffVcd, constraintExpr, options.SimplifyConditions );
end
end

function newVcd = removeConfigurations( vcdOrig, vcdToBeRemoved )
newVcd = vcdOrig;
configs = newVcd.Configurations;
configsToBeRemoved = vcdToBeRemoved.Configurations;
for idx = numel( configs ): - 1:1
    for idxRem = 1:numel( configsToBeRemoved )

        if slvariants.internal.config.utils.areControlVariablesEqual(  ...
                configs( idx ).ControlVariables,  ...
                configsToBeRemoved( idxRem ).ControlVariables )
            newVcd.removeConfiguration( configs( idx ).Name );
            break ;
        end
    end
end
end


