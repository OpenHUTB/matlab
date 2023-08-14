function himl_0012

    rec=getNewCheckObject('mathworks.hism.himl_0012',false,@hCheckAlgo,'None');

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
    FailingObjs=[];failingFcns={};
    fcnObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();




    for i=1:length(fcnObjs)
        if isa(fcnObjs{i},'Stateflow.EMChart')||isa(fcnObjs{i},'Stateflow.EMFunction')
            tempFailingObjs=coderapp.internal.screener.screenerCodeMode(struct('Code',fcnObjs{i}.Script,'Path',fcnObjs{i}.path));

            failingFcns=[failingFcns,{tempFailingObjs.UnsupportedCalls(:).CalleeName}];
        end
    end


    for i=1:length(fcnObjs)
        switch class(fcnObjs{i})
        case{'Stateflow.EMChart','Stateflow.EMFunction'}

            mt=mtree(fcnObjs{i}.Script,'-com','-cell','-comments');
        case 'struct'
            mt=mtree(fcnObjs{i}.FileName,'-com','-cell','-file','-comments');
        end

        [bValid,tree_error]=Advisor.Utils.isValidMtree(mt);
        if~bValid
            vObj=ModelAdvisor.ResultDetail;
            if isa(fcnObjs{i},'struct')
                ModelAdvisor.ResultDetail.setData(vObj,'FileName',fcnObjs{i}.FileName,'Expression',tree_error.message);
            else
                ModelAdvisor.ResultDetail.setData(vObj,'SID',fcnObjs{i},'Expression',tree_error.message);
            end
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:common_matlab_parse_error_rec_action');
            vObj.Status=DAStudio.message('ModelAdvisor:hism:himl_warn_syntax');
            FailingObjs=[FailingObjs;vObj];
            continue;
        end

        opNodes=mt.mtfind('Kind','CALL');
        indices=opNodes.indices;
        for cnt=1:numel(indices)
            node=opNodes.select(indices(cnt));
            callStr=stringvals(node.Left);

            if ismember(callStr,failingFcns)
                vObj=getViolationInfoFromNode(fcnObjs{i},node,DAStudio.message('ModelAdvisor:hism:himl_0012_rec_action'));
                FailingObjs=[FailingObjs;vObj];%#ok<*AGROW>
            end
        end
    end
end
