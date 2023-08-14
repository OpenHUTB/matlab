function[dataStruct,requestId]=mlfbGetBackendData(varargin)


    dataStruct=struct();


    if nargin==1

        dataArgs=varargin{1};
        assert(isa(dataArgs,'com.mathworks.toolbox.coder.mlfb.BackendDataArgs'));
        requestId=int64(dataArgs.getRequestId());

        if isempty(coder.internal.mlfb.gui.CodeViewManager.get(dataArgs.getCodeViewId()))

            return;
        end

        dataKeys=cell(dataArgs.getDataKeys().toArray());
        sudId=coder.internal.mlfb.idForBlock(dataArgs.getSudId());
        mlfbId=coder.internal.mlfb.idForBlock(dataArgs.getBlockId());
        allIds=coder.internal.mlfb.idForBlock(dataArgs.getAllIds());
        runName=char(dataArgs.getRunName());
    else

        narginchk(6,6);
        thisName=mfilename();

        validateattributes(varargin{1},{'cell'},{},thisName,'dataKeys');
        dataKeys=varargin{1};
        sudId=validateBlockArg(varargin{2},thisName,'sudId');
        mlfbId=validateBlockArg(varargin{3},thisName,'mlfbId');
        allIds=validateBlockArg(varargin{4},thisName,'allIds');
        validateattributes(varargin{5},{'char','double'},{},thisName,'runName');
        runName=varargin{5};
        requestId=int64(-1);
    end



    import('coder.internal.mlfb.gui.MlfbUtils');
    import com.mathworks.toolbox.coder.mlfb.BackendDataKey;
    reports=coder.internal.mlfb.createBlockMap();

    for i=1:numel(dataKeys)
        dataKey=dataKeys{i};
        assert(isa(dataKey,'com.mathworks.toolbox.coder.mlfb.BackendDataKey'));

        output={};

        switch char(dataKey)
        case char(BackendDataKey.COMPILATION_REPORT)
            output=populateReportMap(reports,mlfbId);
            output=output{1};
        case char(BackendDataKey.RUN_RESULTS)
            [output{1:3}]=getSimResults(mlfbId,runName);
        case char(BackendDataKey.SHARED_SETTINGS)
            output=readCurrentSettings(sudId);
        case char(BackendDataKey.RUNS)
            [runs,lastUpdated]=MlfbUtils.getRunsForBlock(mlfbId);
            output={runs,lastUpdated};
        case char(BackendDataKey.REPLACEMENTS)
            output=getReplacementsXml(sudId,allIds);
        case char(BackendDataKey.CONVERTED_VARIANT_INFO)
            fixptId=MlfbUtils.getFixedPointVariantId(mlfbId);
            if~isempty(fixptId)
                output=createJavaBlockInfo(fixptId);
            end
        case char(BackendDataKey.BLOCK_ENABLED_STATES)
            output=getVariantEnabledStates(mlfbId);
        case char(BackendDataKey.INACTIVE_COMPILATION_REPORTS)
            output=populateReportMap(reports,allIds{:});
        case char(BackendDataKey.APPLY_ERRORS)
            output=getPendingApplyErrors(allIds);
        case char(BackendDataKey.UNSUPPORTED_FUNCTIONS)
            output=getUnsupportedFunctions(allIds);
        otherwise
            error('Unsupported data key ''%s''',char(dataKey));
        end

        dataStruct.(char(dataKey.getStructField()))=output;
    end
end




function settings=readCurrentSettings(sudSid)
    import com.mathworks.toolbox.coder.mlfb.fpt.SharedSetting;
    import('coder.internal.mlfb.FptSetting');

    fpt=coder.internal.mlfb.FptFacade.getInstance();
    settings=struct();

    appendToStruct('SAFETY_MARGIN',FptSetting.SafetyMargin,'double');
    appendToStruct('WORD_LENGTH',FptSetting.WordLength,'int32');
    appendToStruct('FRACTION_LENGTH',FptSetting.FractionLength,'int32');
    appendToStruct('SIGNEDNESS',FptSetting.ProposeSignedness,'logical');
    appendToStruct('PROPOSE_FRACTION_LENGTH',FptSetting.ProposeWordLength,@(v)~logical(v));

    fimathValue=coder.internal.MLFcnBlock.Float2FixedManager.getSudFimath(sudSid);
    if isa(fimathValue,'embedded.fimath')
        fimathValue=tostring(fimathValue);
    end

    if isempty(fimathValue)

        fimathValue=coder.internal.MLFcnBlock.Float2FixedManager.getFimath(sudSid);
    end

    assert(ischar(fimathValue));

    settings.(char(SharedSetting.FIMATH.getStructField()))=fimathValue;

    function appendToStruct(sharedSettingConstId,setting,type)
        value=fpt.getSettingValue(setting);
        if~isempty(type)
            if isa(type,'function_handle')
                assert(nargin(type)==1&&abs(nargout(type))==1);
                value=type(value);
            else
                assert(ischar(type));
                value=cast(value,type);
            end
        end

        import com.mathworks.toolbox.coder.mlfb.fpt.SharedSetting;
        sharedSetting=SharedSetting.(sharedSettingConstId);
        settings.(char(sharedSetting.getStructField()))=value;
    end
end

function reports=populateReportMap(reportMap,varargin)
    assert(isa(reportMap,'containers.Map'));
    reports=cell(size(varargin));

    for i=1:numel(varargin)
        id=varargin{i};
        if reportMap.isKey(id)
            report=reportMap(id);

            reportMap.remove(id);
        else
            report=getReport(id);
        end
        reportMap(id)=report;
        reports{i}=report;
    end
end

function output=getReport(mlfb)
    try
        reportFunc=@coder.internal.MLFcnBlock.Float2FixedManager.buildFloatingPointCode;
        [output{1:nargout(reportFunc)}]=reportFunc(mlfb);
        output{1}=remapScriptPaths(output{1},mlfb);
    catch me %#ok<NASGU>
        output={[],'',[],true,{},''};
    end
end

function[runName,output,errorMessage]=getSimResults(mlfb,runName)
    output=[];
    runName=char(runName);
    repository=fxptds.FPTRepository.getInstance();
    dataset=repository.getDatasetForSource(mlfb.ModelName);
    errorMessage='';

    if isempty(runName)||~isValidRun(runName)
        [~,runName]=coder.internal.mlfb.gui.MlfbUtils.getRunsForBlock(mlfb);
    end

    if isempty(runName)||~isValidRun(runName)
        runName='';
        return;
    end

    try
        simFunc=@coder.internal.MLFcnBlock.Float2FixedManager.getSimulationResults;
        [fcnVarsInfo,expressions,coverageInfo,errorMessage,messages]=...
        simFunc(mlfb,runName);
        if isempty(fcnVarsInfo)
            fcnVarsInfo={};
        end
        output={remapSimVarInfos(fcnVarsInfo,mlfb),expressions,...
        coverageInfo,'',messages,runName};
    catch me
        coder.internal.gui.asyncDebugPrint(me);
    end

    function valid=isValidRun(someRunName)
        DataLayer=fxptds.DataLayerInterface.getInstance();
        valid=any(ismember(DataLayer.getAllRunNamesWithResults(dataset),someRunName));
    end
end

function blockInfo=createJavaBlockInfo(id)
    if~isempty(id)
        blockInfo=coder.internal.mlfb.gui.MlfbUtils.getBlockInfo(id);
    else
        blockInfo=[];
    end
end

function enabledStates=getVariantEnabledStates(origId)
    import('coder.internal.mlfb.gui.MlfbUtils');
    origEnabled=MlfbUtils.isBlockChartEnabled(origId);
    fixptId=MlfbUtils.getFixedPointVariantId(origId);
    fixptEnabled=~isempty(fixptId)&&MlfbUtils.isBlockChartEnabled(fixptId);
    enabledStates={origEnabled,fixptEnabled};
end

function errors=getPendingApplyErrors(ids)
    errors=cell(numel(ids),1);
    for i=1:numel(ids)
        id=ids{i};
        errors{i}={id.toJava(),coder.internal.MLFcnBlock.Float2FixedManager.getApplyErrors(id)};
    end
end

function unsupported=getUnsupportedFunctions(ids)
    functionMap=coder.internal.MLFcnBlock.Float2FixedManager.getAllUnSupportedFcnInfos(ids);
    ids=functionMap.keys();
    unsupported=cell(numel(ids),1);

    for i=1:numel(ids)
        id=ids{i};
        unsupported{i}={id.toJava(),functionMap(id)};
    end
end

function allXml=getReplacementsXml(sud,ids)
    import('coder.internal.MLFcnBlock.Float2FixedManager');

    overrideXmls=cell(numel(ids),1);
    for i=1:numel(ids)
        id=ids{i};
        overrideXmls{i}={id.toJava(),Float2FixedManager.getFunctionReplacementsForBlock(id,true)};
    end

    allXml={Float2FixedManager.getFunctionReplacementsForBlock(sud,false),overrideXmls};
end

function reportStruct=remapScriptPaths(reportStruct,mlfb)
    if isempty(reportStruct)
        return;
    end

    assert(isstruct(reportStruct)&&isfield(reportStruct,'Scripts')&&...
    isa(mlfb,'coder.internal.mlfb.BlockIdentifier'));

    scripts=reportStruct.Scripts;
    realScriptPath=['#',mlfb.SID];

    for i=1:numel(scripts)
        scriptPath=reportStruct.Scripts(i).ScriptPath;
        if~isempty(scriptPath)&&strcmp(scriptPath(1),'#')

            reportStruct.Scripts(i).ScriptPath=realScriptPath;
        end
    end

    if isfield(reportStruct,'FixedPointVariableInfo')
        for i=1:length(reportStruct.FixedPointVariableInfo)

            if length(reportStruct.FixedPointVariableInfo{i})<3
                continue;
            end
            scriptPath=reportStruct.FixedPointVariableInfo{i}{3};
            if~isempty(scriptPath)&&strcmp(scriptPath(1),'#')

                reportStruct.FixedPointVariableInfo{i}{3}=realScriptPath;
            end
        end
    end
end

function varInfos=remapSimVarInfos(varInfos,mlfb)
    assert(iscell(varInfos)&&isa(mlfb,'coder.internal.mlfb.BlockIdentifier'));

    realScriptPath=['#',mlfb.SID];

    for i=1:numel(varInfos)
        scriptPath=varInfos{i}{3};
        if~isempty(scriptPath)&&strcmp(scriptPath(1),'#')

            varInfos{i}{3}=realScriptPath;
        end
    end
end

function blockArg=validateBlockArg(blockArg,funcName,argName)
    if iscell(blockArg)
        cellfun(@validateSingleBlockArg,blockArg);
    else
        validateSingleBlockArg(blockArg);
    end

    function validateSingleBlockArg(singleArg)
        validateattributes(singleArg,{'char','numeric','DAStudio.Object',...
        'coder.internal.mlfb.BlockIdentifier','com.mathworks.toolbox.coder.mlfb.BlockId'},...
        {'nonempty'},funcName,argName);
    end
end