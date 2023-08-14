function updateSigBldrIceState(modelH,state)




    assert(strcmp(state,'off')||strcmp(state,'on'));

    s=warning('off','Simulink:Libraries:MissingLibrary');
    sCleanup=onCleanup(@()warning(s));


    figs=findall(0,'Type','figure','Tag','SignalBuilderGUI');
    if isempty(figs)
        return;
    end


    sigbldrs=find_system(modelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'AllBlocks','on','Tag','STV Subsys');

    for i=1:length(sigbldrs)
        try
            sigbuilder_block('updateIceState',sigbldrs(i),state);
        catch ME
            Simulink.harness.internal.warn(ME);
        end
    end

end
