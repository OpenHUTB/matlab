function[info,e]=getExtModeWidgets(hObj)





    info.ParameterGroups={};
    info.Parameters={};
    e=[];
    try
        hardware=codertarget.targethardware.getTargetHardware(hObj);
        if~isempty(hardware)
            targetInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
            if~isempty(targetInfo)&&~isempty(targetInfo.ExternalModeInfo)&&targetInfo.EnableOneClick
                info.ParameterGroups={'External mode'};
                transportIdx=1;
                targetTransport=targetInfo.ExternalModeInfo(transportIdx).Transport.Type;
                extModeData=[];
                if hObj.isValidParam('CoderTargetData')&&...
                    ~isempty(get_param(hObj,'CoderTargetData'))&&...
                    codertarget.data.isParameterInitialized(hObj,'ExtMode')
                    coderTargetData=get_param(hObj,'CoderTargetData');%#ok
                    extModeData=codertarget.data.getParameterValue(hObj,'ExtMode');
                    if~isempty(extModeData)&&isstruct(extModeData)&&isfield(extModeData,'Configuration')
                        extModeTransportNames=cell(1,numel(targetInfo.ExternalModeInfo));
                        for i=1:numel(extModeTransportNames)
                            extModeTransportNames{i}=targetInfo.ExternalModeInfo(i).Transport.IOInterfaceName;
                        end
                        [~,transportIdx]=intersect(extModeTransportNames,extModeData.Configuration);
                        if~isempty(transportIdx)
                            targetTransport=targetInfo.ExternalModeInfo(transportIdx).Transport.Type;
                        else



                            transportIdx=1;
                            codertarget.data.setParameterValue(hObj,'ExtMode.Configuration',extModeTransportNames{1});
                        end
                    end
                end

                p=codertarget.parameter.ParameterInfo.getDefaultParameter();
                transportIntefaceNames=targetInfo.ExternalModeInfo.getIOInterfaceNames;
                p.Entries=transportIntefaceNames;
                p.Name=DAStudio.message('codertarget:ui:ExternalModeInterfaceLabel');
                p.SaveValueAsString=true;
                p.Storage='ExtMode.Configuration';
                p.Type='combobox';
                p.Tag='ExtMode_Configuration';
                p.Callback='codertarget.attributes.setExtModeData';
                if~isempty(extModeData)&&isstruct(extModeData)&&isfield(extModeData,'Configuration')
                    coderTargetData=get_param(hObj,'CoderTargetData');
                    p.Value=coderTargetData.ExtMode.Configuration;
                else
                    p.Value=transportIntefaceNames{1};
                end
                p.Visible=~hardware.SupportsOnlySimulation;
                p.DialogRefresh=true;
                p.RowSpan=eval(p.RowSpan);
                p.ColSpan=eval(p.ColSpan);
                p.Alignment=true;
                p.DoNotStore=false;
                idx=1;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries=codertarget.attributes.XCPProtocolConfiguration.getSupportedHostInterfaces();
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeHostInterfaceLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Type='combobox';
                p(idx).Tag='ExtMode_HostInterface';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Value=getExtModeProtocolInfoDataFromModel(hObj,p(1).Value,'HostInterface');
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''HostInterface'')';
                p(idx).DialogRefresh=true;
                p(idx).RowSpan=eval(p(idx).RowSpan);
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeRunInBackground');
                p(idx).Tag='ExtMode_RunInBackground';
                p(idx).Type='checkbox';
                p(idx).SaveValueAsString=false;
                p(idx).Callback='codertarget.attributes.setExtModeData';
                if targetInfo.ExternalModeInfo(transportIdx).Task.Visible
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'RunInBackground');
                else
                    p(idx).Value=false;
                end
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''InBackgroundTask'')';
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=eval(p(idx).RowSpan);
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;
                p(idx).ToolTip=char(DAStudio.message('codertarget:build:TooltipRunInBackground'));

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeSerialPortLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_COMPort';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''COMPort'')';
                if isequal(targetTransport,'serial')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'COMPort');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=eval(p(idx).RowSpan);
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeBaudRateLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_Baudrate';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''Baudrate'')';
                if isequal(targetTransport,'serial')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'Baudrate');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=eval(p(idx).RowSpan);
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeIPAddressLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_IPAddress';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''IPAddress'')';
                if isequal(targetTransport,'tcp/ip')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'IPAddress');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=eval(p(idx).RowSpan);
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModePortLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_Port';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''Port'')';
                if isequal(targetTransport,'tcp/ip')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'Port');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=eval(p(idx).RowSpan);
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;


                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Enabled=true;
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeCANVendorLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_CANVendor';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''CANVendor'')';
                if isequal(targetTransport,'can')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'CANVendor');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=[3,3];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Enabled=true;
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeCANDeviceLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_CANDevice';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''CANDevice'')';
                if isequal(targetTransport,'can')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'CANDevice');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=[4,4];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Enabled=true;
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeCANChannelLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_CANChannel';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''CANChannel'')';
                if isequal(targetTransport,'can')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'CANChannel');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=[5,5];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeCANIDCommandLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_CANIDCommand';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''CANIDCommand'')';
                if isequal(targetTransport,'can')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'CANIDCommand');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=[6,6];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeCANIDResponseLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_CANIDResponse';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''CANIDResponse'')';
                if isequal(targetTransport,'can')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'CANIDResponse');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=[7,7];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Type='checkbox';
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeExtendedCANIDLabel');
                p(idx).SaveValueAsString=false;
                p(idx).Tag='ExtMode_IsCANIDExtended';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''IsCANIDExtended'')';
                if isequal(targetTransport,'can')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'IsCANIDExtended');
                else
                    p(idx).Value=false;
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=[8,8];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeVerbose');
                p(idx).SaveValueAsString=false;
                p(idx).Tag='ExtMode_Verbose';
                p(idx).Type='checkbox';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''Verbose'')';
                if isequal(targetTransport,'serial')||isequal(targetTransport,'tcp/ip')||...
                    isequal(targetTransport,'can')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'Verbose');
                else
                    p(idx).Value=false;
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=[9,9];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeLoggingBufferSizeAutomaticLabel');
                p(idx).SaveValueAsString=false;
                p(idx).Tag='ExtMode_LoggingBufferAuto';
                p(idx).Type='checkbox';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''LoggingBufferAuto'')';
                p(idx).Value=getExtModeProtocolInfoDataFromModel(hObj,p(1).Value,'LoggingBufferAuto');
                p(idx).DialogRefresh=true;
                p(idx).RowSpan=[10,10];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeLoggingBufferSizeLabel');
                p(idx).SaveValueAsString=false;
                p(idx).Tag='ExtMode_LoggingBufferSize';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''LoggingBufferSize'')';
                p(idx).Value=getExtModeProtocolInfoDataFromModel(hObj,p(1).Value,'LoggingBufferSize');
                p(idx).DialogRefresh=true;
                p(idx).RowSpan=[11,11];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeNumOfLoggingBuffersLabel');
                p(idx).SaveValueAsString=false;
                p(idx).Tag='ExtMode_LoggingBufferNum';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''LoggingBufferNum'')';
                p(idx).Value=getExtModeProtocolInfoDataFromModel(hObj,p(1).Value,'LoggingBufferNum');
                p(idx).DialogRefresh=true;
                p(idx).RowSpan=[12,12];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeMaxContigSamples');
                p(idx).SaveValueAsString=false;
                p(idx).Tag='ExtMode_MaxContigSamples';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''MaxContigSamples'')';
                p(idx).Value=getExtModeProtocolInfoDataFromModel(hObj,p(1).Value,'MaxContigSamples');
                p(idx).DialogRefresh=true;
                p(idx).RowSpan=[13,13];
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;
                p(idx).ToolTip=char(DAStudio.message('codertarget:build:TooltipMaxContigSamples'));

                idx=idx+1;
                p(idx)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(idx).Entries={};
                p(idx).Name=DAStudio.message('codertarget:ui:ExternalModeMexArgsLabel');
                p(idx).SaveValueAsString=true;
                p(idx).Tag='ExtMode_MEXArgs';
                p(idx).Callback='codertarget.attributes.setExtModeData';
                p(idx).Visible='codertarget.attributes.isExtModeOptionVisible(hObj,''MEXArgs'')';
                if~isempty(targetTransport)&&isequal(targetTransport,'custom')
                    p(idx).Value=getConnectionInfoDataFromModel(hObj,p(1).Value,'MEXArgs');
                end
                p(idx).DialogRefresh=false;
                p(idx).RowSpan=eval(p(idx).RowSpan);
                p(idx).ColSpan=eval(p(idx).ColSpan);
                p(idx).Alignment=true;
                p(idx).DoNotStore=true;

                for ii=1:numel(p)
                    info.Parameters{1}{ii}=p(ii);
                end
            end
        end
    catch e
        info.ParameterGroups={};
        info.Parameters={};
    end
end



function data=getConnectionInfoDataFromModel(hCS,lIOInterfaceName,lFieldName)
    lCoderTargetData=get_param(hCS,'CoderTargetData');
    lIOInterfaceName=regexprep(lIOInterfaceName,'\W','');
    if~isempty(lCoderTargetData)&&isfield(lCoderTargetData,'ConnectionInfo')&&...
        isfield(lCoderTargetData.ConnectionInfo,lIOInterfaceName)&&...
        isfield(lCoderTargetData.ConnectionInfo.(lIOInterfaceName),lFieldName)
        data=lCoderTargetData.ConnectionInfo.(lIOInterfaceName).(lFieldName);
    else



        codertarget.attributes.resetExtModeData(hCS);
        lCoderTargetData=get_param(hCS,'CoderTargetData');
        data=lCoderTargetData.ConnectionInfo.(regexprep(lIOInterfaceName,'\W','')).(lFieldName);
    end
end

function data=getExtModeProtocolInfoDataFromModel(hCS,lIOInterfaceName,lFieldName)
    lCoderTargetData=get_param(hCS,'CoderTargetData');
    lIOInterfaceName=regexprep(lIOInterfaceName,'\W','');
    if~isempty(lCoderTargetData)&&isfield(lCoderTargetData,'ExtModeProtocolInfo')&&...
        isfield(lCoderTargetData.ExtModeProtocolInfo,lIOInterfaceName)&&...
        isfield(lCoderTargetData.ExtModeProtocolInfo.(lIOInterfaceName),lFieldName)
        data=lCoderTargetData.ExtModeProtocolInfo.(lIOInterfaceName).(lFieldName);
    else



        codertarget.attributes.resetExtModeProtocolInfo(hCS);
        lCoderTargetData=get_param(hCS,'CoderTargetData');
        if~isempty(lCoderTargetData)&&isfield(lCoderTargetData,'ExtModeProtocolInfo')&&...
            isfield(lCoderTargetData.ExtModeProtocolInfo,lIOInterfaceName)&&...
            isfield(lCoderTargetData.ExtModeProtocolInfo.(lIOInterfaceName),lFieldName)
            data=lCoderTargetData.ExtModeProtocolInfo.(lIOInterfaceName).(lFieldName);
        else



            data=[];
        end
    end
end
