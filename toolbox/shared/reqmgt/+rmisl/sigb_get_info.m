function blkInfo=sigb_get_info(blkHandle)






    fromWsH=find_system(blkHandle,'FollowLinks','on'...
    ,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices...
    ,'LookUnderMasks','all'...
    ,'BlockType','FromWorkspace');
    blkInfo=get_param(fromWsH,'VnvData');

    if isempty(blkInfo.blockH)

        blkInfo.blockH=blkHandle;
        blkInfo.modelH=bdroot(blkHandle);
    end
end


