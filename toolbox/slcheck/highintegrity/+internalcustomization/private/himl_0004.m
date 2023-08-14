function himl_0004

    rec=getNewCheckObject('mathworks.hism.himl_0004',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams();

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function FailingObjs=hCheckAlgo(~)
    FailingObjs=[];
    fcnObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();




    for i=1:length(fcnObjs)
        if~isempty(fcnObjs{i})
            FailingObjs=[FailingObjs;getFailingEMLFunctions(fcnObjs{i})];%#ok<AGROW>
        end
    end

end

function FailObjs=getFailingEMLFunctions(eml_obj)
    FailObjs=[];
    switch class(eml_obj)
    case 'Stateflow.EMChart'
        checkCodeResults=checkcode('-text',eml_obj.Script,'.m','-id','-codegen');
        mt=mtree(eml_obj.Script,'-com','-cell','-comments');
        script=strsplit(eml_obj.Script,newline,'CollapseDelimiters',false);
    case 'Stateflow.EMFunction'
        checkCodeResults=checkcode('-text',eml_obj.Script,'.m','-id','-codegen');
        checkCodeResults=filterResults(checkCodeResults);
        mt=mtree(eml_obj.Script,'-com','-cell','-comments');
        script=strsplit(eml_obj.Script,newline,'CollapseDelimiters',false);
    case 'struct'
        checkCodeResults=checkcode(eml_obj.FileName,'-id','-codegen');
        mt=mtree(eml_obj.FileName,'-com','-cell','-file','-comments');
        script=strsplit(fileread(eml_obj.FileName),newline,'CollapseDelimiters',false);
    end


    if~hasCodegenDirective(eml_obj,mt)
        expression_string=strtrim(script{1});

        tempObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(tempObj,'FileName',eml_obj.FileName,'Expression',expression_string,'TextStart',1,'TextEnd',length(expression_string));
        tempObj.CustomData={['%#codegen : ',DAStudio.message('ModelAdvisor:hism:himl_0004_missing_codegen')]};
        tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:himl_0004_rec_action');
        FailObjs=[FailObjs;tempObj];
    end

    commentNodes=mt.mtfind('Kind','COMMENT');
    for nodeNumber=commentNodes.indices
        thisNode=commentNodes.select(nodeNumber);
        comment=strtrim(thisNode.string);
        fullLineDirective=false;
        if length(comment)>=4&&strcmp(comment(1:4),'%#ok')
            if length(comment)>=5
                if comment(5)~='<'
                    fullLineDirective=true;
                end
            else
                fullLineDirective=true;
            end
        end
        if fullLineDirective
            tempObj=getViolationInfoFromNode(eml_obj,thisNode,'');
            tempObj.CustomData={['%#ok : ',DAStudio.message('ModelAdvisor:hism:himl_0004_unspecified_justification')]};
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:himl_0004_rec_action');
            FailObjs=[FailObjs;tempObj];%#ok<AGROW>
        end
    end

    if~isempty(checkCodeResults)
        for i=1:numel(checkCodeResults)
            current_result=checkCodeResults(i);
            stIdx=mt.lc2pos(current_result.line,current_result.column(1));
            enIdx=mt.lc2pos(current_result.line,current_result.column(2));

            expression_string=strtrim(script{current_result.line});

            tempObj=ModelAdvisor.ResultDetail;
            if isa(eml_obj,'struct')
                ModelAdvisor.ResultDetail.setData(tempObj,'FileName',eml_obj.FileName,'Expression',expression_string,'TextStart',stIdx,'TextEnd',enIdx);
            else
                ModelAdvisor.ResultDetail.setData(tempObj,'SID',eml_obj,'Expression',expression_string,'TextStart',stIdx,'TextEnd',enIdx);
            end
            tempObj.CustomData={[current_result.id,' : ',current_result.message]};
            tempObj.RecAction=DAStudio.message('ModelAdvisor:hism:himl_0004_rec_action');
            FailObjs=[FailObjs;tempObj];%#ok<AGROW>
        end
    end
end

function newCheckCodeResults=filterResults(oldCheckCodeResults)
    keep=true(size(oldCheckCodeResults));
    for index=1:numel(oldCheckCodeResults)
        switch oldCheckCodeResults(index).id
        case 'COLND',keep(index)=false;
        case 'EMVDF',keep(index)=false;
        case 'NASGU',keep(index)=false;
        case 'NODEF',keep(index)=false;
        otherwise,keep(index)=true;
        end
    end
    newCheckCodeResults=oldCheckCodeResults(keep);
end

function codegenDirectiveFound=hasCodegenDirective(eml_obj,mtreeObject)

    codegenDirectiveFound=false;

    switch class(eml_obj)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        codegenDirectiveFound=true;
    case 'struct'
        commentNodes=mtreeObject.mtfind('Kind','COMMENT');
        for nodeNumber=commentNodes.indices
            thisNode=commentNodes.select(nodeNumber);
            comment=strtrim(thisNode.string);
            if length(comment)>=9
                if strcmp(comment(1:9),'%#codegen')==1
                    codegenDirectiveFound=true;
                    break;
                end
            end
        end
    otherwise
        return;
    end
end
