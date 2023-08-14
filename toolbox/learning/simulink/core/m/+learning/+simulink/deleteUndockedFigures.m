function deleteUndockedFigures(mdl)






    grader_list=find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'RegExp','on','ReferenceBlock','signalChecks');

    for idx=1:length(grader_list)
        fh=findobj(0,'type','Figure','tag',grader_list{idx});
        if~isempty(fh)
            figure(fh);
            delete(fh);
        end
    end

end

