function[fcnName,fcnText,params,TunableParamStrs,...
    TunableParamTypes,paramTypes,nonTunableParamNames,...
    ctrlPropertyNames]=getMATLABScriptAndParams(this,hC,inlineParams)



    system_name=get_param(hC.SimulinkHandle,'System');

    [TunableParamInputs,TunableParamStrs,TunableParamTypes]=...
    getTunableProperty(this,hC.SimulinkHandle);
    [TunablePropNamesFromPort,ctrlPropertyNames]=...
    getTunablePropNamesFromPort(hC.SimulinkHandle);
    [fcnName,fcnText,params,paramTypes,nonTunableParamNames]=...
    getMATLABScript(this,system_name,...
    numel(hC.PirInputSignals),...
    numel(hC.PirOutputSignals),hC,...
    TunableParamInputs,TunableParamStrs,...
    TunablePropNamesFromPort,...
    ctrlPropertyNames,inlineParams);
end

function[fcnName,fcnText,params,paramTypes,nonTunableParamNames]=...
    getMATLABScript(this,sysObjectName,numIns,numOuts,hC,...
    TunableParamInputs,TunableParamStrs,...
    TunablePropNamesFromPort,...
    ctrlPropertyNames,inlineParams)

    fcnName=[sysObjectName,'_fcn'];
    fcnName=strrep(fcnName,'.','_');

    if numOuts>0
        outputNames=sprintf('y%d, ',1:numOuts);
        outputNames=['[',outputNames(1:end-2),'] = '];
    else
        outputNames='';
    end

    tunable_param_suffix='_tunable_param';
    TunableParamStrs=strcat(TunableParamStrs,tunable_param_suffix);
    if inlineParams

        numIns=numIns-numel(TunableParamStrs);
    end

    numDataIn=numIns-numel(TunablePropNamesFromPort);


    tunablePropInputNames='';
    if numel(TunablePropNamesFromPort)>0
        tunablePropInputNames=[TunablePropNamesFromPort{1},'_prop'];
        for ii=2:numel(TunablePropNamesFromPort)
            tunablePropInputNames=[tunablePropInputNames,','...
            ,TunablePropNamesFromPort{ii},'_prop'];
        end
    end

    if numDataIn>0
        inputNames=sprintf('u%d, ',1:numDataIn);
        inputNames=inputNames(1:end-2);
    else
        inputNames='';
    end


    if isempty(inputNames)||isempty(tunablePropInputNames)
        allInputNames=[inputNames,tunablePropInputNames];
    else
        allInputNames=[inputNames,',',tunablePropInputNames];
    end
    dialogParams=get_param(hC.SimulinkHandle,'DialogParameters');


    fiSettingParams=getFiParams(hC.SimulinkHandle);
    if all(isfield(dialogParams,fiSettingParams))
        dialogParams=rmfield(dialogParams,fiSettingParams);
    end

    TunableParamNames=fieldnames(TunableParamInputs);
    paramsToSkip={'SimulateUsing','LockScale'};
    if~isempty(dialogParams)
        readOnlyAttributes=getReadOnlyAttribute(dialogParams);
        paramNames=fieldnames(dialogParams);
        validInputNames=paramNames(~readOnlyAttributes);
        nonTunableParamNames=setdiff(validInputNames,...
        [TunablePropNamesFromPort(:);TunableParamNames(:);paramsToSkip(:)],'stable');
        nonTunableParamNamesForInput=strcat(nonTunableParamNames,'_prop');
        validInputNames=[TunableParamStrs(:);nonTunableParamNamesForInput(:)];
    else
        validInputNames={};
        nonTunableParamNames={};
    end

    paramInputs=sprintf('%s, ',validInputNames{:});
    if~isempty(paramInputs)
        paramInputs=paramInputs(1:end-2);
        if numIns>0
            paramInputs=[', ',paramInputs];
        end
    end

    if~isempty(fiSettingParams)&&...
        strcmp(get_param(hC.SimulinkHandle,'BlockDefaultFimath'),'Specify Other')
        fimathSetting=this.hdlslResolve('InputFimath',hC.SimulinkHandle);
        fimathParam=fi(0,fimathSetting);
    else
        fimathParam=fi(0);
    end
    if~inlineParams
        if~isempty(paramInputs)||numIns>0
            paramInputs=[paramInputs,', fimathParam'];
        else
            paramInputs='fimathParam';
        end
    end

    [params,paramTypes]=getDialogParams(hC.SimulinkHandle,nonTunableParamNames,...
    dialogParams,ctrlPropertyNames,sysObjectName);


    paramMap=getParamMapForDialogProps(sysObjectName);

    fcnText=sprintf(['%%#codegen\n',...
    'function ',outputNames,fcnName,'(',allInputNames,paramInputs,')\n'...
    ,'%% Copyright 2013 The MathWorks, Inc.\n',...
    '\n',...
    'persistent obj\n',...
    'if isempty(obj)\n',...
    '    obj = ',sysObjectName,';\n']);
    for ii=1:numel(nonTunableParamNames)
        paramName=nonTunableParamNames{ii};
        if paramMap.(nonTunableParamNames{ii}).isDataTypeProperty
            paramName=paramMap.(paramName).Name;
        end
        fcnText=[fcnText...
        ,sprintf(['    obj.',paramName,' = '...
        ,nonTunableParamNames{ii},'_prop;\n'])];
    end
    if~isempty(inputNames)
        inputNames=[', ',inputNames];
    end
    fcnText=[fcnText,sprintf(['end\n',...
    '\n'])];


    for ii=1:numel(TunablePropNamesFromPort)
        fcnText=[fcnText...
        ,sprintf(['obj.',TunablePropNamesFromPort{ii},' = '...
        ,TunablePropNamesFromPort{ii},'_prop;\n'])];
    end


    for ii=1:numel(TunableParamNames)
        fcnText=[fcnText...
        ,sprintf(['obj.',TunableParamNames{ii},' = '...
        ,TunableParamInputs.(TunableParamNames{ii})...
        ,tunable_param_suffix,';\n'])];
    end


    fcnText=[fcnText,sprintf([outputNames,'step(obj',inputNames,');\n',...
    '\n'])];


    params{end+1}=fimathParam;

end

function readOnlyAttributes=getReadOnlyAttribute(dialogParams)
    paramNames=fieldnames(dialogParams);
    readOnlyAttributes=false(1,numel(paramNames));
    for ii=1:numel(paramNames)
        paramName=paramNames{ii};
        paramInfo=dialogParams.(paramName);
        if any(strcmp(paramInfo.Attributes,'read-only'))
            readOnlyAttributes(ii)=true;
        end
    end
end

function[TunablePropNamesFromPort,ctrlPropertyNames]=...
    getTunablePropNamesFromPort(slbh)

    sysObjName=get_param(slbh,'System');
    mc=meta.class.fromName(sysObjName);
    mp=mc.PropertyList;
    ordinals=[];
    ctrlPropSetting=[];
    paramPortTunablePropNames={};
    ctrlPropertyNames={};
    for ii=1:numel(mp)
        if isa(mp(ii),'matlab.system.CustomMetaProp')&&mp(ii).PropertyPortPolicy
            srcSetPolicy=eval([sysObjName,'.',mp(ii).Name,'.','getPolicy(1)']);%#ok<*AGROW>
            if isa(srcSetPolicy,'matlab.system.internal.PropertyOrMethod')


                continue;
            end
            ordinals(end+1)=srcSetPolicy.InputOrdinal;
            ctrlPropertyNames{end+1}=srcSetPolicy.ControlPropertyName;
            ctrlPropSetting(end+1)=...
            strcmp(get_param(slbh,ctrlPropertyNames{end}),'on');
            paramPortTunablePropNames{end+1}=strrep(mp(ii).Name,'Set','');
        end
    end


    ctrlPropSetting=logical(ctrlPropSetting);
    TunablePropNamesFromPort=paramPortTunablePropNames(ctrlPropSetting);




    [~,idx]=sort(ordinals(ctrlPropSetting));
    TunablePropNamesFromPort=TunablePropNamesFromPort(idx);
end

function[params,paramTypes]=getDialogParams(slbh,nonTunableParamNames,...
    dialogParams,ctrlPropertyNames,...
    sysObjectName)


    params=cell(1,numel(nonTunableParamNames));
    paramTypes=cell(1,numel(nonTunableParamNames));


    paramMap=getParamMapForDialogProps(sysObjectName);

    for ii=1:numel(nonTunableParamNames)
        paramName=nonTunableParamNames{ii};
        if any(strcmp(paramName,ctrlPropertyNames))




            params{ii}=false;
            paramTypes{ii}='boolean';
            continue;
        end
        paramVal=get_param(slbh,paramName);
        paramInfo=dialogParams.(paramName);
        paramTypes{ii}=paramInfo.Type;
        if strcmp(paramInfo.Type,'boolean')
            params{ii}=strcmp(paramVal,'on');
        elseif strcmp(paramInfo.Type,'string')&&...
            ~paramMap.(paramName).isDataTypeProperty
            try
                params{ii}=hdlslResolve(paramName,slbh);
            catch
                params{ii}=paramVal;

            end
        elseif paramMap.(paramName).isDataTypeProperty

            dt=matlab.system.display.internal.DataTypeProperty.udtToDataType(paramVal);
            params{ii}=dt;
        else
            params{ii}=paramVal;
        end
    end

end

function fiSettingParams=getFiParams(slbh)


    fiSettingParams={'SaturateOnIntegerOverflow','TreatAsFi',...
    'BlockDefaultFimath','InputFimath'};
    dialogParams=get_param(slbh,'DialogParameters');
    if~all(isfield(dialogParams,fiSettingParams))
        fiSettingParams={};
    end
end

function paramMap=getParamMapForDialogProps(sysObjectName)

    paramMap=struct();
    groups=matlab.system.display.internal.Memoizer.getBlockPropertyGroups(sysObjectName,...
    'DefaultIfError',true);
    dialogProps=matlab.system.ui.getPropertyList(sysObjectName,groups);
    for propInd=1:numel(dialogProps)
        property=dialogProps(propInd);
        paramMap.(property.BlockParameterName)=property;
    end
end

