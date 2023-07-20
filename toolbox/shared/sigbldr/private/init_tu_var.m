function tu=init_tu_var(blockH)






    fromWsH=find_system(blockH,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','FromWorkspace');
    UD=get_param(fromWsH,'SigBuilderData');

    if~isfield(UD,'sbobj')
        UD.sbobj=SigSuite(UD);
    else
        if~isempty(UD.sbobj)&&iscell(UD.sbobj.Groups)
            UD.sbobj=convertFrom2008a(UD);
        end
    end

    ActiveGroup=UD.sbobj.ActiveGroup;
    if(isempty(ActiveGroup)||(ActiveGroup~=UD.dataSetIdx))
        ActiveGroup=UD.dataSetIdx;
        UD.sbobj.ActiveGroup=UD.dataSetIdx;
    end

    signalCnt=length(UD.channels);
    [X,Y]=match_end_points(UD,ActiveGroup);
    tu=create_sl_input_variable(X,Y,signalCnt);
