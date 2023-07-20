function disableFormatBlocks(block)





    formatBlocks=plc_find_system(block,'LookUnderMasks','all','FollowLinks','on',...
    'regexp','on',...
    'Name','^__Format',...
    'BlockType','SubSystem');

    warning('off','Simulink:Commands:SetParamLinkChangeWarn');
    for blkCount=1:numel(formatBlocks)
        formattingBlock=formatBlocks{blkCount};
        set_param(formattingBlock,'Commented','on');
    end
    warning('on','Simulink:Commands:SetParamLinkChangeWarn');
end
