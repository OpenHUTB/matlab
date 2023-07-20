function validateHardwareBoardFeatureSet(hCS,value)









    EC=0;
    SOC=1;

    assert(ismember(value,[EC,SOC]),'invalid value for HardwareBoardFeatureSet');






    if~isequal(get_param(hCS,'HardwareBoard'),'None')&&~isValidParam(hCS,'CoderTargetData')
        return;
    end








    if~isValidParam(hCS,'CoderTargetData')&&isequal(value,SOC)
        error(message('codertarget:build:HardwareBoardFeatureSetSOCInvalid'));
    end



    targetHardwareName=codertarget.data.getParameterValue(hCS,'TargetHardware');




    import codertarget.utils.*;
    switch(isSoCInstalled()&&isBoardSoCCompatible(targetHardwareName))
    case true
        if isequal(value,EC)&&~locIsECHSPInstalled(targetHardwareName)
            error(message('codertarget:build:HardwareBoardFeatureSetECInvalid'));
        end
    case false
        if isequal(value,SOC)
            error(message('codertarget:build:HardwareBoardFeatureSetSOCInvalid'));
        end
    end
end


function ret=locIsECHSPInstalled(targetHardwareName)



    ret=false;
    if~isempty(which('codertarget.internal.getHardwareBoardsForInstalledSpPkgs'))
        ret=any(ismember(targetHardwareName,...
        codertarget.internal.getHardwareBoardsForInstalledSpPkgs('ec')));
    end
end
