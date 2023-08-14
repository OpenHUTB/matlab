function setFastSim(block,setting)





    if ischar(setting)
        setting=strcmpi(setting,'on');
    end
    fastSimOn=setting;

    if fastSimOn
        slplc.utils.disableFormatBlocks(block);
    else
        enableFormatBlocks(block);
        plcFBBlocks=plc_find_system(block,'LookUnderMasks','all','FollowLinks','on',...
        'PLCBlockType','LDFunctionBlock');
        for blkCount=1:numel(plcFBBlocks)
            plcFBBlock=plcFBBlocks{blkCount};
            prescanBlockPath=slplc.utils.getInternalBlockPath(plcFBBlock,'Prescan');
            slplc.utils.disableFormatBlocks(prescanBlockPath);
        end
    end
end

function enableFormatBlocks(block)


    formatSettingBlockName=slplc.utils.getInternalBlockName('Format');
    powerRailStartBlocks=plc_find_system(block,'LookUnderMasks','all','FollowLinks','on',...
    'PLCBlockType','PowerRailStart');
    plcBlocks=plc_find_system(block,'LookUnderMasks','all','FollowLinks','on',...
    'regexp','on',...
    'PLCBlockType','^\w+','PLCPOUType','^\w+');
    plcBlocks=[powerRailStartBlocks;plcBlocks];

    warning('off','Simulink:Commands:SetParamLinkChangeWarn');
    for blkCount=1:numel(plcBlocks)
        plcBlock=plcBlocks{blkCount};
        formattingBlock=[plcBlock,'/',formatSettingBlockName];
        if getSimulinkBlockHandle(formattingBlock)>0
            set_param(formattingBlock,'Commented','off');
        end
    end
    warning('on','Simulink:Commands:SetParamLinkChangeWarn');
end
