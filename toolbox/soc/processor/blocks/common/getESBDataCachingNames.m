function rWirelessDataCachingNames=getESBDataCachingNames(hBlk)




    rWirelessDataCachingNames={};




    bd=bdroot(hBlk);


    tskBlks=find_system(bd,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'MaskType','ESB Task');

    rtBlksPerTaskBlocks=soc.internal.getESBTaskRTInfo(bd);
    taskNames=cell(1,length(tskBlks));
    for idx=1:length(tskBlks)
        taskNames{idx}=get_param(tskBlks{idx},'taskName');
    end
    taskNames=unique(taskNames);

    for idx=1:length(taskNames)
        if rtBlksPerTaskBlocks.isKey(taskNames{idx})
            rtBlkNames=rtBlksPerTaskBlocks(taskNames{idx});
            for m=1:numel(rtBlkNames)
                thisRtBlkName=rtBlkNames{m};
                rtNameStr=[thisRtBlkName,'_esbrt'];
                rWirelessDataCachingNames{end+1}=rtNameStr;%#ok<*AGROW>
            end
        else
            rWirelessDataCachingNames{end+1}='Stub_esbrt';
        end
    end
end
