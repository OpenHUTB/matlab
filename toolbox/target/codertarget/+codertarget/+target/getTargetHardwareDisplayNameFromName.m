function dispName=getTargetHardwareDisplayNameFromName(name)




    dispName='';
    hw=codertarget.targethardware.getRegisteredTargetHardware;
    for i=1:numel(hw)
        if isequal(name,hw(i).Name)
            dispName=hw(i).DisplayName;
            break
        end
    end
end
