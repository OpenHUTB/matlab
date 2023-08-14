function SFMessages(obj)




    if isR2014bOrEarlier(obj.ver)



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

            if(~isempty(msgs))
                obj.reportWarning('Stateflow:misc:MessagesSaveInPrevVersion',chart.Name);
            end

            for j=1:length(msgs)
                delete(msgs(j));
            end

        end

        obj.appendRule('<data<message:remove>>');
    end
    if isR2016aOrEarlier(obj.ver)
        obj.appendRule('<data<message<queueOverflowDiagnostic:remove>>>');
    end
end
