function targetType=getTargetType(targetName)




    targetType=-1;
    targets=codertarget.target.getRegisteredTargets;
    for i=1:numel(targets)
        if strcmp(targetName,targets(i).Name)
            targetType=targets(i).TargetType;
            break
        end
    end
    if isequal(targetType,-1)




        targetType=0;


        registeredHW=codertarget.targethardware.getRegisteredTargetHardware;
        for i=1:numel(registeredHW)
            if isequal(registeredHW(i).TargetName,targetName)


                targetType=registeredHW(i).TargetType;
                break;
            end
        end
    end
end