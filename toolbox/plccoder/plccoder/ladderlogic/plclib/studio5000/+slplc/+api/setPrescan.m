function setPrescan(mdlName,setting)




    if ischar(setting)
        setting=strcmpi(setting,'on');
    end
    PrescanOn=setting;

    topPLCBlks=plc_find_system(mdlName,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'PLCBlockType','(^PLCController$)|(^AOIRunner$)');

    for blkCount=1:numel(topPLCBlks)
        blk=topPLCBlks{blkCount};
        loc_setPrescan(blk,PrescanOn);
    end
end


function loc_setPrescan(block,prescanOn)

    enableBlockName=slplc.utils.getInternalBlockName('Enable');
    prescanBlockName=slplc.utils.getInternalBlockName('Prescan');
    aoiEventListenerBlockPath=[prescanBlockName,'/Event Listener'];

    instructionEnableBlockName='Instruction_Enable';
    instructionEventListenerBlockPath='Initialize Function/Event Listener';

    plcBlocks=plc_find_system(block,'LookUnderMasks','all','FollowLinks','on',...
    'regexp','on',...
    'BlockType','SubSystem',...
    'Name',['(^',enableBlockName,'$)|(^',instructionEnableBlockName,'$)']);

    warning('off','Simulink:Commands:SetParamLinkChangeWarn');
    for blkCount=1:numel(plcBlocks)
        plcBlock=plcBlocks{blkCount};
        aoiEventListenerBlk=[plcBlock,'/',aoiEventListenerBlockPath];
        instructionEventListenerBlk=[plcBlock,'/',instructionEventListenerBlockPath];
        if getSimulinkBlockHandle(aoiEventListenerBlk)>0
            if~prescanOn
                set_param(get_param(aoiEventListenerBlk,'Parent'),'Commented','on');
            else
                aoiBlock=slplc.utils.getParentPOU(plcBlock);
                slplc.callbacks.initPrescanRoutine(aoiBlock);
            end
        elseif getSimulinkBlockHandle(instructionEventListenerBlk)>0
            if~prescanOn
                set_param(get_param(instructionEventListenerBlk,'Parent'),'Commented','on');
            else
                set_param(get_param(instructionEventListenerBlk,'Parent'),'Commented','off');
            end
        end
    end
    warning('on','Simulink:Commands:SetParamLinkChangeWarn');
end
