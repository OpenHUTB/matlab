function SFNotes(obj)












    if isR2013bOrEarlier(obj.ver)



        hCharts=find_system(obj.modelName,...
        'LookUnderMasks','all',...
        'SkipLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','off',...
        'MaskType','Stateflow');

        if(isempty(hCharts))
            return;
        end

        for i=1:numel(hCharts)
            chart=idToHandle(sfroot,sfprivate('block2chart',hCharts{i}));
            notes=chart.find('-isa','Stateflow.Note');

            for j=1:numel(notes)

                if notes(j).IsImage

                    delete(notes(j));
                elseif strcmp(notes(j).Interpretation,'RICH')


                    notes(j).Interpretation='OFF';
                end
            end
        end
    end
end
