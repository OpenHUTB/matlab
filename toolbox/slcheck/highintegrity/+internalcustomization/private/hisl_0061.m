function hisl_0061
    rec=getNewCheckObject('mathworks.hism.hisl_0061',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)

    violations=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;

    allCharts=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Chart'},true);
    allCharts=mdlAdvObj.filterResultWithExclusion(allCharts);

    for i=1:numel(allCharts)
        chartObj=allCharts{i};
        allData=chartObj.find('-isa','Stateflow.Data');

        allData=filterOutData(allData);

        dataNames=arrayfun(@(x)x.Name,allData,'UniformOutput',false);

        [uniqueNames,ia,~]=unique(dataNames);


        if numel(dataNames)~=numel(uniqueNames)


            duplicateIndices=setdiff(1:numel(dataNames),ia);
            for j=1:length(duplicateIndices)
                dObj.Name=allData(duplicateIndices(j)).Name;
                dObj.Source=allData(duplicateIndices(j)).Path;
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SimulinkVariableUsage',dObj);
                violations=[violations;vObj];%#ok<AGROW>
            end
        end
    end

end

function out=filterOutData(in)
    keep=true(size(in));
    for i=1:numel(in)
        if in(i).autoManaged||...
            startsWith(in(i).Name,'sf_internal_')||...
            any(strcmp(in(i).Scope,{'Input','Output'}))
            keep(i)=false;
        end
    end
    out=in(keep);
end