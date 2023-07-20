function Output=getExtModeData(lFieldName,hCS)




    if isa(hCS,'CoderTarget.SettingsController')
        hCS=hCS.getConfigSet();
    elseif ischar(hCS)
        hCS=getActiveConfigSet(hCS);
    else
        assert(isa(hCS,'Simulink.ConfigSet'),[mfilename,' called with a wrong argument']);
    end

    if hCS.isValidParam('CoderTargetData')
        lData=get_param(hCS,'CoderTargetData');
        lTargetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
        lExtModeInfo=lTargetInfo.ExternalModeInfo;
        lIOInterface=lData.ExtMode.Configuration;
        extModeTransportNames=lExtModeInfo.getIOInterfaceNames();
        [~,idx]=intersect(extModeTransportNames,lIOInterface);
        protocolFields=codertarget.attributes.XCPProtocolConfiguration.getProtocolConfigurationWidgetNames();
        if isequal(lFieldName,'Transport')
            Output=lExtModeInfo(idx).Transport.Name;
        elseif isequal(lFieldName,'TransportType')
            Output=lExtModeInfo(idx).Transport.Type;
        elseif isequal(lFieldName,'PostDisconnectTargetFcn')
            if isprop(lExtModeInfo(idx),'PostDisconnectTargetFcn')
                Output=lExtModeInfo(idx).PostDisconnectTargetFcn;
            else
                Output='';
            end
        elseif any(contains(lFieldName,protocolFields))
            Output=locGetExtModeProtocolData(lData,lIOInterface,lFieldName);
        else
            Output=locGetConnectionData(hCS,lTargetInfo,lData,lIOInterface,lFieldName);
        end
    else
        Output=[];
    end
end


function Output=locGetConnectionData(hCS,lTargetInfo,lData,lIOInterface,lFieldName)
    aIOInterface=regexprep(lIOInterface,'\W','');
    if isstruct(lData)&&isfield(lData,'ConnectionInfo')&&isfield(lData.ConnectionInfo,aIOInterface)
        connData=lData.ConnectionInfo.(aIOInterface);
    else

        Output='';
        return
    end
    switch(lFieldName)
    case{'COMPort','comport'}
        COMPort=connData.COMPort;
        COMPort=codertarget.utils.replaceTokens(hCS,COMPort,lTargetInfo.Tokens);


        lExtModeInfo=lTargetInfo.ExternalModeInfo;
        extModeTransportNames=lExtModeInfo.getIOInterfaceNames();
        [~,idx]=intersect(extModeTransportNames,lIOInterface);
        COMPortAttribute=lExtModeInfo(idx).Transport.(lFieldName).value;
        if isnan(str2double(COMPortAttribute))
            if ispc
                numberRetAttribute=regexp(COMPortAttribute,'COM(\d+)','tokens');
            else
                numberRetAttribute=regexp(COMPortAttribute,'^(/.*)','tokens');
            end
        end

        if isnan(str2double(COMPort))
            if ispc
                numberRet=regexp(COMPort,'COM(\d+)','tokens');
            else
                numberRet=regexp(COMPort,'^(/.*)','tokens');
            end

            if~isempty(numberRet)
                if isempty(numberRetAttribute)




                    COMPort=COMPortAttribute;
                    COMPort=codertarget.utils.replaceTokens(hCS,COMPort,lTargetInfo.Tokens);
                    numberRet='';
                end
            end

            if~isempty(numberRet)
                COMPort=numberRet{1}{1};
            else
                COMPort=locEvalOneOutput(hCS,COMPort);
            end
        end
        Output=COMPort;
    case{'IPAddress','ipaddress'}
        Output=connData.IPAddress;
        Output=codertarget.utils.replaceTokens(hCS,Output,lTargetInfo.Tokens);
        number=regexp(Output,'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$','tokens');
        if isempty(number)
            Output=locEvalOneOutput(hCS,Output);
        end
        Output=['''',Output,''''];
    case{'Baudrate','baudrate'}
        Output=locEvalOneOutput(hCS,connData.Baudrate);
        Output=codertarget.utils.replaceTokens(hCS,Output,lTargetInfo.Tokens);
        if isempty(Output)
            Output='115200';
        end
    case{'Port','port'}
        Output=locEvalOneOutput(hCS,connData.Port);
        Output=codertarget.utils.replaceTokens(hCS,Output,lTargetInfo.Tokens);
        if isempty(Output)
            Output='17725';
        end
    case{'Verbose','verbose'}
        Output=connData.Verbose;
        if islogical(Output)&&connData.Verbose
            Output='1';
        elseif islogical(Output)&&~connData.Verbose
            Output='0';
        end
    case{'MEXArgs','mexargs'}
        Output=connData.MEXArgs;
        if~isempty(Output)&&isequal(Output(1),'@')
            Output=locEvalOneOutput(hCS,Output(2:end));
        end
        Output=codertarget.utils.replaceTokens(hCS,Output,lTargetInfo.Tokens);
    case{'RunInBackground'}
        if isfield(connData,lFieldName)
            Output=connData.(lFieldName);
        else
            Output=true;
        end
    case{'CANVendor','canvendor'}
        Output=connData.CANVendor;
    case{'CANDevice','candevice'}
        Output=connData.CANDevice;
    case{'CANChannel','canchannel'}
        Output=connData.CANChannel;
        if isempty(Output)
            Output='1';
        end
    case{'BusSpeed','busspeed'}
        Output=locEvalOneOutput(hCS,connData.BusSpeed);
        Output=codertarget.utils.replaceTokens(hCS,Output,lTargetInfo.Tokens);
        if isempty(Output)
            Output='1000000';
        end
    case{'CANIDCommand','canidcommand'}
        Output=locEvalOneOutput(hCS,connData.CANIDCommand);
        Output=codertarget.utils.replaceTokens(hCS,Output,lTargetInfo.Tokens);
        if isempty(Output)
            Output='2';
        end
    case{'CANIDResponse','canidresponse'}
        Output=locEvalOneOutput(hCS,connData.CANIDResponse);
        Output=codertarget.utils.replaceTokens(hCS,Output,lTargetInfo.Tokens);
        if isempty(Output)
            Output='3';
        end
    case{'IsCANIDExtended','iscanidextended'}
        Output=connData.IsCANIDExtended;
        if islogical(Output)&&connData.IsCANIDExtended
            Output='1';
        elseif islogical(Output)&&~connData.IsCANIDExtended
            Output='0';
        end
    otherwise
        Output='';
    end
end


function Output=locGetExtModeProtocolData(lData,lIOInterface,lFieldName)
    aIOInterface=regexprep(lIOInterface,'\W','');
    if isstruct(lData)&&isfield(lData,'ExtModeProtocolInfo')&&...
        isfield(lData.ExtModeProtocolInfo,aIOInterface)&&...
        isfield(lData.ExtModeProtocolInfo.(aIOInterface),lFieldName)
        Output=lData.ExtModeProtocolInfo.(aIOInterface).(lFieldName);
    else
        Output='';
    end
end



function out=locEvalOneOutput(hCS,in)


    try
        assert(ischar(in),'Input must be a character array')
        out=eval(in);
        if isnumeric(out)
            out=num2str(out);
        end
    catch e
        DAStudio.error('codertarget:build:ExternalModeCallbackError','getExtModeData',char([in,10,e.message]));
    end
end



