function resetAllResources(hCS,varargin)












    if~hCS.isValidParam('DynamicTargetHardwareResourcesBuilding')||...
        ~hCS.isValidParam('DynamicTargetHardwareResourcesUpdating')
        return
    end
    fullReset=false;
    if isequal(nargin,2)
        fullReset=true;
    end



    if~isa(hCS,'Simulink.ConfigSetRef')
        if fullReset
            set_param(hCS,'DynamicTargetHardwareResourcesBuilding','');
            set_param(hCS,'DynamicTargetHardwareResourcesUpdating','');
        else
            set_param(hCS,'DynamicTargetHardwareResourcesUpdating','');
        end
    end
end