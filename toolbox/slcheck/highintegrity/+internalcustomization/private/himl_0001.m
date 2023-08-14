function himl_0001

    rec=getNewCheckObject('mathworks.hism.himl_0001',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name='Header format type';
    inputParamList{end}.Type='Enum';
    inputParamList{end}.Entries={'Default','Custom'};
    inputParamList{end}.Enable=true;
    inputParamList{end}.Visible=false;
    inputParamList{end}.setRowSpan([1,1]);
    inputParamList{end}.setColSpan([1,1]);

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name='Custom header format';
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='Description, Input, Output';
    inputParamList{end}.Enable=false;
    inputParamList{end}.Visible=false;
    inputParamList{end}.setRowSpan([1,1]);
    inputParamList{end}.setColSpan([2,4]);

    stdInputParams=Advisor.Utils.Eml.getEMLStandardInputParams(2);

    for i=1:numel(stdInputParams)
        inputParamList{end+1}=stdInputParams{i};
    end

    rec.setInputParametersCallbackFcn(@inputParameterCallback);
    rec.setInputParametersLayoutGrid([3,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function inputParameterCallback(taskObject,~)
    switch class(taskObject)
    case 'ModelAdvisor.Task'
        inputParameters=taskObject.Check.InputParameters;
    case 'ModelAdvisor.ConfigUI'
        inputParameters=taskObject.InputParameters;
    otherwise
        return;
    end

    switch inputParameters{1}.Value
    case 'Default'
        inputParameters{2}.Value='Description, Input, Output';
        inputParameters{2}.Enable=false;
    case 'Custom'
        inputParameters{2}.Enable=true;
    otherwise
        return;
    end

end

function FailingObjs=hCheckAlgo(system)

    FailingObjs=[];
    fcnObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();




    for i=1:length(fcnObjs)
        if~isempty(fcnObjs{i})
            FailingObjs=[FailingObjs;getFailingEMLFunctions(fcnObjs{i},system)];%#ok<AGROW>
        end
    end

end

function FailObjs=getFailingEMLFunctions(eml_obj,system)
    FailObjs=[];

    switch class(eml_obj)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        mt=mtree(eml_obj.Script,'-com','-cell','-comments');
    case 'struct'
        mt=mtree(eml_obj.FileName,'-com','-cell','-file','-comments');
    end

    functionNodes=mt.mtfind('Kind','FUNCTION');

    indices=functionNodes.indices;

    for i=1:length(indices)
        node=functionNodes.select(indices(i));
        [bIsValid,issueIdx]=hasValidFunctionHeader(node,system);
        if~bIsValid
            FailObjs=[FailObjs;getViolationInfoFromNode(eml_obj,node,DAStudio.message(['ModelAdvisor:hism:himl_0001_rec_action',num2str(issueIdx)]))];%#ok<AGROW>
        end
    end
end

function[bResult,issueNum]=hasValidFunctionHeader(FcnNode,system)
    bResult=true;
    issueNum=0;

    mFcnName=FcnNode.Fname.string;


    inVars={};
    mInNode=FcnNode.Ins;
    while~isempty(mInNode)
        nodeText=mInNode.strings;
        if~isempty(nodeText{1})
            inVars{end+1}=nodeText{1};%#ok<AGROW>
        end
        mInNode=mInNode.Next;
    end


    outVars={};
    mOutNode=FcnNode.Outs;
    while~isempty(mOutNode)
        nodeText=mOutNode.strings;
        if~isempty(nodeText{1})
            outVars{end+1}=nodeText{1};%#ok<AGROW>
        end
        mOutNode=mOutNode.Next;
    end


    FcnHeader={};
    fBody=FcnNode.Body;
    while~isempty(fBody)&&strcmp(fBody.kind,'COMMENT')
        nodeText=fBody.strings;
        if~isempty(nodeText{1})
            FcnHeader{end+1}=nodeText{1};%#ok<AGROW>
        end
        fBody=fBody.Next;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    if~isempty(FcnHeader)
        mFcnHeader=strjoin(FcnHeader);
    end

    if strcmp(inputParams{1}.Value,'Custom')

        if isempty(FcnHeader)&&isempty(strtrim(inputParams{2}.Value))
            return;
        end

        headerFormat=split(inputParams{2}.Value,',');
        headerFormat=strtrim(headerFormat);
        for i=1:numel(headerFormat)
            if isempty(regexpi(mFcnHeader,['%\s*',headerFormat{i},'\s+[^%]+'],'once'))
                bResult=false;
                issueNum=5;
                return;
            end
        end
        return;
    end

    if isempty(FcnHeader)
        bResult=false;
        issueNum=1;
        return;
    end


    if isempty(regexpi(mFcnHeader,['%+\s*',mFcnName,'\s[^%]*'],'once'))
        bResult=false;
        issueNum=2;
        return;
    end


    for i=1:numel(inVars)
        if isempty(regexpi(mFcnHeader,['%\s*',inVars{i},'\s+[^%]+'],'once'))
            bResult=false;
            issueNum=3;
            return;
        end
    end


    for i=1:numel(outVars)
        if isempty(regexpi(mFcnHeader,['%\s*',outVars{i},'\s+[^%]+'],'once'))
            bResult=false;
            issueNum=4;
            return;
        end
    end
end
