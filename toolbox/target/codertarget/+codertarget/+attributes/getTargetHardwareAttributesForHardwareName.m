function attributes=getTargetHardwareAttributesForHardwareName(hardware,product)




    if nargin<2
        product='simulink';
    end
    attributes=[];
    if ischar(hardware)
        hardware=codertarget.targethardware.getTargetHardware(hardware,product);
    end
    if~isempty(hardware)
        defFile=codertarget.utils.replaceTokensforHardwareName(hardware,hardware.AttributeInfoFile);
        if~isempty(defFile)
            attributes=codertarget.Registry.manageInstance('get','attributes',defFile);
        end
    end
end

