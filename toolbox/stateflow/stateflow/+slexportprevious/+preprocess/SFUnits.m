function SFUnits(obj)




    if isR2015bOrEarlier(obj.ver)



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
            if~isempty(chart)
                inputData=chart.find('-isa','Stateflow.Data','Scope','Input');
                outputData=chart.find('-isa','Stateflow.Data','Scope','Output');
                ids=arrayfun(@(x)x.Id,inputData);
                ids=[ids;arrayfun(@(x)x.Id,outputData)];%#ok
                withUnitIds=sf('find',ids','~.props.unit.name','inherit');
                if(~isempty(withUnitIds))
                    obj.reportWarning('Stateflow:misc:UnitsSaveInPrevVersion',chart.Name);
                end
            end
        end

        obj.appendRule('<data<props<unit:remove>>>');
    end
end
