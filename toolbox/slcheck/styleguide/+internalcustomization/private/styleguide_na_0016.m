function styleguide_na_0016




    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.na_0016',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    iParam=ModelAdvisor.InputParameter;
    iParam.RowSpan=[1,1];
    iParam.ColSpan=[1,4];
    iParam.Name=DAStudio.message('ModelAdvisor:styleguide:na_0016_input_param_loc');
    iParam.Type='Number';
    iParam.Value=60;
    iParam.Visible=false;

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams(2);

    rec.setInputParametersLayoutGrid([3,4]);
    rec.setInputParameters([{iParam},inputParamList]);

    rec.setLicense({styleguide_license});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,sg_maab_group);
end

function FailingObjs=hCheckAlgo(~)
    FailingObjs=[];
    fcnObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();




    for i=1:length(fcnObjs)
        if~isempty(fcnObjs{i})
            FailingObjs=[FailingObjs;getInvalidNestedConditionals(fcnObjs{i})];%#ok<AGROW>
        end
    end

end

function FailObjs=getInvalidNestedConditionals(eml_obj)
    FailObjs=[];
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

    mObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    inputParams=mObj.getInputParameters;

    threshold=inputParams{1}.Value;

    function_nodes=mt.mtfind('Kind','FUNCTION');

    indices=function_nodes.indices;
    for i=1:length(indices)
        fnode=function_nodes.select(indices(i));
        noCodeNodes=fnode.Tree.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
        codeNodes=fnode.Tree.mtfind('~Member',noCodeNodes);

        effLoc=length(unique(codeNodes.lineno));

        if effLoc>threshold
            vObj=getViolationInfoFromNode(eml_obj,fnode,DAStudio.message('ModelAdvisor:styleguide:na_0016_rec_action'));
            vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0016_warn',threshold);
            vObj.CustomData={DAStudio.message('ModelAdvisor:styleguide:na_0016_issue_desc',num2str(effLoc))};
            FailObjs=[FailObjs;vObj];%#ok<AGROW>
        end
    end
end
