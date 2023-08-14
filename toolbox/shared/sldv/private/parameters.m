function out=parameters(method,modelH,varargin)





    switch(lower(method))
    case 'hasparameters'
        [~,params]=getParamsFromTestComponent();
        if isempty(params)
            out=false;
        else
            out=true;
        end

    case 'isvalid'
        [out,params]=getParamsFromTestComponent();%#ok<ASGLU> 

    case 'list'
        [status,params]=getParamsFromTestComponent();
        if status
            if isempty(params)
                out={};
            else
                out=fieldnames(params);
            end
        else
            out=[];
        end

    case 'getall'
        [~,params]=getParamsFromTestComponent();
        out=params;

    case 'clearcachedparams'
        testComp=Sldv.Token.get.getTestComponent;
        if~isempty(testComp)
            testComp.tunableParamsAndConstraints.Constraints.singleParamConstraints=[];
        end
        out=[];

    case 'addparamstoharness'
        status=addParamstoWorkspace(modelH,varargin{1},varargin{2});
        out=status;

    case 'init'
        modelName=gcs;
        modelH=get_param(modelName,'Handle');
        out=instantiateParams(modelH);

    case 'stop'
        modelH=get_param(gcs,'Handle');
        out=restoreParams(modelH);
    case 'setparameterconfiguration'
        testComp=Sldv.Token.get.getTestComponent;
        out=setParameterConfiguration(modelH,testComp,varargin{1},varargin{2});

    case 'populateparameters'
        if nargin<3
            params=[];
            startUpParamsNames={};
            startupBlkHs=[];
        else
            params=varargin{1};
            startUpParamsNames=varargin{2};
            startupBlkHs=varargin{3};
        end
        testComp=Sldv.Token.get.getTestComponent;
        out=populateParamsForAnalysis(testComp,modelH,params,...
        startUpParamsNames,startupBlkHs);

    case 'getallmultiparamconstraints'
        out=getAllMultiParamConstraintsFromTestComp();

    otherwise
        error(message('Sldv:Parameters:UnknownMethod'));
    end
end

function status=setParameterConfiguration(modelH,testComp,startUpParamsNames,startupBlkHs)



    if isempty(testComp)
        status=true;
        return;
    end

    options=testComp.activeSettings;
    parametersToTune=[];

    if slfeature('DVCodeAwareParameterTuning')













        parameterOpts.Parameters=options.Parameters;
        parameterOpts.ParametersUseConfig=options.ParametersUseConfig;
        parameterOpts.ParameterConfiguration=options.ParameterConfiguration;
        designModelH=testComp.analysisInfo.designModelH;





        if strcmp(parameterOpts.Parameters,'on')&&...
            strcmp(parameterOpts.ParametersUseConfig,'on')&&...
            ~strcmp(parameterOpts.ParameterConfiguration,'UseParameterTable')&&...
            ~isCodeAwareParamTuningOpts(options)

            sldvshareprivate('avtcgirunsupcollect','push',modelH,...
            'sldv_info',getString(message('Sldv:Parameters:ParameterSyncToParameterTable')),...
            'Sldv:Parameters:ParameterSyncToParameterTable');
        elseif strcmp(parameterOpts.Parameters,'on')&&...
            strcmp(parameterOpts.ParametersUseConfig,'off')&&...
            ~strcmp(parameterOpts.ParameterConfiguration,'UseParameterConfigFile')&&...
            ~isCodeAwareParamTuningOpts(options)

            sldvshareprivate('avtcgirunsupcollect','push',modelH,...
            'sldv_info',getString(message('Sldv:Parameters:ParameterSyncToParameterConfigFile',...
            options.ParametersConfigFileName)),...
            'Sldv:Parameters:ParameterSyncToParameterConfigFile');
        end









        stopOnWarning=false;
        switch parameterOpts.ParameterConfiguration
        case 'None'
            parameterOpts.Parameters='off';%#ok<STRNU> 
            status=populateParamsForAnalysis(testComp,modelH,parametersToTune,startUpParamsNames,startupBlkHs);
            return;
        case 'Auto'


            pManager=Sldv.ParameterTuning.Manager(modelH);
            if strcmp(options.TestgenTarget,'Model')

                [status,parametersToTune]=pManager.autoPopulateParameterConstraints(modelH,stopOnWarning);
            else
                topModelName=getTopModelName(modelH,designModelH);

                [status,parametersToTune]=pManager.autoPopulateParameterConstraints(modelH,stopOnWarning,Simulink.ID.getFullName(topModelName));
            end
        case 'DetermineFromGeneratedCode'
            topModelName=getTopModelName(modelH,designModelH);
            pManager=Sldv.ParameterTuning.Manager(modelH);
            cgDirInfo=RTW.getBuildDir(Simulink.ID.getFullName(topModelName));
            ParameterCodeLocation=cgDirInfo.BuildDirectory;
            [status,parametersToTune]=pManager.autoPopulateParameterConstraints(modelH,stopOnWarning,ParameterCodeLocation);
        case 'UseParameterTable'
            parameterOpts.ParametersUseConfig='on';%#ok<STRNU> 
            status=true;
        case 'UseParameterConfigFile'
            parameterOpts.ParametersUseConfig='off';%#ok<STRNU> 
            status=true;
        end
    else









        status=true;
        if isCodeAwareParamTuningOpts(options)
            parametersToTune=[];
        end
    end
    if~status



        return;
    end

    status=populateParamsForAnalysis(testComp,modelH,parametersToTune,...
    startUpParamsNames,startupBlkHs);
end

function out=isCodeAwareParamTuningOpts(options)



    out=strcmp(options.ParameterConfiguration,'Auto')||...
    strcmp(options.ParameterConfiguration,'DetermineFromGeneratedCode');
end

function topModelName=getTopModelName(modelH,designModelH)













    topModelName=Simulink.ID.getFullName(designModelH);
    [isATS,harnessInfo]=sldv.code.xil.CodeAnalyzer.isATSHarnessModel(Simulink.ID.getFullName(modelH));
    if isATS
        topModelName=harnessInfo.model;
    end
end

function[status,params]=getParamsFromTestComponent()
    status=false;
    testComp=Sldv.Token.get.getTestComponent;

    if isempty(testComp)
        params=[];
        return;
    end

    if isempty(testComp.tunableParamsAndConstraints)
        params=[];
        return;
    end

    params=testComp.tunableParamsAndConstraints.Constraints.singleParamConstraints;

    status=true;
end


function validateParams(sldv_params,allVarsUsage,modelH)


    if~isstruct(sldv_params)



        return;
    end




    if isempty(allVarsUsage)
        if~Sldv.xform.MdlInfo.isMdlCompiled(modelH)
            allVarsUsage=Simulink.findVars(get_param(modelH,'name'),...
            'SearchReferencedModels','on');
        else
            allVarsUsage=Simulink.findVars(get_param(modelH,'name'),...
            'SearchReferencedModels','on','SearchMethod','cached');
        end
    end


    variantControlVars=Sldv.utils.getVariantControlVars(get_param(modelH,'name'),allVarsUsage);
    if isempty(variantControlVars)
        variantControlVarNames=[];
    else
        variantControlVarNames=variantControlVars.Name;
    end

    paramNameToObsMap=Sldv.utils.getParamNamesToObsRefMap(modelH);

    fields=fieldnames(sldv_params);

    for i=1:length(fields)


        varUsage=allVarsUsage(strcmp({allVarsUsage.Name},fields{i}));

        varUsage=varUsage(not(strcmp({varUsage.SourceType},'mask workspace')));

        if isKey(paramNameToObsMap,fields{i})
            sldv_error_push(modelH,...
            getString(message('Sldv:Parameters:ParameterCommonToDesignAndObserverNotSupported',fields{i},getfullname(modelH),getfullname(paramNameToObsMap(fields{i})))),...
            'Sldv:Parameters:ParameterCommonToDesignAndObserverNotSupported');
        end

        if~isempty(varUsage)&&~Sldv.utils.checkForStartUpVariantParam(varUsage.Users)


            userBlockTypes=cellfun(@(u)get_param(u,'BlockType'),varUsage.Users,...
            'UniformOutput',false);
            if any(strcmp('Lookup',userBlockTypes))||...
                any(strcmp('Lookup_n-D',userBlockTypes))||...
                any(strcmp('LookupNDDirect',userBlockTypes))||...
                any(strcmp('Interpolation_n-D',userBlockTypes))||...
                any(strcmp('Lookup Table Dynamic',userBlockTypes))||...
                any(strcmp('PreLookup',userBlockTypes))
                sldv_error_push(modelH,...
                getString(message('Sldv:Parameters:LookupTableTuningNotSupported',fields{i})),...
                'Sldv:Parameters:LookupTableTuningNotSupported');
            end

            if any(strcmp(fields{i},variantControlVarNames))
                sldv_error_push(modelH,...
                getString(message('Sldv:Parameters:VariantVarTuningNotSupported',fields{i})),...
                'Sldv:Parameters:VariantVarTuningNotSupported');
            end
        end
    end
end


function evaluated_params=evalParams(sldv_params,modelH)

    if~isstruct(sldv_params)
        evaluated_params={};
        return;
    end

    evaluated_params=sldv_params;
    fields=fieldnames(sldv_params);
    hws=get_param(modelH,'modelworkspace');

    modelWsVars=hws.whos;
    modelWsVarNames=cell(1,length(modelWsVars));
    for idx=1:length(modelWsVars)
        modelWsVarNames{idx}=modelWsVars(idx).name;
    end
    for i=1:length(fields)



        isDeclInBaseWork=existsInGlobalScope(modelH,fields{i});
        if~isDeclInBaseWork
            error(message('Sldv:Parameters:CheckParamInBase',fields{i}));
        end
        isDeclInModelWork=any(strcmp(fields{i},modelWsVarNames));
        if isDeclInModelWork
            error(message('Sldv:Parameters:CheckParamInModelWorkSpace',fields{i},fields{i}));
        end
        for j=1:length(sldv_params)




            currentVal=evalinGlobalScope(modelH,fields{i});
            if isa(currentVal,'Simulink.Parameter')
                currentVal=currentVal.Value;
            end




            if slavteng('feature','BusParameterTuning')
                if~(isstruct(currentVal)||checkAllAllDims(isnumeric(currentVal))||checkAllAllDims(islogical(currentVal)))
                    error(message('Sldv:Parameters:UnsupportedParam',fields{i}));
                elseif isstruct(currentVal)&&length(currentVal)>1


                    error(message('Sldv:Parameters:ArrayOfBusNotSupported',fields{1}));
                elseif~(checkAllAllDims(isreal(currentVal))||isstruct(currentVal))
                    error(message('Sldv:Parameters:UnsupportedComplexParam',fields{i}));
                end
            else
                if~(checkAllAllDims(isnumeric(currentVal))||checkAllAllDims(islogical(currentVal)))
                    error(message('Sldv:Parameters:UnsupportedParam',fields{i}));
                elseif~checkAllAllDims(isreal(currentVal))
                    error(message('Sldv:Parameters:UnsupportedComplexParam',fields{i}));
                end
            end

            [spec,errId]=checkSldvSpecification(sldv_params(j).(fields{i}));
            if isempty(errId)
                evaluated_params(j).(fields{i})=spec;
            else
                error('Sldv:Parameters:CheckSpecification',getString(message(errId)));
            end
        end
    end
end



function out=checkAllAllDims(value)
    out=all(value);
    while~isscalar(out)
        out=all(out);
    end
end



function sldv_params=evalFileParams(file)



    currPath=path;

    [dir,name]=fileparts(file);
    if~isempty(dir)
        addpath(dir);
    end

    isfunction=true;
    funchandle=str2func(name);
    try
        nargout(funchandle);
    catch Mex %#ok<NASGU>
        isfunction=false;
    end

    if isfunction
        params=feval(name);
    else
        currentvars=whos;
        currentvarnames={currentvars.name};
        eval(name);
        newvars=whos;
        newvarnames={newvars.name};
        [~,index]=setdiff(newvarnames,currentvarnames);
        paramsIsfound=false;
        for idx=1:length(index)
            if strcmp(newvars(index(idx)).name,'params')
                paramsIsfound=true;
                break;
            end
        end
        if~paramsIsfound
            params={};
        end
    end

    path(currPath);

    if isempty(params)
        sldv_params={};
    else
        sldv_params=params;
    end
end



function status=addParamstoWorkspace(modelH,sldvData,mdlRefHarn)
    status=true;

    if isempty(sldvData)
        status=false;
        return;
    end



    hws=get_param(modelH,'modelworkspace');
    try
        testcase=hws.evalin('SldvTestCaseParameterValues');
        numExistingParameters=numel(testcase);
    catch Mex %#ok<NASGU
        numExistingParameters=0;
    end

    SimData=Sldv.DataUtils.getSimData(sldvData);
    for i=1:length(SimData)
        testcase(i+numExistingParameters).parameters=getfield(SimData(i),'paramValues');%#ok
    end
    hws.assignin('SldvTestCaseParameterValues',testcase);

    isXIL=Sldv.DataUtils.isXilSldvData(sldvData);

    if isXIL
        mdlRefHarn=true;
    end
    setInitFcn(modelH,mdlRefHarn);
    setStopFcn(modelH,mdlRefHarn);
end



function setStopFcn(modelH,mdlRefHarn)
    method='stop';
    startFcnStr=sprintf('sldvshareprivate(''parameters'',''%s'',[],%s);',method,num2str(mdlRefHarn));
    set_param(modelH,'StopFcn',startFcnStr);
end



function setInitFcn(modelH,mdlRefHarn)
    method='init';
    startFcnStr=sprintf('sldvshareprivate(''parameters'',''%s'',[],%s);',method,num2str(mdlRefHarn));
    set_param(modelH,'InitFcn',startFcnStr);
end


function status=restoreParams(modelH)
    status=true;
    hws=get_param(modelH,'modelworkspace');

    try
        sldvTestCaseParameterBackupValues=hws.evalin('sldvTestCaseParameterBackupValues');
        paramNames=fieldnames(sldvTestCaseParameterBackupValues);
    catch
        status=false;
        return
    end

    for ii=1:numel(paramNames)
        paramName=paramNames{ii};
        paramVal=sldvTestCaseParameterBackupValues.(paramName);
        assigninGlobalScope(modelH,paramName,paramVal);
    end
    hws.assignin('sldvTestCaseParameterBackupValues',[]);
end



function status=instantiateParams(modelH)
    status=true;
    hws=get_param(modelH,'modelworkspace');

    try
        testcase=hws.evalin('SldvTestCaseParameterValues');
    catch Mex %#ok<NASGU>
        testcase=[];
    end

    harnessSource=Sldv.harnesssource.Source.getSource(modelH);

    if~isempty(testcase)&&~isempty(harnessSource)&&ishandle(harnessSource.blockH)
        testCaseIndex=harnessSource.getActiveTestcase;
        SldvParameters=testcase(testCaseIndex).parameters;
        groupedParams=groupParameters(SldvParameters,modelH);
        parameters=fieldnames(groupedParams);



        sldvTestCaseParameterBackupValues=struct();
        for idx=1:length(parameters)
            paramName=parameters{idx};
            if existsInGlobalScope(modelH,paramName)
                currentVal=evalinGlobalScope(modelH,paramName);
                if isa(currentVal,'Simulink.Parameter')
                    sldvTestCaseParameterBackupValues.(paramName)=currentVal;
                    paramVal=copy(currentVal);
                    paramVal.Value=groupedParams.(paramName);
                else
                    sldvTestCaseParameterBackupValues.(paramName)=currentVal;
                    paramVal=groupedParams.(paramName);
                end

                assigninGlobalScope(modelH,paramName,paramVal);
            end
        end

        hws.assignin('sldvTestCaseParameterBackupValues',sldvTestCaseParameterBackupValues);
    else
        status=false;
    end
end


function groupedParams=groupParameters(SldvParameters,modelH)












    groupedParams=struct;
    if~slavteng('feature','BusParameterTuning')
        groupedParams=SldvParameters;
        return;
    end


    counter=0;
    for idx=1:length(SldvParameters)
        paramName=SldvParameters(idx).name;
        if~contains(paramName,'.')
            counter=counter+1;
            groupedParams.(paramName)=SldvParameters(idx).value;
        else
            paramNameHierarchyArr=strsplit(paramName,'.');
            topLvlParamName=paramNameHierarchyArr{1};
            paramStruct=struct;
            if isfield(groupedParams,topLvlParamName)
                paramStruct=groupedParams.(topLvlParamName);
            end
            currentVal=evalinGlobalScope(modelH,topLvlParamName);
            evalParamName=paramName;
            if isa(currentVal,'Simulink.Parameter')
                evalParamName=strjoin({paramNameHierarchyArr{1},'Value',paramNameHierarchyArr{2:end}},'.');
            end
            paramValue=evalinGlobalScope(modelH,evalParamName);
            paramStruct=assignStructParamValue(paramStruct,paramName,paramValue);
            groupedParams.(topLvlParamName)=paramStruct;
        end
    end
end


function currentStruct=assignStructParamValue(paramStruct,paramName,paramValue)







    paramNameArr=strsplit(paramName,'.');
    currentStruct=paramStruct;
    if length(paramNameArr)==1
        currentStruct=paramValue;
        return;
    end
    currentParamName=strjoin(paramNameArr(2:end),'.');
    if isfield(currentStruct,paramNameArr{2})
        currentStruct.(paramNameArr{2})=assignStructParamValue(currentStruct.(paramNameArr{2}),currentParamName,paramValue);
    else
        currentStruct.(paramNameArr{2})=assignStructParamValue(struct(),currentParamName,paramValue);
    end
end

function sigbH=sigbuild_handle(modelH)

    sigbH=find_system(modelH,...
    'SearchDepth',1,...
    'LoadFullyIfNeeded','off',...
    'FollowLinks','off',...
    'LookUnderMasks','all',...
    'BlockType','SubSystem',...
    'PreSaveFcn','sigbuilder_block(''preSave'');');

end



function errmsg=filterEvalParamsEror(errStruct,parametersConfigFileName)

    coreMsg=getString(message('Sldv:Parameters:ErrorInParamConfigFile',parametersConfigFileName));

    msg=errStruct.message;

    if contains(msg,[getString(message('MATLAB:legacy_two_part:error_using')),' ==>'])
        index_cr=strfind(msg,10);
        if~isempty(index_cr)
            msg=msg(index_cr(1)+1:length(msg));
        end
    end
    if contains(msg,'Error: <a href="error:')
        msg=regexprep(msg,'Error: <a href="error:[^"]*">([^<]*)</a>','$1');
    end

    stackNames={errStruct.stack.name};
    relaventStack=errStruct.stack(strcmp(stackNames,strrep(parametersConfigFileName,'.m','')));
    if~isempty(relaventStack)
        lineStr=[' (',getString(message('Sldv:Parameters:Line')),' ',num2str(relaventStack(1).line),'): '];
    else
        lineStr='';
    end


    errmsg=[coreMsg,lineStr,newline,msg];
end




function params=makeParamsStruct(pnames,pconstraints,pchks,modelH)
    params=struct;





    for idx=1:length(pnames)
        if length(pconstraints)<idx||length(pchks)<idx
            error(message('Sldv:Parameters:NoConstraintSet'));
        end
        try
            if strcmp(pchks{idx},'on')



                if isempty(pconstraints{idx})
                    value={};
                else
                    value=evalinGlobalScope(modelH,pconstraints{idx});
                end
                if slavteng('feature','BusParameterTuning')
                    eval(['params.',pnames{idx},'= value;']);%#ok<EVLDOT> 
                else
                    params.(pnames{idx})=value;
                end
            end
        catch
            error(message('Sldv:Parameters:InvalidConstraint',pnames{idx}));
        end
    end
end

function[status,params]=populateParamsForAnalysis(testComp,modelH,params,startUpParamsNames,startupBlkHs)
    status=true;

    if isempty(testComp)
        params=[];
        return;
    end

    options=testComp.activeSettings;


    testComp.tunableParamsAndConstraints=[];
    testComp.tunableParamsAndConstraints.VariantParams={};
    testComp.tunableParamsAndConstraints.Parameters={};

    testComp.tunableParamsAndConstraints.Constraints=[];
    testComp.tunableParamsAndConstraints.Constraints.singleParamConstraints=[];
    testComp.tunableParamsAndConstraints.Constraints.multiParamConstraints={};
    try
        sldv_params=[];
        pnames={};
        if~strcmp(options.ParameterConfiguration,'None')
            if slfeature('DVCodeAwareParameterTuning')&&...
                (strcmp(options.ParameterConfiguration,'Auto')||...
                strcmp(options.ParameterConfiguration,'DetermineFromGeneratedCode'))
                sldv_params=params;
            elseif strcmp(options.ParameterConfiguration,'UseParameterTable')
                pnames=options.ParameterNames;
                pconstraints=options.ParameterConstraints;
                pchecks=options.ParameterUseInAnalysis;
                sldv_params=makeParamsStruct(pnames,pconstraints,pchecks,modelH);
            elseif strcmp(options.ParameterConfiguration,'UseParameterConfigFile')
                sldv_params=evalFileParams(options.ParametersConfigFileName);
            end
        end

        if~isempty(startupBlkHs)&&isempty(startUpParamsNames)
            [startUpParamsNames,allVarsUsage]=Sldv.utils.findStartUpVariantParams(modelH,options);
        else
            allVarsUsage={};
        end

        sldv_params=appendStartUpVariantParams(sldv_params,startUpParamsNames,modelH);

        if~isempty(sldv_params)
            validateParams(sldv_params,allVarsUsage,modelH);

            params=evalParams(sldv_params,modelH);

            testComp.tunableParamsAndConstraints.VariantParams=startUpParamsNames;
            testComp.tunableParamsAndConstraints.Parameters=pnames;

            testComp.tunableParamsAndConstraints.Constraints.singleParamConstraints=params;

            testComp=Sldv.utils.addStartUpVariantConstraintsToTestComp(testComp,modelH,startupBlkHs);%#ok<NASGU>
        end
    catch Mex
        status=false;
        switch Mex.identifier
        case{'Sldv:Parameters:NoConstraintSet',...
            'Sldv:Parameters:InvalidConstraint',...
            'Sldv:Parameters:CheckParamInBase'}
            sldv_error_push(modelH,Mex.message,Mex.identifier);
        case{'SLDD:sldd:DuplicateSymbol'}
            sldv_error_push(modelH,Mex.message,Mex.identifier);
        otherwise
            if strcmp(options.ParameterConfiguration,'UseParameterTable')
                sldv_error_push(modelH,...
                getString(message('Sldv:Parameters:ErrorInParams')),...
                'Sldv:Parameters:ErrorInParams');
            else
                errmsg=filterEvalParamsEror(Mex,options.ParametersConfigFileName);

                sldv_error_push(modelH,errmsg,'Sldv:Compatibility:Parameters');
            end
        end
    end

    if(slfeature('ObserverSLDV')>1)






        try
            obsPortParams=Simulink.findVars(get_param(modelH,'name'),'Regexp','on',...
            'Name','SYN_BLOCK_CONST_TUNABLE_PARAM_*',...
            'FindUsedVars','off',...
            'SourceType','base workspace');
        catch


            obsPortParams=Simulink.findVars(get_param(modelH,'name'),'Regexp','on',...
            'Name','SYN_BLOCK_CONST_TUNABLE_PARAM_*',...
            'FindUsedVars','off',...
            'SourceType','base workspace',...
            'SearchMethod','cached');
        end


        for i=1:length(obsPortParams)
            params.(obsPortParams(i).Name)='[]';
        end
    end
end

function sldv_params=appendStartUpVariantParams(sldv_params,startUpParamsName,modelH)
    if~slavteng('feature','StartupVariantSLDV')||isempty(startUpParamsName)
        return;
    end

    if~isempty(sldv_params)
        for idx=1:numel(startUpParamsName)
            sldv_params.(startUpParamsName{idx})=[];
        end

        return;
    end
    pconstraints(1:numel(startUpParamsName))={'[]'};
    pchecks(1:numel(startUpParamsName))={'on'};

    sldv_params=makeParamsStruct(startUpParamsName,pconstraints,pchecks,modelH);
end

function multiParamConstraints=getAllMultiParamConstraintsFromTestComp()
    multiParamConstraints={};
    testComp=Sldv.Token.get.getTestComponent;

    if isempty(testComp)||isempty(testComp.tunableParamsAndConstraints)
        return;
    end

    multiParamConstraints=testComp.tunableParamsAndConstraints.Constraints.multiParamConstraints;
end



