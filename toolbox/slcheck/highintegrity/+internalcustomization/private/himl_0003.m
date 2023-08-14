function himl_0003

    rec=getNewCheckObject('mathworks.hism.himl_0003',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams();

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:himl_0003_input_loc');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='60';
    inputParamList{end}.setRowSpan([3,3]);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:himl_0003_input_doc');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='0.2';
    inputParamList{end}.setRowSpan([4,4]);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:hism:himl_0003_input_cyc');
    inputParamList{end}.Type='String';
    inputParamList{end}.Value='15';
    inputParamList{end}.setRowSpan([5,5]);
    inputParamList{end}.setColSpan([1,4]);
    inputParamList{end}.Visible=false;

    rec.setInputParametersLayoutGrid([5,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function FailingObjs=hCheckAlgo(system)

    FailingObjs={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    [isValid,ErrorObj]=validateCheckParams(inputParams);
    if~isValid
        FailingObjs=ErrorObj;
        return;
    end

    locParam=str2double(inputParams{4}.Value);
    docParam=str2double(inputParams{5}.Value);
    cycParam=str2double(inputParams{6}.Value);

    fcnObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,inputParams{2}.Value,inputParams{3}.Value);
    fcnObjs=mdladvObj.filterResultWithExclusion(fcnObjs);


    s=size(fcnObjs);
    if s(1)~=length(fcnObjs)

        fcnObjs=fcnObjs';
    end
    if inputParams{1}.Value
        fcnObjs=Advisor.Utils.Eml.getReferencedMFiles(system,fcnObjs);
    end


    for i=1:length(fcnObjs)
        eml_obj=fcnObjs{i};
        if isempty(eml_obj)
            continue;
        end

        switch class(eml_obj)
        case{'Stateflow.EMChart','Stateflow.EMFunction'}
            mt=mtree(eml_obj.Script,'-com','-cell','-comments');
            ccr=checkcode('-text',eml_obj.Script,'.m','-cyc');
            tloc=length(strsplit(eml_obj.Script,newline,'CollapseDelimiters',false));
        case 'struct'
            filename=eml_obj.FileName;
            mt=mtree(filename,'-com','-cell','-file','-comments');
            ccr=checkcode(filename,'-cyc');
            tloc=length(strsplit(fileread(filename),newline,'CollapseDelimiters',false));
        end

        if mt.isempty
            continue;
        end



        commentNodes=mt.mtfind('Kind','COMMENT');
        cellmarkNodes=mt.mtfind('Kind','CELLMARK');
        blkcomNodes=mt.mtfind('Kind','BLKCOM');

        commentLinesOfCode=commentNodes.count+cellmarkNodes.count+2*blkcomNodes.count;
        commentDensity=commentLinesOfCode/tloc;

        if commentDensity<docParam
            vObj=getViolationInfoFromNode(eml_obj,mt.root,DAStudio.message('ModelAdvisor:hism:himl_0003_rec_action'));
            vObj.CustomData={DAStudio.message('ModelAdvisor:hism:himl_0003_issue1',num2str(commentDensity),num2str(docParam))};
            FailingObjs=[FailingObjs;vObj];%#ok<AGROW>
        end

        functionNodes=mt.mtfind('Kind','FUNCTION');
        idxs=functionNodes.indices;

        for j=1:functionNodes.count
            fnode=functionNodes.select(idxs(j));
            functionName=fnode.Fname.string;
            noCodeNodes=fnode.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
            codeNodes=fnode.mtfind('~Member',noCodeNodes);


            effLoc=length(unique(codeNodes.Tree.lineno));

            if effLoc>locParam
                vObj=getViolationInfoFromNode(eml_obj,fnode,DAStudio.message('ModelAdvisor:hism:himl_0003_rec_action'));
                vObj.CustomData={DAStudio.message('ModelAdvisor:hism:himl_0003_issue2',num2str(effLoc),num2str(locParam))};
                FailingObjs=[FailingObjs;vObj];%#ok<AGROW>
            end

            cycComp=get_cyclomaticComplexity(ccr,functionName);

            if cycComp>cycParam
                vObj=getViolationInfoFromNode(eml_obj,fnode,DAStudio.message('ModelAdvisor:hism:himl_0003_rec_action'));
                vObj.CustomData={DAStudio.message('ModelAdvisor:hism:himl_0003_issue3',num2str(cycComp),num2str(cycParam))};
                FailingObjs=[FailingObjs;vObj];%#ok<AGROW>
            end
        end
    end
end

function[isValid,ErrorObj]=validateCheckParams(inputParams)
    isValid=true;
    ErrorObj=[];
    errorString={};

    locParam=str2double(inputParams{4}.Value);
    docParam=str2double(inputParams{5}.Value);
    cycParam=str2double(inputParams{6}.Value);


    if isnan(locParam)||locParam<1||locParam~=fix(locParam)
        isValid=false;
        errorString{end+1}=DAStudio.message('ModelAdvisor:hism:himl_0003_wrong_input_param',inputParams{4}.Name);
    end

    if isnan(docParam)||docParam<0||docParam>1
        isValid=false;
        errorString{end+1}=DAStudio.message('ModelAdvisor:hism:himl_0003_wrong_input_param',inputParams{5}.Name);
    end

    if isnan(cycParam)||cycParam<1||cycParam~=fix(cycParam)
        isValid=false;
        errorString{end+1}=DAStudio.message('ModelAdvisor:hism:himl_0003_wrong_input_param',inputParams{6}.Name);
    end

    if~isValid
        ErrorObj=ModelAdvisor.ResultDetail;
        ErrorObj.IsInformer=true;
        ErrorObj.IsViolation=true;
        ModelAdvisor.ResultDetail.setSeverity(ErrorObj,'fail');
        ErrorObj.Description=strjoin(errorString,'<br/>');
        ErrorObj.RecAction=DAStudio.message('ModelAdvisor:hism:himl_0003_wrong_input_param_action');
        ErrorObj.Status=' ';
    end
end

function cyclomaticComplexity=get_cyclomaticComplexity(checkCodeResults,functionName)

    cyclomaticComplexity=[];
    pattern=DAStudio.message('CodeAnalyzer:caBuiltins:CABE',['''',functionName,''''],'(\d+)');
    messages={checkCodeResults.message}';
    tokens=regexp(messages,pattern,'tokens');
    for idx=1:length(tokens)
        thisToken=tokens{idx};
        if~isempty(thisToken)
            cyclomaticComplexity=str2double(thisToken{1});
            break;
        end
    end

end