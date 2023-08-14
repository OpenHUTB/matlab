function styleguide_na_0018




    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.na_0018',false,@hCheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    iParam=ModelAdvisor.InputParameter;
    iParam.RowSpan=[1,1];
    iParam.ColSpan=[1,4];
    iParam.Name=DAStudio.message('ModelAdvisor:styleguide:na_0018_input_param_levels');
    iParam.Type='Number';
    iParam.Value=3;
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

    if_head_nodes=mt.mtfind('Kind',{'IF','SWITCH'});

    indices=if_head_nodes.indices;
    levels=zeros(1,numel(indices));

    for i=1:length(indices)
        node=if_head_nodes.select(indices(i));

        while~isnull(node)
            if any(strcmp(node.kind,{'IF','SWITCH'}))
                levels(i)=levels(i)+1;
            end
            node=node.trueparent;
        end

        if levels(i)>threshold
            vObj=getViolationInfoFromNode(eml_obj,if_head_nodes.select(indices(i)),DAStudio.message('ModelAdvisor:styleguide:na_0018_rec_action'));
            vObj.Status=DAStudio.message('ModelAdvisor:styleguide:na_0018_warn',threshold);
            FailObjs=[FailObjs;vObj];%#ok<AGROW>
        end
    end
end
