function ret=getAllHardwareBoards(targetName)



    ret=[];
    registeredHw=codertarget.targethardware.getRegisteredTargetHardware;
    for i=1:numel(registeredHw)
        if isequal(targetName,registeredHw(i).TargetName)
            ret=[ret,codertarget.targethardware.getTargetHardware(registeredHw(i).Name)];%#ok<AGROW>
        end
    end
end