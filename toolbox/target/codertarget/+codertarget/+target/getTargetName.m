function targetName=getTargetName(hObj)




    if ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    elseif~isa(hObj,'coder.CodeConfig')&&...
        ~isa(hObj,'Simulink.ConfigSet')
        hObj=hObj.getConfigSet();
    end

    targetHardware=codertarget.targethardware.getTargetHardware(hObj);
    if~isempty(targetHardware)
        targetName=targetHardware.TargetName;
    else
        targetName=[];
    end
end
