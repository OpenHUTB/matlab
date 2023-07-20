function out=isExtModeOptionVisible(hObj,widgetName)













    out=false;
    try
        transportType='';
        switch widgetName
        case{'Baudrate','COMPort'}
            transportType='serial';
        case{'IPAddress','Port','Verbose'}
            transportType='tcp/ip';
        case{'CANVendor','CANDevice','CANChannel','BusSpeed','CANIDCommand','CANIDResponse','IsCANIDExtended'}
            transportType='can';
        case{'MEXArgs'}
            transportType='custom';
        end
        hCS=hObj.getConfigSet();
        transport=codertarget.attributes.getExtModeData('Transport',hCS);
        targetInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
        tgtHwInfo=codertarget.targethardware.getTargetHardware(hObj);
        if isempty(transport)
            transport=targetInfo.ExternalModeInfo(1).Transport.Name;
        end
        if~isempty(targetInfo.ExternalModeInfo)
            for ii=1:numel(targetInfo.ExternalModeInfo)
                if isequal(targetInfo.ExternalModeInfo(ii).Transport.Name,transport)

                    if~isempty(targetInfo.ExternalModeInfo(ii).ProtocolConfiguration)
                        protocolConfig=targetInfo.ExternalModeInfo(ii).ProtocolConfiguration;
                        switch widgetName
                        case{'HostInterface'}
                            out=protocolConfig.(widgetName).visible;
                            break;
                        case{'LoggingBufferAuto'}
                            out=protocolConfig.(widgetName).visible&&...
                            isequal(codertarget.attributes.getExtModeData('HostInterface',hCS),...
                            DAStudio.message('codertarget:ui:ExternalModeSimulinkHostInterface'));
                            break;
                        case{'LoggingBufferSize','LoggingBufferNum'}
                            out=~codertarget.attributes.getExtModeData('LoggingBufferAuto',hCS)&&...
                            protocolConfig.(widgetName).visible;
                            break;
                        case{'MaxContigSamples'}
                            out=codertarget.attributes.getExtModeData('LoggingBufferAuto',hCS)&&...
                            protocolConfig.(widgetName).visible;
                            break;
                        end
                    end

                    if~isempty(targetInfo.ExternalModeInfo(ii).Task)
                        if isequal(widgetName,'InBackgroundTask')
                            out=targetInfo.ExternalModeInfo(ii).Task.Visible;
                            break;
                        end
                    end

                    if~isempty(transportType)
                        inputApplicable=(isequal(widgetName,'Verbose')&&...
                        ~isequal(targetInfo.ExternalModeInfo(ii).Transport.Type,'custom'))...
                        ||isequal(targetInfo.ExternalModeInfo(ii).Transport.Type,transportType);
                        if inputApplicable
                            out=targetInfo.ExternalModeInfo(ii).Transport.(widgetName).visible;
                        else
                            out=false;
                        end
                        if isequal(widgetName,'CANVendor')||isequal(widgetName,'CANDevice')||...
                            isequal(widgetName,'CANChannel')
                            out=out&&isequal(codertarget.attributes.getExtModeData('HostInterface',hCS),...
                            DAStudio.message('codertarget:ui:ExternalModeSimulinkHostInterface'));
                        end
                        break;
                    end
                end
            end
        end
    catch e
        MSLDiagnostic('codertarget:build:ExternalModeCallbackError','isExtModeOptionVisible',char([10,e.message])).reportAsWarning;
        out=false;
    end


    out=out&&~tgtHwInfo.SupportsOnlySimulation;
end
