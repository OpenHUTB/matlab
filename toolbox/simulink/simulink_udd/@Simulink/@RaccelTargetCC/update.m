function update(hSrc,event)


    if strcmp(event,'attach')
        registerPropList(hSrc,'NoDuplicate','All',[]);


    elseif strcmp(event,'switch_target')
        if~isempty(hSrc.getConfigSet)
            set_param(hSrc.getConfigSet,...
            'TargetHWDeviceType','MATLAB Host');
        end

    end






