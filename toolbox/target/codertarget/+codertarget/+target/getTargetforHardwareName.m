function targetName=getTargetforHardwareName(hwName)



    targetName=[];
    registeredHw=codertarget.targethardware.getRegisteredTargetHardware;
    for i=1:numel(registeredHw)
        if isequal(hwName,registeredHw(i).Name)
            targetName=registeredHw(i).TargetName;
            break;
        end
    end
end

