function update(hSrc,event)



    if nargin>1
        event=convertStringsToChars(event);
    end

    if strcmp(event,'attach')
        registerPropList(hSrc,'NoDuplicate','All',[]);
    elseif strcmp(event,'switch_target')
        if~isempty(hSrc.getConfigSet)
            cs=hSrc.getConfigSet;
            set_param(cs,'TargetHWDeviceType','MATLAB Host');
            set_param(cs,'PackageGeneratedCodeAndArtifacts','off');
            slConfigUISetEnabled(cs,hSrc,'PackageGeneratedCodeAndArtifacts','off');
            set_param(cs,'PackageName','');
            slConfigUISetEnabled(cs,hSrc,'PackageName','off');
        end
    end

