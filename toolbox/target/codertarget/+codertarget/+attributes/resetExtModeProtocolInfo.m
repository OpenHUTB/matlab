function protocolInfo=resetExtModeProtocolInfo(hCS)





    targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
    protocolInfo=[];
    if isprop(targetInfo,'ExternalModeInfo')
        extmodeInfo=targetInfo.ExternalModeInfo;
        if~isempty(extmodeInfo)
            for i=1:numel(extmodeInfo)
                if isprop(extmodeInfo(i),'ProtocolConfiguration')&&~isempty(extmodeInfo(i).ProtocolConfiguration)
                    protocolFields=codertarget.attributes.XCPProtocolConfiguration.getProtocolConfigurationWidgetNames();
                    for ii=1:numel(protocolFields)
                        lProtocolInfo.(protocolFields{ii})=extmodeInfo(i).ProtocolConfiguration.(protocolFields{ii}).value;
                    end
                    protocolInfo.(regexprep(extmodeInfo(i).Transport.IOInterfaceName,'\W',''))=lProtocolInfo;
                end
            end
            if~isempty(protocolInfo)
                codertarget.data.setParameterValue(hCS,'ExtModeProtocolInfo',protocolInfo);
            end
        end
    end
end