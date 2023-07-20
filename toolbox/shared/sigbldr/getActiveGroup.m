function[activeGroupName]=getActiveGroup(blockH)



    figH=get_param(blockH,'UserData');
    if isempty(figH)||~ishghandle(figH,'figure')


        fromWsH=find_system(blockH,'FollowLinks','on','LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','FromWorkspace');
        UD=get_param(fromWsH,'SigBuilderData');
        activegroup=UD.dataSetIdx;
    else
        UD=get(figH,'UserData');
        activegroup=UD.current.dataSetIdx;
    end

    activeGroupName=UD.dataSet(activegroup).name;

