function hisf_0016

    rec=getNewCheckObject('mathworks.hism.hisf_0016',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end

function FailingObjs=hCheckAlgo(system)


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    allCharts=Advisor.Utils.Stateflow.sfFindSys(gcs,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart','-or','-isa','Stateflow.LinkChart'},true);
    allCharts=mdladvObj.filterResultWithExclusion(allCharts);





    FailingObjs=[];

    for i=1:length(allCharts)

        t_chart=allCharts{i};

        subsysObj=get_param(sfprivate('chart2block',allCharts{i}.Id),'object');


        for j=1:length(subsysObj.LineHandles.Inport)
            lineHandle=subsysObj.LineHandles.Inport(j);
            sfInputObject=t_chart.find('Scope','Input','-and','Port',j,'-not','-isa','Stateflow.Event');
            name=loc_getInportLineName(lineHandle);
            if~isempty(name)&&~strcmp(name,sfInputObject.Name)
                violation=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(violation,'Signal',lineHandle);
                FailingObjs=[FailingObjs;violation];%#ok<AGROW>
            end
        end

        for j=1:length(subsysObj.LineHandles.Outport)
            if subsysObj.LineHandles.Outport(j)>0
                lineObj=get_param(subsysObj.LineHandles.Outport(j),'Object');
                sp=lineObj.getSourcePort;
                sfOutputObject=t_chart.find('Scope','Output','-and','Port',j);
                if~isempty(sp)&&~isempty(sp.Name)&&~strcmp(sp.Name,sfOutputObject.Name)
                    violation=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(violation,'Signal',lineObj.Handle);
                    FailingObjs=[FailingObjs;violation];%#ok<AGROW>
                end
            end
        end
    end

end

function name=loc_getInportLineName(handle)

    name='';

    if handle>0
        lineObj=get_param(handle,'Object');
        sp=lineObj.getSourcePort;




        if~isempty(sp)

            if isempty(sp.Name)
                name=sp.PropagatedSignals;

            else
                name=sp.Name;
                if strcmp(name(1),'<')&&strcmp(name(end),'>')
                    name(1)='';
                    name(end)='';
                end
            end
        end
    end
end
