function folder=getTargetFolder(hSrc)





    folder=[];
    if isa(hSrc,'Simulink.ConfigSet')||isa(hSrc,'Simulink.ConfigSetRef')
        hardware=codertarget.targethardware.getTargetHardware(hSrc.getConfigSet());
        if~isempty(hardware)
            folder=hardware.TargetFolder;
        end
    elseif ischar(hSrc)
        targets=codertarget.target.getRegisteredTargets;
        for i=1:numel(targets)
            if strcmp(hSrc,targets(i).Name)
                folder=targets(i).TargetFolder;
                break
            end
        end
    end
end
