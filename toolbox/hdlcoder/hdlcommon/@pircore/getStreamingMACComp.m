

function StrMacComp=getStreamingMACComp(hN,hInSignals,hOutSignals,rndMode,compName,InitValueSetting,initValue,numberOfSamples,opMode,Cbox_ValidOut,Cbox_EndInAndOut,Cbox_StartOut,Cbox_CountOut,PortInString,PortOutString)

    if strcmp(Cbox_ValidOut,'on')
        Cbox_ValidOutFlg=true;
    else
        Cbox_ValidOutFlg=false;
    end

    if strcmp(Cbox_EndInAndOut,'on')
        Cbox_EndInAndOutFlg=true;
    else
        Cbox_EndInAndOutFlg=false;
    end

    if strcmp(Cbox_StartOut,'on')
        Cbox_StartOutFlg=true;
    else
        Cbox_StartOutFlg=false;
    end

    if strcmp(Cbox_CountOut,'on')
        Cbox_CountOutFlg=true;
    else
        Cbox_CountOutFlg=false;
    end

    if(~isa(initValue,'numeric'))
        try
            initValue=str2double(initValue.Value);
        catch
            initValue=str2double(initValue);
        end
    end

    StrMacComp=hN.addComponent2(...
    'kind','streamingmac',...
    'SimulinkHandle',-1,...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'RoundingMode',rndMode,...
    'InitValueSetting',InitValueSetting,...
    'initValue',initValue,...
    'numberofsamples',numberOfSamples,...
    'OpMode',opMode,...
    'Cbox_ValidOut',Cbox_ValidOutFlg,...
    'Cbox_EndInAndOut',Cbox_EndInAndOutFlg,...
    'Cbox_StartOut',Cbox_StartOutFlg,...
    'Cbox_CountOut',Cbox_CountOutFlg,...
    'PortInString',PortInString,...
    'PortOutString',PortOutString);
end
