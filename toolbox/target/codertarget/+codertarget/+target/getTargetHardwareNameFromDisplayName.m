function name=getTargetHardwareNameFromDisplayName(dispName)




    name='';
    hw=codertarget.targethardware.getRegisteredTargetHardware;
    for i=1:numel(hw)
        if isequal(dispName,hw(i).DisplayName)
            name=hw(i).Name;
            break
        end
    end
end
