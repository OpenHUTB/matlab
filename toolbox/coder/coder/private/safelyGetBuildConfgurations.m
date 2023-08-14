function[cfgs,defaultValue]=safelyGetBuildConfgurations(toolchain)



    cfgs={};
    defaultValue='';

    try
        [cfgs,defaultValue]=coder.make.internal.guicallback.getBuildConfigurations(toolchain);
        if~strcmp(defaultValue,'Faster Runs')&&any(contains(cfgs,'Faster Runs'))
            defaultValue='Faster Runs';
        end
    catch

    end
end