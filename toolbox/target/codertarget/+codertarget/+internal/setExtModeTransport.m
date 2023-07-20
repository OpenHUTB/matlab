function setExtModeTransport(hObj)




    targetHardwareAttributes=codertarget.attributes.getTargetHardwareAttributes(hObj);


    if codertarget.data.isParameterInitialized(hObj,'ExtMode')
        extModeInfo=targetHardwareAttributes.ExternalModeInfo;
        IOInterfaceName=codertarget.data.getParameterValue(hObj,...
        'ExtMode.Configuration');
        extModeTransportsRegistered=extmode_transports(hObj);



        if~isequal(extModeTransportsRegistered{1},'none')
            for i=1:numel(extModeInfo)
                if isequal(IOInterfaceName,extModeInfo(i).Transport.IOInterfaceName)
                    transportName=extModeInfo(i).Transport.Name;
                    idx=Simulink.ExtMode.Transports.getExtModeTransportIndex(hObj,...
                    transportName);
                    assert(~isempty(idx),'Unknown Transport selected');
                    set_param(hObj,'ExtModeTransport',idx);
                    break;
                end
            end
        end
    end
end