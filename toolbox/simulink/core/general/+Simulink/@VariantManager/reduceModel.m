function varargout=reduceModel(modelName,varargin)













































































































































































































    try
        [varargout{1:nargout}]=reduceModelImpl(modelName,varargin{:});
    catch excep
        Simulink.variant.reducer.utils.logException(excep);
        throwAsCaller(excep);
    end
end

function varargout=reduceModelImpl(modelName,varargin)
    nargoutchk(0,5);
    [rOptsStruct,cmd]=parseUserInput(modelName,varargin{:});
    calledFromUI=~isempty(rOptsStruct.UIFrameHandle)||rOptsStruct.CalledFromUI;

    if slfeature('VRedRearch')>0
        core=slvariants.internal.reducer.Core();
        core.setReductionOptions(rOptsStruct);
        core.setCommand(cmd);
        core.reduce();
        err=core.getError();
        warns=core.getWarnings();
        reducedModelFullName=core.getReducedModelPath();
        printOutput(calledFromUI,reducedModelFullName,err);
    else
        rMgr=Simulink.variant.reducer.ReductionManager(rOptsStruct);
        rMgr.getOptions().Command=cmd;
        rMgr.reduceModel();
        err=rMgr.Error;
        warns=rMgr.Warnings;
        reducedModelFullName=rMgr.getOptions().RedModelFullName;
        printOutput(calledFromUI,reducedModelFullName,err);
        rMgr.generateReport();
    end

    if nargout>0
        varargout{1}=isempty(err);
    end
    if~calledFromUI
        if~isempty(err)
            throwAsCaller(err);
        end
        return;
    end


    if nargout>1
        varargout{2}=err;
    end

    if nargout>2
        varargout{3}=warns;
    end



    if nargout>3
        varargout{4}=cmd(3:end);
    end

    if nargout>4
        varargout{5}=reducedModelFullName;
    end
end

function printOutput(calledFromUI,redMdlFullPath,err)
    if calledFromUI
        return;
    end
    if~isempty(err)
        fprintf(newline);
        return;
    end


    if feature('Hotlinks')
        commandToCdAndOpenRedModel=[...
        'Simulink.variant.reducer.utils.cdAndOpenReducedModel(''',redMdlFullPath,''')'];
        successMsg=message('Simulink:Variants:VariantReducerSuccessDiffModelNames',...
        ['<a href="matlab:',commandToCdAndOpenRedModel,'">',redMdlFullPath,'</a>']);
    else
        successMsg=message('Simulink:Variants:VariantReducerSuccessDiffModelNames',...
        redMdlFullPath);
    end
    successMsg=successMsg.getString();

    matlab.internal.display.printWrapped(sprintf('%s',successMsg));
end

function[rOptsStruct,command]=parseUserInput(modelName,varargin)

    defaultConfig={};
    defaultOutdir='';


    oldConfigParamName='Configurations';
    outputFolderParamName='OutputFolder';
    namedconfigParamName='NamedConfigurations';
    varconfigParamName='VariableConfigurations';
    fullrangeParamName='FullRangeVariables';
    varGroupParamName='VariableGroups';



    persistent p
    if isempty(p)
        p=Simulink.variant.reducer.utils.getReducerInputParser();
    end


    numOptionalInputs=numel(varargin);






    usePositionArg=(numOptionalInputs==1)||...
    ((numOptionalInputs==2)&&((iscell(varargin{1})||isstruct(varargin{1}))||~any(strcmpi(varargin{1},getOptionalArgs(p)))));


    if usePositionArg



        configInfos=defaultConfig;
        outputDir=defaultOutdir;
        switch numOptionalInputs
        case 2
            configInfos=varargin{1};
            outputDir=varargin{2};
        case 1
            configInfos=varargin{1};
        end
        isConfigVarSpec=isa(configInfos,'struct')||(iscell(configInfos)&&numel(configInfos)>0&&isa(configInfos{1},'struct'));

        if isempty(configInfos)&&(isa(configInfos,'double')||isa(configInfos,'char')||isa(configInfos,'cell'))





            configInfos='';
            pvArgs={oldConfigParamName,configInfos,outputFolderParamName,outputDir};
        elseif isConfigVarSpec
            configInfos=Simulink.variant.reducer.utils.preprocessConfigInfo(configInfos,true);
            pvArgs={varGroupParamName,configInfos,outputFolderParamName,outputDir};
        else
            pvArgs={namedconfigParamName,configInfos,outputFolderParamName,outputDir};
        end
    else
        pvArgs=varargin;
    end

    if slfeature('VRedReduceForCodegen')<1&&~isempty(pvArgs)

        props=pvArgs(1:2:end);
        if any(strcmp(props,'CompileMode'))


            throwAsCaller(MException(message('Simulink:VariantReducer:InvalidOption','CompileMode')));
        end
    end

    try
        parse(p,modelName,pvArgs{:});
    catch ME
        throwAsCaller(ME);
    end



    if~isvarname(modelName)
        throwAsCaller(MException(message('Simulink:utility:InvalidBlockDiagramName')));
    end


    modelName=i_convertStringsToChar(modelName);
    validateSignals=p.Results.PreserveSignalAttributes;
    outputDir=i_convertStringsToChar(p.Results.OutputFolder);

    suffix=i_convertStringsToChar(p.Results.ModelSuffix);
    verbose=p.Results.Verbose;
    generateReport=p.Results.GenerateSummary;
    fullrangeVars=p.Results.FullRangeVariables;


    compileMode=p.Results.CompileMode;
    skipFiles=p.Results.ExcludeFiles;

    configProps={oldConfigParamName,namedconfigParamName,varconfigParamName,fullrangeParamName,varGroupParamName};






    paramsSpec=setdiff(configProps,p.UsingDefaults);
    paramsSpecAllowed={{fullrangeParamName,varconfigParamName},...
    {fullrangeParamName,varGroupParamName}};



    if numel(paramsSpec)==2
        if~any(cellfun(@(x)all(strcmp(x,paramsSpec)),paramsSpecAllowed))
            throwAsCaller(MException(message('Simulink:Variants:ReducerInvalidConfigs',paramsSpec{1},paramsSpec{2})));
        end
    elseif numel(paramsSpec)>2
        throwAsCaller(MException(message('Simulink:Variants:ReducerInvalidConfigs',paramsSpec{1},paramsSpec{2})));
    end

    isConfigNameSpec=~any(strcmp(p.UsingDefaults,namedconfigParamName));
    isVarConfigSpec=~any(strcmp(p.UsingDefaults,varconfigParamName));
    isVarGroupSpec=~any(strcmp(p.UsingDefaults,varGroupParamName));
    isConfigVarSpec=isVarConfigSpec||isVarGroupSpec||...
    (~any(strcmp(p.UsingDefaults,fullrangeParamName)));

    varNameSimParamExpressionMap=containers.Map();

    if isConfigNameSpec
        configInfos=p.Results.NamedConfigurations;
        configInfos=i_convertStringsToChar(configInfos);
        if~validateNamedConfigs(configInfos)
            throwAsCaller(MException(message('Simulink:Variants:ReducerInvalidNamedConfig')));
        end
    elseif isConfigVarSpec
        if isVarConfigSpec
            configInfos=p.Results.VariableConfigurations;
        else
            configInfos=p.Results.VariableGroups;
        end




        if~((isvector(configInfos))||(isempty(configInfos)))


            throwAsCaller(MException(message('Simulink:Variants:ReducerInvalidVarConfig')));
        end

        configInfos=i_convertStringsToChar(configInfos);
        try
            [isValid,configInfos]=validateAllVarConfig(configInfos,modelName,varNameSimParamExpressionMap);
        catch ex
            throwAsCaller(ex);
        end
        if~isValid
            throwAsCaller(MException(message('Simulink:Variants:ReducerInvalidVarConfig')));
        end

        configInfos=Simulink.variant.reducer.utils.preprocessConfigInfo(configInfos,false);






        fullrangeVars=i_convertStringsToChar(fullrangeVars);
        try
            isFullRangeValid=validateVarConfigs(fullrangeVars,modelName,varNameSimParamExpressionMap);
        catch ex
            throwAsCaller(ex);
        end
        if~isFullRangeValid
            throwAsCaller(MException(message('Simulink:VariantReducer:InvalidFullRangeSpec')));
        end

        errid='Simulink:VariantReducer:InconsistentSlexprDefinitions';
        err=Simulink.variant.utils.getInconsistentSlexprError(varNameSimParamExpressionMap,numel(configInfos),errid);
        if~isempty(err)
            throw(err);
        end

        try




            configInfos=Simulink.variant.reducer.utils.removeDuplicateVars(configInfos,fullrangeVars);
        catch ex
            throwAsCaller(ex);
        end

    else
        configInfos=p.Results.Configurations;
        isConfigVarSpec=isa(configInfos,'struct')||(iscell(configInfos)&&numel(configInfos)>0&&isa(configInfos{1},'struct'));
        if isConfigVarSpec
            configInfos=Simulink.variant.reducer.utils.preprocessConfigInfo(configInfos,true);
        end
    end


    redModelName=strcat(modelName,suffix);
    if~isvarname(redModelName)
        throwAsCaller(MException(message('Simulink:Variants:ReducerInvalidSuffix',suffix,redModelName)));
    end

    frameHandle=p.Results.FrameHandle;
    calledFromUI=p.Results.CalledFromUI;


    rOptsStruct=Simulink.variant.reducer.ReductionOptions.getDefaultInputStruct(modelName);


    rOptsStruct.ConfigInfos=configInfos;
    rOptsStruct.IsConfigVarSpec=isConfigVarSpec;
    rOptsStruct.OutputFolder=outputDir;
    rOptsStruct.ValidateSignals=validateSignals;
    rOptsStruct.Suffix=suffix;
    rOptsStruct.Verbose=verbose;
    rOptsStruct.UIFrameHandle=frameHandle;
    rOptsStruct.CalledFromUI=calledFromUI;
    rOptsStruct.GenerateReport=generateReport;
    rOptsStruct.FullRangeVariables=fullrangeVars;
    rOptsStruct.CompileMode=compileMode;
    rOptsStruct.ExcludeFiles=skipFiles;


    command=Simulink.variant.reducer.getReducerCommand(p);
end


function optionalArgs=getOptionalArgs(p)
    optionalArgs=p.Parameters;

    mdlNameIdx=strcmpi('ModelName',optionalArgs);
    optionalArgs(mdlNameIdx)=[];
end



function[isValid,configInfoModified]=validateAllVarConfig(configInfo,modelName,varNameSimParamExpressionMap)

    configInfoModified=configInfo;








    if isa(configInfo,'struct')
        msg=[];
        [isValid,configInfoModified]=Simulink.variant.reducer.utils.isVarGroupNameSyntaxStructValid(configInfo);
        if isValid
            configInfoFieldNames=fieldnames(configInfo);
            groupNames={configInfo.(configInfoFieldNames{1})};
            configInfo={configInfo.(configInfoFieldNames{2})};
            groupNamesMap=containers.Map('KeyType','char','ValueType','logical');
            repeatedGroupNames='';
            invalidGroupNames='';
            for i=1:numel(groupNames)
                if~groupNamesMap.isKey(groupNames{i})

                    groupNamesMap(groupNames{i})=false;
                    if~isvarname(groupNames{i})
                        invalidGroupNames=[invalidGroupNames,groupNames{i},', '];%#ok<AGROW>
                    end
                elseif~groupNamesMap(groupNames{i})

                    repeatedGroupNames=[repeatedGroupNames,groupNames{i},', '];%#ok<AGROW>
                    groupNamesMap(groupNames{i})=true;
                end
            end


            if~isempty(repeatedGroupNames)
                repeatedGroupNames(end-1:end)=[];
                msg=message('Simulink:VariantReducer:NonUniqueGroupNames',repeatedGroupNames);
            elseif~isempty(invalidGroupNames)
                invalidGroupNames(end-1:end)=[];
                msg=message('Simulink:VariantReducer:InvalidGroupNames',invalidGroupNames);
            end
        else
            sampleStructCommand='[struct(''Name'', ''Group1'', ''VariantControls'', {{''V'', 1, ''W'', 1}}) struct(''Name'', ''Group2'', ''VariantControls'', {{''V'', 2, ''W'', 2}})]';
            msg=message('Simulink:VariantReducer:InvalidVariableGroupNameSyntax',sampleStructCommand);
        end
        if~isempty(msg)
            err=MException(msg);
            throwAsCaller(err);
        end
    end



    allNonCells=all(cellfun(@(x)~iscell(x),configInfo));
    allCells=all(cellfun(@(x)iscell(x),configInfo));
    isValid=allNonCells||allCells;
    if~isValid,return;end



    if allNonCells


        isValid=validateVarConfigs(configInfo,modelName,varNameSimParamExpressionMap);
        return;
    end

    if allCells





        for cellId=1:numel(configInfo)
            isValid=isValid&&validateVarConfigs(configInfo{cellId},modelName,varNameSimParamExpressionMap);
        end

    end
end


function isValid=validateVarConfigs(configInfo,modelName,varNameSimParamExpressionMap)



    isValid=true;
    if isempty(configInfo)
        return;
    end






    if mod(numel(configInfo),2)
        isValid=false;
        return;
    end




    isValid=all(cellfun(@(x)Simulink.variant.utils.isCharOrString(x),configInfo(1:2:end-1)));
    if~isValid,return;end





    varControlVars=configInfo(1:2:end-1);
    varControlVals=configInfo(2:2:end);
    for varId=1:numel(varControlVars)
        isVarNameValid=isvarname(varControlVars{varId});






        if~isVarNameValid

            subStrings=regexp(varControlVars{varId},'\.','split');
            isVarNameValid=cellfun(@(x)isvarname(x),subStrings);
            isVarNameValid=all(isVarNameValid);
        end
        isValid=isValid&&isVarNameValid;
        if~isValid
            return;
        end
        if isempty(varControlVals{varId})


            strEmptyVal=varControlVars{varId};
            errid='Simulink:VariantReducer:VarConfigWithEmptyValues';
            err=MException(message(errid,strEmptyVal,modelName));
            throw(err);
        end

        varNameSimParamExpressionForVariableGroupMap=containers.Map;

        if isa(varControlVals{varId},'Simulink.Parameter')
            for valId=1:numel(varControlVals{varId})
                if isa(varControlVals{varId}(valId).Value,'Simulink.data.Expression')
                    Simulink.variant.utils.i_addKeyValueToMap(varNameSimParamExpressionForVariableGroupMap,...
                    varControlVars{varId},{char(varControlVals{varId}(valId).Value.ExpressionString)});
                end
            end
        end
        if~isvector(varControlVals{varId})



            strVarName=varControlVars{varId};
            errid='Simulink:VariantReducer:NonVectorValueInput';
            err=MException(message(errid,strVarName,modelName));
            throw(err);
        end

        errid='Simulink:VariantReducer:InconsistentSlexprDefinitions';
        err=Simulink.variant.utils.getInconsistentSlexprError(varNameSimParamExpressionForVariableGroupMap,1,errid);
        if isempty(err)
            varControlVarsParamExpression=varNameSimParamExpressionForVariableGroupMap.keys;
            for i=1:numel(varControlVarsParamExpression)
                allExpressions=varNameSimParamExpressionForVariableGroupMap(varControlVarsParamExpression{i});
                Simulink.variant.utils.i_addKeyValueWithDupsToMap(varNameSimParamExpressionMap,...
                varControlVarsParamExpression{i},allExpressions{1});
            end
        else
            throw(err);
        end
    end





    isValidVarValueFun=@(x)(Simulink.variant.reducer.utils.isValidControlVariableValue(x));

    function ctrlVarValue=getValueIfSLVarCtrl(ctrlVarValue)


        if isa(ctrlVarValue,'Simulink.VariantControl')
            ctrlVarValue=ctrlVarValue.Value;
        end
    end
    varControlVals=cellfun(@(X)(getValueIfSLVarCtrl(X)),varControlVals,'UniformOutput',false);

    isValidVarValueCellFun=@(X)(all(arrayfun(isValidVarValueFun,X)));
    isVarValValid=cellfun(isValidVarValueCellFun,varControlVals,'UniformOutput',true);
    isValid=all(isVarValValid);
    if~isValid,return;end



    for varId=1:numel(varControlVals)
        if isa(varControlVals{varId},'Simulink.Parameter')
            isValValid=arrayfun(@(x)isscalar(x.Value),varControlVals{varId});
            isValid=isValid&&all(isValValid);
        end
        if~isValid,return;end
    end
end

function isValidConfig=validateNamedConfigs(configInfos)







    isValidConfig=~isempty(configInfos);
    if~isValidConfig
        return;
    end


    if Simulink.variant.utils.isCharOrString(configInfos)
        isValidConfig=true;
        return;
    end




    Simulink.variant.reducer.utils.assert(iscell(configInfos));
    isValid=cellfun(@(x)Simulink.variant.utils.isCharOrString(x),configInfos);
    isValidConfig=all(isValid);
end

function output=i_convertStringsToChar(input)
    if isstring(input)
        output=convertStringsToChars(input);
    elseif iscell(input)
        output=cellfun(@(x)i_convertStringsToChar(x),input,'UniformOutput',false);
    else
        output=input;
    end
end



