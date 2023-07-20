function ret=getHardwareNames




    ret={};
    hw=codertarget.targethardware.getRegisteredTargetHardware('matlab');
    for i=1:numel(hw)
        if hw(i).HasMATLABPILInfo
            ret{end+1}=hw(i).Name;%#ok<AGROW>
        end
    end

