function sigb_write_info(blkInfo)






    fromWsH=find_system(blkInfo.blockH,'FollowLinks','on'...
    ,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices...
    ,'LookUnderMasks','all'...
    ,'BlockType','FromWorkspace');
    if~strcmp(get_param(fromWsH,'StaticLinkStatus'),'implicit')


        blkInfo.blockH=[];
        blkInfo.modelH=[];
        set_param(fromWsH,'VnvData',blkInfo);
    end
end
