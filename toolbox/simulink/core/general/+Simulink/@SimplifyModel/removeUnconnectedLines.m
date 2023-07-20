


function removeUnconnectedLines(FullPath)

    mdlName=Simulink.SimplifyModel.getSubsystemName(FullPath);
    load_system(mdlName);



    unconnectedLines=find_system(FullPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','line');
    for i=1:length(unconnectedLines)
        try %#ok<TRYNC>
            if strcmpi(get_param(unconnectedLines(i),'Connected'),'off')
                delete_line(unconnectedLines(i));
            end
        end
    end
