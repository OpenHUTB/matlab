function varargout=sfunbuilderports(varargin)




    Action=varargin{1};
    blockHandle=varargin{2};

    switch(Action)
    case 'Create'



        majority=varargin{3};
        iP=varargin{4};
        oP=varargin{5};
        param=varargin{6};
        AppData=varargin{7};

        [iP,oP,param]=addBusPortInfo(iP,oP,param);
        [iP,oP,param]=sfcnbuilder.renamePortInfo(iP,oP,param);


        if(~isempty(iP.Name)&&~strcmp(iP.Name{1},'ALLOW_ZERO_PORTS'))
            AppData.SfunWizardData.InputPorts=iP;
        end

        if(~isempty(oP.Name)&&~strcmp(oP.Name{1},'ALLOW_ZERO_PORTS'))
            AppData.SfunWizardData.OutputPorts=oP;
        end


        try
            if(~isempty(param.Name)&&~isempty(param.Name{1}))


                AppData.SfunWizardData.Parameters=setParamsValues(AppData,param);
            end
        catch

        end
        varargout{1}=AppData;

    case 'GetPortsInfo'



        AppData=varargin{3};
        [majority,inputPortsInfo,outputPortsInfo,parametersInfo]=getPortsInfo(AppData);
        varargout{1}=majority;
        varargout{2}=inputPortsInfo;
        varargout{3}=outputPortsInfo;
        varargout{4}=parametersInfo;

    case 'UpdatePortsInfo'

        majority=varargin{3};
        iP=varargin{4};
        oP=varargin{5};
        param=varargin{6};
        [majority,iP,oP,param]=updatePortsInfo(majority,iP,oP,param);
        varargout={majority,iP,oP,param};

    otherwise
        DAStudio.error('Simulink:blocks:SFunctionBuilderInvalidInput');
    end
end

function[majority,inPortsInfo,outPortsInfo,paramInfo]=updatePortsInfo(majr,ip,op,pp)

    portsInfoFields={'Name','DataType','Dims','Dimensions','Complexity','Frame',...
    'Bus','Busname','IsSigned','WordLength','FixPointScalingType',...
    'FractionLength','Slope','Bias'};
    portsInfoDefault={'ALLOW_ZERO_PORTS','0','0','0','0','0','0','0',...
    '0','1','8','0','3','2^-3','0'};

    paramInfoFields={'Name','DataType','Complexity'};
    paramInfoDefault={'','',''};

    majority=majr;
    if isempty(majority)||~any(strcmp(majority,{'Column','Row','Any'}))
        majority='Column';
    end
    inPortsInfo=ip;
    for k=1:length(ip.Name)
        for j=1:length(portsInfoFields)
            if~isfield(inPortsInfo,portsInfoFields{j})||k>length(inPortsInfo.(portsInfoFields{j}))
                inPortsInfo.(portsInfoFields{j}){k}=portsInfoDefault{j};
            end
        end
    end

    outPortsInfo=op;
    for k=1:length(op.Name)
        for j=1:length(portsInfoFields)
            if~isfield(outPortsInfo,portsInfoFields{j})||k>length(outPortsInfo.(portsInfoFields{j}))
                outPortsInfo.(portsInfoFields{j}){k}=portsInfoDefault{j};
            end
        end
    end

    paramInfo=pp;
    for k=1:length(pp.Name)
        for j=1:length(paramInfoFields)
            if~isfield(paramInfo,paramInfoFields{j})||k>length(paramInfo.(paramInfoFields{j}))
                paramInfo.(paramInfoFields{j}){k}=paramInfoDefault{j};
            end
        end
    end
end

function[majority,inPortsInfo,outPortsInfo,parametersInfo]=getPortsInfo(appData)


    majority=appData.SfunWizardData.Majority;
    inPortsInfo=appData.SfunWizardData.InputPorts;
    outPortsInfo=appData.SfunWizardData.OutputPorts;
    parametersInfo=appData.SfunWizardData.Parameters;

    intputPortNum=nnz(inPortsInfo.Name~=""&~strcmp(inPortsInfo.Name,'ALLOW_ZERO_PORTS'));
    ouputPortNum=nnz(outPortsInfo.Name~=""&~strcmp(outPortsInfo.Name,'ALLOW_ZERO_PORTS'));

    if intputPortNum==0
        inPortsInfo.Name{1}='ALLOW_ZERO_PORTS';
        inPortsInfo.DataType{1}='0';
        inPortsInfo.Dims{1}='0';
        inPortsInfo.Dimensions{1}='0';
        inPortsInfo.Complexity{1}='0';
        inPortsInfo.Frame{1}='0';
        inPortsInfo.Bus{1}='0';
        inPortsInfo.Busname{1}='0';
        inPortsInfo.IsSigned{1}='1';
        inPortsInfo.WordLength{1}='8';
        inPortsInfo.FixPointScalingType{1}='0';
        inPortsInfo.FractionLength{1}='3';
        inPortsInfo.Slope{1}='2^-3';
        inPortsInfo.Bias{1}='0';
    else
        for k=1:intputPortNum

            if strcmp(char(inPortsInfo.Bus{k}),'off')
                inPortsInfo.Busname{k}='';
            elseif~slfeature('slBusArraySFBuilder')
                inPortsInfo.Dimensions{k}='[1, 1]';
            end

            if strcmp(char(inPortsInfo.DataType{k}),'fixpt')||strcmp(char(inPortsInfo.DataType{k}),'cfixpt')
            else
                inPortsInfo.IsSigned{k}='0';
                inPortsInfo.WordLength{k}='8';
                inPortsInfo.FixPointScalingType{k}='1';
                inPortsInfo.FractionLength{k}='9';
                inPortsInfo.Slope{k}='0.125';
                inPortsInfo.Bias{k}='0';
            end
        end
    end

    if ouputPortNum==0
        outPortsInfo.Name{1}='ALLOW_ZERO_PORTS';
        outPortsInfo.DataType{1}='0';
        outPortsInfo.Dims{1}='0';
        outPortsInfo.Dimensions{1}='0';
        outPortsInfo.Complexity{1}='0';
        outPortsInfo.Frame{1}='0';
        outPortsInfo.Bus{1}='0';
        outPortsInfo.Busname{1}='0';
        outPortsInfo.IsSigned{1}='1';
        outPortsInfo.WordLength{1}='8';
        outPortsInfo.FixPointScalingType{1}='0';
        outPortsInfo.FractionLength{1}='3';
        outPortsInfo.Slope{1}='2^-3';
        outPortsInfo.Bias{1}='0';
    else
        for k=1:ouputPortNum

            if strcmp(char(outPortsInfo.Bus{k}),'off')
                outPortsInfo.Busname{k}='';
            elseif~slfeature('slBusArraySFBuilder')
                outPortsInfo.Dimensions{k}='[1, 1]';
            end

            if strcmp(char(outPortsInfo.DataType{k}),'fixpt')||strcmp(char(outPortsInfo.DataType{k}),'cfixpt')
            else
                outPortsInfo.IsSigned{k}='1';
                outPortsInfo.WordLength{k}='8';
                outPortsInfo.FixPointScalingType{k}='1';
                outPortsInfo.FractionLength{k}='3';
                outPortsInfo.Slope{k}='0.125';
                outPortsInfo.Bias{k}='0';
            end
        end
    end

end

function param=setParamsValues(AppData,param)
    useWizardDataParam=false;
    if~isempty(param.Name{1})
        if(isfield(AppData.SfunWizardData.Parameters,'Value')&&~isempty(AppData.SfunWizardData.Parameters.Value{1}))
            param.Value=AppData.SfunWizardData.Parameters.Value;
            useWizardDataParam=true;
        else
            for k=1:length(param.Name)
                param.Value{k}='';
            end
        end
    end

    blkParams=get_param(AppData.inputArgs,'Parameters');


    pat={'\[','\]'};
    loc=regexp(blkParams,pat);
    if length(loc{1})==length(loc{1})
        for k=1:length(loc{1})
            startIdx=loc{1}(k);
            endIdx=loc{2}(k);
            noCommas=strrep(blkParams(startIdx:endIdx),',','|');
            blkParams=strrep(blkParams,blkParams(startIdx:endIdx),noCommas);
        end
    end
    if~isempty(param.Name{1})
        if~useWizardDataParam

            param.Value=strread(blkParams,'%s','delimiter',',');

            param.Value=strrep(param.Value,'|',',');

        end
    end
end

function[Slope]=getSlope(Str,appData)
    Slope=sprintf('%0.19g',2^-3);

    try
        Slope=eval(Str);
        Slope=sprintf('%0.19g',Slope(1));
    catch

        appData.SfunBuilderPanel.fCompileStatsTextArea.setText(DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidSlope'));

        DAStudio.error('Simulink:blocks:SFunctionBuilderInvalidSlope');
    end
end

function portsInfo=configueFixPtAttributes(appData,portsInfo,k,port_mode)








    if(port_mode==0)
        FxPtAtt=[];
    else
        FxPtAtt=[];
    end











end

function[iP,oP,param]=addBusPortInfo(iP,oP,param)
    if~isfield(iP,'Bus')
        iP.Bus={};
        oP.Bus={};
        iP.Busname={};
        oP.Busname={};

        for i=1:length(iP.Name)
            iP.Bus=[iP.Bus,'off'];
            iP.Busname=[iP.Busname,{''}];
        end

        for i=1:length(oP.Name)
            oP.Bus=[oP.Bus,'off'];
            oP.Busname=[oP.Busname,{''}];
        end
    end
end
