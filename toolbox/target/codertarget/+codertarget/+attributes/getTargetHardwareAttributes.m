function attributes=getTargetHardwareAttributes(hObj,product)




    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')||...
        isa(hObj,'coder.CodeConfig'),...
        [mfilename,' called with a wrong argument']);
    end
    if nargin<2
        product='simulink';
    end
    validatestring(product,{'matlab','simulink'},'','''product''');

    attributes=[];
    hardware=codertarget.targethardware.getTargetHardware(hObj,product);
    if~isempty(hardware)
        if locIsMdlConfiguredForProcessingUnit(hardware,hObj)
            procUnit=codertarget.targethardware.getProcessingUnitInfo(hObj);
            attributes=codertarget.attributes.getProcessingUnitAttributes(procUnit);
        else
            attributes=codertarget.attributes.getTargetHardwareAttributesForHardwareName(hardware,product);
        end
    end
end

function out=locIsMdlConfiguredForProcessingUnit(hardware,hObj)
    out=false;
    if hardware.hasProcessingUnit()&&...
        codertarget.targethardware.isProcessingUnitSelectionAvailable(hObj)
        procUnitName=codertarget.targethardware.getProcessingUnitName(hObj);
        if~isempty(procUnitName)||~isequal(procUnitName,'None')
            out=true;
        end
    end
end

