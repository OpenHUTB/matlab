function setExtModeData(hObj,hDlg,tag,~)






    if isa(hDlg,'ConfigSet.DDGWrapper')
        setExtModeData_web(hObj,hDlg);
    else
        setExtModeData_ddg(hObj,hDlg,tag)
    end


    hCS=hObj.getConfigSet();
    codertarget.internal.setExtModeTransport(hCS);
end

function setExtModeData_ddg(hObj,hDlg,tag)

    cs=hObj.getConfigSet();
    ud=hDlg.getUserData(tag);
    fieldName=ud.Storage;

    if isequal(fieldName,'ExtMode.Configuration')
        tagprefix='Tag_ConfigSet_CoderTarget_';
        if isempty(fieldName)
            fieldName=strrep(tag,tagprefix,'');
        end
        curVal=codertarget.data.getParameterValue(cs,fieldName);
        newVal=hDlg.getWidgetValue(tag);
        if isnumeric(newVal)&&~isnumeric(curVal)
            newVal=hDlg.getComboBoxText(tag);
        elseif ischar(newVal)&&isnumeric(curVal)
            newVal=str2num(newVal);%#ok<ST2NM>
        end
        codertarget.data.setParameterValue(cs,fieldName,newVal);
    else
        tagprefix='Tag_ConfigSet_CoderTarget_ExtMode_';
        if isempty(fieldName)
            fieldName=strrep(tag,tagprefix,'');
        else
            fieldName=strrep(fieldName,'ExtMode.','');
        end
        newVal=hDlg.getWidgetValue(tag);
        iointerfacename=hDlg.getComboBoxText('Tag_ConfigSet_CoderTarget_ExtMode_Configuration');
        lTargetInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
        protocolFields=codertarget.attributes.XCPProtocolConfiguration.getProtocolConfigurationWidgetNames();

        if any(contains(fieldName,protocolFields))
            iointerfacename=['ExtModeProtocolInfo.',regexprep(iointerfacename,'\W','')];
            curExtModeProtocolInfo=codertarget.data.getParameterValue(cs,iointerfacename);
            curVal=curExtModeProtocolInfo.(fieldName);
            if codertarget.data.isParameterInitialized(hObj,iointerfacename)
                lExtModeProtocolInfo=codertarget.data.getParameterValue(hObj,iointerfacename);
            else

                DAStudio.error('codertarget:setup:ExternalModeDataCorrupted');
            end
            if~locCheckValidity(cs,newVal,fieldName,lTargetInfo)
                hDlg.setWidgetValue(tag,curVal);
                DAStudio.error('codertarget:setup:ExternalModeDataInvalid',newVal,fieldName);
            end
            if isnumeric(newVal)&&~isnumeric(curVal)
                newVal=hDlg.getComboBoxText(tag);
            elseif ischar(newVal)&&isnumeric(curVal)
                newVal=str2num(newVal);%#ok<ST2NM>
            end
            if~isempty(lExtModeProtocolInfo)&&isstruct(lExtModeProtocolInfo)&&isfield(lExtModeProtocolInfo,fieldName)
                lExtModeProtocolInfo.(fieldName)=newVal;
            end
            if locCheckRangeAndValue(ud,newVal)
                codertarget.data.setParameterValue(cs,iointerfacename,lExtModeProtocolInfo);
            else
                hDlg.setWidgetValue(tag,curVal);
            end
            locSetDependentFields(cs,iointerfacename,fieldName,lExtModeProtocolInfo);
        else

            iointerfacename=['ConnectionInfo.',regexprep(iointerfacename,'\W','')];
            curConnectionInfo=codertarget.data.getParameterValue(cs,iointerfacename);
            curVal=curConnectionInfo.(fieldName);
            if codertarget.data.isParameterInitialized(hObj,iointerfacename)
                lConnection=codertarget.data.getParameterValue(hObj,iointerfacename);
            else

                DAStudio.error('codertarget:setup:ExternalModeDataCorrupted');
            end
            if~locCheckValidity(cs,newVal,fieldName,lTargetInfo)
                hDlg.setWidgetValue(tag,curVal);
                DAStudio.error('codertarget:setup:ExternalModeDataInvalid',newVal,fieldName);
            end
            if isnumeric(newVal)&&~isnumeric(curVal)
                newVal=hDlg.getComboBoxText(tag);
            elseif ischar(newVal)&&isnumeric(curVal)
                newVal=str2num(newVal);%#ok<ST2NM>
            end
            if~isempty(lConnection)&&isstruct(lConnection)&&isfield(lConnection,fieldName)
                lConnection.(fieldName)=newVal;
            end
            if locCheckRangeAndValue(ud,newVal)
                codertarget.data.setParameterValue(cs,iointerfacename,lConnection);
            else
                hDlg.setWidgetValue(tag,curVal);
            end
        end
    end
end

function setExtModeData_web(hObj,hDlg)

    cs=hObj.getConfigSet();
    ud=hDlg.userData;
    fieldName=ud.Storage;
    newVal=hDlg.value;
    tag=hDlg.tag;

    if isequal(fieldName,'ExtMode.Configuration')
        curVal=codertarget.data.getParameterValue(cs,fieldName);
        if isnumeric(newVal)&&~isnumeric(curVal)
            newVal=ud.Entries{newVal+1};
        elseif ischar(newVal)&&isnumeric(curVal)
            newVal=str2num(newVal);%#ok<ST2NM>
        end
        codertarget.data.setParameterValue(cs,fieldName,newVal);
    else
        tagprefix='Tag_ConfigSet_CoderTarget_ExtMode_';
        if isempty(fieldName)
            fieldName=strrep(tag,tagprefix,'');
        else
            fieldName=strrep(fieldName,'ExtMode.','');
        end

        iointerfacename=codertarget.data.getParameterValue(cs,'ExtMode.Configuration');
        lTargetInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
        protocolFields=codertarget.attributes.XCPProtocolConfiguration.getProtocolConfigurationWidgetNames();

        if any(contains(fieldName,protocolFields))
            iointerfacename=['ExtModeProtocolInfo.',regexprep(iointerfacename,'\W','')];
            if codertarget.data.isParameterInitialized(hObj,iointerfacename)
                lExtModeProtocolInfo=codertarget.data.getParameterValue(hObj,iointerfacename);
            else

                DAStudio.error('codertarget:setup:ExternalModeDataCorrupted');
            end
            if~locCheckValidity(cs,newVal,fieldName,lTargetInfo)
                DAStudio.error('codertarget:setup:ExternalModeDataInvalid',newVal,fieldName);
            end
            if~isempty(lExtModeProtocolInfo)&&isstruct(lExtModeProtocolInfo)&&isfield(lExtModeProtocolInfo,fieldName)
                lExtModeProtocolInfo.(fieldName)=newVal;
            end
            if locCheckRangeAndValue(ud,newVal)
                codertarget.data.setParameterValue(cs,iointerfacename,lExtModeProtocolInfo);
            end
            locSetDependentFields(cs,iointerfacename,fieldName,lExtModeProtocolInfo);
        else

            iointerfacename=['ConnectionInfo.',regexprep(iointerfacename,'\W','')];
            if codertarget.data.isParameterInitialized(hObj,iointerfacename)
                lConnection=codertarget.data.getParameterValue(hObj,iointerfacename);
            else

                DAStudio.error('codertarget:setup:ExternalModeDataCorrupted');
            end
            if~locCheckValidity(cs,newVal,fieldName,lTargetInfo)
                DAStudio.error('codertarget:setup:ExternalModeDataInvalid',newVal,fieldName);
            end
            if~isempty(lConnection)&&isstruct(lConnection)&&isfield(lConnection,fieldName)
                lConnection.(fieldName)=newVal;
            end
            if locCheckRangeAndValue(ud,newVal)
                codertarget.data.setParameterValue(cs,iointerfacename,lConnection);
            end
        end
    end
end


function out=locCheckRangeAndValue(ud,newVal)
    out=true;
    if(~isempty(ud.ValueType)&&~strcmpi(ud.ValueType,'callback'))||~isempty(ud.ValueRange)
        validRange=eval(ud.ValueRange);
        if~isnumeric(newVal)
            newVal=str2double(newVal);
        end
        func=str2func(ud.ValueType);
        val=func(newVal);
        if val<func(validRange(1))||val>func(validRange(2))||~isequal(newVal,val)
            s1=num2str(validRange(1));
            s2=num2str(validRange(2));
            str=sprintf('Invalid value entered. The value must be between %s and %s.',s1,s2);
            f=errordlg(str,'Coder Target Error Dialog','modal');%#ok<NASGU>
            out=false;
        end
    end
end


function Output=locCheckValidity(hCS,newVal,lFieldName,lTargetInfo)
    Output=false;
    switch(lFieldName)
    case{'COMPort','comport'}
        COMPort=newVal;
        COMPort=codertarget.utils.replaceTokens(hCS,COMPort,lTargetInfo.Tokens);
        if isnan(str2double(COMPort))
            if ispc
                numberRet=regexp(COMPort,'COM(\d+)','tokens');
            else
                numberRet=regexp(COMPort,'^(/.*)','tokens');
            end
            if~isempty(numberRet)
                COMPort=numberRet{1}{1};
            else
                COMPort=locEvalOneOutput(COMPort);
            end
        end
        if~isempty(COMPort)
            Output=true;
        end
    case{'IPAddress','ipaddress'}
        newVal=codertarget.utils.replaceTokens(hCS,newVal,lTargetInfo.Tokens);
        number=regexp(newVal,'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$','tokens');
        if isempty(number)
            newVal=locEvalOneOutput(newVal);
        end
        if~isempty(newVal)
            Output=true;
        end
    case{'Baudrate','baudrate'}
        newVal=locEvalOneOutput(newVal);
        newVal=codertarget.utils.replaceTokens(hCS,newVal,lTargetInfo.Tokens);
        if~isempty(newVal)
            Output=true;
        end
    case{'Port','port'}
        newVal=locEvalOneOutput(newVal);
        newVal=codertarget.utils.replaceTokens(hCS,newVal,lTargetInfo.Tokens);
        validateattributes(str2double(newVal),{'numeric'},...
        {'nonempty','nonnan','scalar','integer','>=',1,'<=',2^16-1},'','Port');
        if~isempty(newVal)
            Output=true;
        end
    case{'Verbose','verbose'}
        if islogical(newVal)
            Output=true;
        end
    case{'MEXArgs','mexargs'}
        if~isempty(newVal)&&isequal(newVal(1),'@')
            newVal=locEvalOneOutput(newVal(2:end));
        end
        newVal=codertarget.utils.replaceTokens(hCS,newVal,lTargetInfo.Tokens);
        if~isempty(newVal)
            Output=true;
        end
    case{'RunInBackground'}
        if islogical(newVal)
            Output=true;
        end
    case{'CANVendor'}
        validateattributes(newVal,{'char'},{'scalartext'},'','CANVendor');

        val=regexp(newVal,'^[A-Za-z]+$');%#ok<*RGXP1> 
        if~isempty(val)
            Output=true;
        end
    case{'CANDevice'}
        validateattributes(newVal,{'char'},{'scalartext'},'','CANDevice');


        val=regexp(newVal,'^[A-Za-z0-9\s]+$');
        if~isempty(val)
            Output=true;
        end
    case{'CANChannel'}
        validateattributes(str2double(newVal),{'numeric'},...
        {'integer','positive'},'','CANChannel');
        if~isempty(newVal)
            Output=true;
        end
    case{'BusSpeed'}
        newVal=locEvalOneOutput(newVal);
        validateattributes(str2double(newVal),{'numeric'},...
        {'scalar','positive','<=',1000000},'','BusSpeed');
        if~isempty(newVal)
            Output=true;
        end
    case{'CANIDCommand'}
        newVal=locEvalOneOutput(newVal);
        isExtendedID=codertarget.attributes.getExtModeData('IsCANIDExtended',hCS);
        if isequal(isExtendedID,'1')
            validateattributes(str2double(newVal),{'numeric'},...
            {'scalar','positive','<',pow2(29)},'','CANIDCommand');
        else
            validateattributes(str2double(newVal),{'numeric'},...
            {'scalar','positive','<',pow2(11)},'','CANIDCommand');
        end
        if~isempty(newVal)
            Output=true;
        end
    case{'CANIDResponse'}
        newVal=locEvalOneOutput(newVal);
        isExtendedID=codertarget.attributes.getExtModeData('IsCANIDExtended',hCS);
        if isequal(isExtendedID,'1')
            validateattributes(str2double(newVal),{'numeric'},...
            {'scalar','positive','<',pow2(29)},'','CANIDResponse');
        else
            validateattributes(str2double(newVal),{'numeric'},...
            {'scalar','positive','<',pow2(11)},'','CANIDResponse');
        end
        if~isempty(newVal)
            Output=true;
        end
    case{'IsCANIDExtended'}
        if islogical(newVal)
            Output=true;
        end
    case{'HostInterface'}
        supportedHostInterfaces=codertarget.attributes.XCPProtocolConfiguration.getSupportedHostInterfaces();
        if any(contains(newVal,supportedHostInterfaces))
            Output=true;
        end
    case{'LoggingBufferAuto'}
        if islogical(newVal)
            Output=true;
        end
    case{'LoggingBufferSize'}
        validateattributes(str2double(newVal),{'numeric'},...
        {'scalar','positive'},'','LoggingBufferSize');
        if~isempty(newVal)
            Output=true;
        end
    case{'LoggingBufferNum'}
        validateattributes(str2double(newVal),{'numeric'},...
        {'scalar','positive'},'','LoggingBufferNum');
        if~isempty(newVal)
            Output=true;
        end
    case{'MaxContigSamples'}
        validateattributes(str2double(newVal),{'numeric'},...
        {'scalar','positive'},'','MaxContigSamples');
        if~isempty(newVal)
            Output=true;
        end
    end
end

function out=locEvalOneOutput(in)


    try
        assert(ischar(in),'Input must be a character array')
        out=evalin('base',in);
        if isnumeric(out)
            out=num2str(out);
        end
    catch
        out=[];
    end
end

function locSetDependentFields(cs,iointerfaceName,fieldName,extmodeProtocolInfo)


    switch fieldName
    case{'HostInterface'}
        if isequal(extmodeProtocolInfo.HostInterface,'Simulink')&&...
            isfield(extmodeProtocolInfo,'LoggingBufferAuto')
            extmodeProtocolInfo.LoggingBufferAuto=true;
        else
            extmodeProtocolInfo.LoggingBufferAuto=false;
        end
        codertarget.data.setParameterValue(cs,iointerfaceName,extmodeProtocolInfo);
    end
end
