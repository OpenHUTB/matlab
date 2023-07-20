function SFStrings(obj)







    hCharts=find_system(obj.modelName,...
    'LookUnderMasks','all',...
    'SkipLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','off',...
    'MaskType','Stateflow');
    if(isempty(hCharts))
        return;
    end

    for i=1:length(hCharts)
        chart=idToHandle(sfroot,sfprivate('block2chart',hCharts{i}));

        msgs=chart.find('-isa','Stateflow.Message');
        stringMsgs=msgs(arrayfun(@(x)strncmp(x.DataType,'string',6),msgs));

        datas=chart.find('-isa','Stateflow.Data');
        stringDatas=datas(arrayfun(@(x)strncmp(x.DataType,'string',6),datas));

        if(isempty(stringMsgs)&&isempty(stringDatas))
            continue;
        end

        ver=obj.ver;
        if isa(chart,'Stateflow.StateTransitionTableChart')&&isR2021bOrEarlier(ver)
            obj.reportWarning('Stateflow:misc:StringSaveInPrevVersion',chart.Name,'R2022a');
        elseif isa(chart,'Stateflow.TruthTableChart')&&isR2021bOrEarlier(ver)
            obj.reportWarning('Stateflow:misc:StringSaveInPrevVersion',chart.Name,'R2022a');
        elseif isa(chart,'Stateflow.Chart')&&chart.isRequirementsTable&&isR2022aOrEarlier(ver)
            obj.reportWarning('Stateflow:misc:StringSaveInPrevVersion',chart.Name,'R2022b');
        elseif isa(chart,'Stateflow.Chart')&&sfprivate('is_des_chart',chart.Id)&&isR2022aOrEarlier(ver)
            obj.reportWarning('Stateflow:misc:StringSaveInPrevVersion',chart.Name,'R2022b');
        elseif isa(chart,'Stateflow.Chart')&&strcmp(chart.ActionLanguage,'MATLAB')&&isR2021aOrEarlier(ver)
            obj.reportWarning('Stateflow:misc:StringSaveInPrevVersion',chart.Name,'R2021b');
        elseif isa(chart,'Stateflow.Chart')&&strcmp(chart.ActionLanguage,'C')&&isR2018aOrEarlier(ver)
            obj.reportWarning('Stateflow:misc:StringSaveInPrevVersion',chart.Name,'R2018b');
        else
            continue;
        end

        for j=1:length(stringMsgs)
            delete(stringMsgs(j));
        end
        for k=1:length(stringDatas)
            delete(stringDatas(k));
        end
    end
end
