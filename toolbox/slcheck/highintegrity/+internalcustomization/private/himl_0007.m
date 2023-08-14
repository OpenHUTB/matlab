function himl_0007

    rec=getNewCheckObject('mathworks.hism.himl_0007',false,@hCheckAlgo,'None');
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
    FailObjs={};
    switch class(eml_obj)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        mt=mtree(eml_obj.Script,'-com','-cell','-comments');
    case 'struct'
        mt=mtree(eml_obj.FileName,'-com','-cell','-file','-comments');
    end

    [bValid,tree_error]=Advisor.Utils.isValidMtree(mt);
    if~bValid
        FailObjs=ModelAdvisor.ResultDetail;
        if isa(eml_obj,'struct')
            ModelAdvisor.ResultDetail.setData(FailObjs,'FileName',eml_obj.FileName,'Expression',tree_error.message);
        else
            ModelAdvisor.ResultDetail.setData(FailObjs,'SID',eml_obj,'Expression',tree_error.message);
        end
        FailObjs.RecAction=DAStudio.message('ModelAdvisor:hism:common_matlab_parse_error_rec_action');
        FailObjs.Status=DAStudio.message('ModelAdvisor:hism:himl_warn_syntax');
        return;
    end

    switch_nodes=mt.mtfind('Kind','SWITCH');

    indices=switch_nodes.indices;
    for i=1:length(indices)
        node=switch_nodes.select(indices(i));


        if(~isempty(node.Body)&&~strcmp(node.Body.kind,'COMMENT')&&~strcmp(node.Body.kind,'CASE'))||(~isempty(node.Body.Next)&&~strcmp(node.Body.Next.kind,'CASE')&&~isempty(node.Body.Left)&&~strcmp(node.Body.Left.kind,'LC'))
            FailObjs=[FailObjs;getViolationInfoFromNode(eml_obj,node,DAStudio.message('ModelAdvisor:hism:himl_0007_rec_action1'))];%#ok<AGROW>       
        end


        if~strcmp(node.Body.last.kind,'OTHERWISE')
            FailObjs=[FailObjs;getViolationInfoFromNode(eml_obj,node,DAStudio.message('ModelAdvisor:hism:himl_0007_rec_action2'))];%#ok<AGROW>
        elseif isempty(node.Body.last.Body)||(~isempty(node.Body.last.Body)&&strcmp(node.Body.last.Body.kind,'COMMENT')&&isempty(regexp(node.Body.last.Body.tree2str,'%+\s*\w+','once')))
            FailObjs=[FailObjs;getViolationInfoFromNode(eml_obj,node,DAStudio.message('ModelAdvisor:hism:himl_0007_rec_action3'))];%#ok<AGROW>
        end
    end
end
