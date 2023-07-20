function uniquedVCD=unique(vcd)













    uniquedVCD=copy(vcd);
    uniquedVCD=removeDuplicateConfigurations(uniquedVCD);
    uniquedVCD=removeDuplicateConstraints(uniquedVCD);
end

function vcdOut=removeDuplicateConfigurations(vcd)
    vcdOut=vcd;
    configs=vcd.Configurations;
    for idx=numel(configs):-1:1
        configsOut=vcdOut.Configurations;
        for idxOut=1:numel(configsOut)
            if isequal(configs(idx),configsOut(idxOut))
                continue;
            end

            ctrlVarsEqual=slvariants.internal.config.utils.areControlVariablesEqual(...
            configs(idx).ControlVariables,...
            configsOut(idxOut).ControlVariables);

            if~ctrlVarsEqual
                continue;
            end

            vcdOut.removeConfiguration(configs(idx).Name);

            if~isempty(vcdOut.PreferredConfiguration)&&...
                isequal(vcdOut.PreferredConfiguration,configs(idx).Name)
                vcdOut.setPreferredConfiguration(configsOut(idxOut).Name);
            end

            if~isempty(vcdOut.DefaultConfigurationName)&&...
                isequal(vcdOut.DefaultConfigurationName,configs(idx).Name)
                vcdOut.setDefaultConfigurationName(configsOut(idxOut).Name);
            end

            break;
        end
    end
end

function vcdOut=removeDuplicateConstraints(vcd)
    vcdOut=vcd;
    constraints=vcd.Constraints;
    for idx=numel(constraints):-1:1
        constraintsOut=vcdOut.Constraints;
        for idxOut=1:numel(constraintsOut)
            if(isequal(constraints(idx),constraintsOut(idxOut)))
                continue;
            end

            if isequal(constraints(idx).Condition,...
                constraintsOut(idxOut).Condition)
                vcdOut.removeConstraint(constraints(idx).Name);
                break;
            end
        end
    end
end
