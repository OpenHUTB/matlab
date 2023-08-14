function initPrescanRoutine(pouBlock)




    rootMdl=bdroot(pouBlock);
    if~strcmp(get_param(rootMdl,'SimulationStatus'),'stopped')||bdIsLibrary(rootMdl)
        return;
    end

    routineBlockPath=slplc.utils.getInternalBlockPath(pouBlock,'Prescan');

    preScanMode=strcmpi(slplc.api.getModelParam(rootMdl,'PLCLadderLogicPrescan'),'on');
    sldvMode=strcmpi(slplc.api.getModelParam(rootMdl,'PLCLadderLogicSLDVPreprocessing'),'on');

    if strcmpi(get_param(pouBlock,'PLCAllowPrescan'),'off')||~preScanMode||sldvMode
        set_param(routineBlockPath,'Commented','on');
    else
        set_param(routineBlockPath,'Commented','off');
        slplc.utils.disableFormatBlocks(routineBlockPath);
        assertNoInstrucionWithPrescanMode(routineBlockPath);
        assertNoAOIAndSubroutineInPrescanRoutine(routineBlockPath);
    end
end

function assertNoInstrucionWithPrescanMode(routineBlockPath)
    prescanInstructionList={'OTE','OSR','OSF','ONS','TON','TOF','RTO','CTU','CTD'};
    prescanRoutineOperandBlks=plc_find_system(routineBlockPath,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'PLCOperandTag','.+');
    for blkCount=1:numel(prescanRoutineOperandBlks)
        block=prescanRoutineOperandBlks{blkCount};
        plcBlockType=slplc.utils.getParam(block,'PLCBlockType');
        if~isempty(plcBlockType)&&ismember(plcBlockType,prescanInstructionList)


            error('slplc:initFcnInPrescanRoutine',...
            'Instruction block with prescan mode:\n\n%s\n\nis not supported in AOI Prescan Routine.',...
            block);
        end
    end
end

function assertNoAOIAndSubroutineInPrescanRoutine(block)
    aoiBlks=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on',...
    'PLCPOUType','Function Block');
    if~isempty(aoiBlks)
        jsrListStr=evalc('disp(aoiBlks);');
        error('slplc:aoiInPrescanRoutine',...
        'AOI Block(s):\n\n%s\n\nis not supported in AOI Prescan Routine.',...
        jsrListStr);
    end

    jsrBlks=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on',...
    'PLCPOUType','Subroutine');

    if~isempty(jsrBlks)
        jsrListStr=evalc('disp(jsrBlks);');
        error('slplc:jsrInPrescanRoutine',...
        'JSR Block(s):\n\n%s\n\nis not supported in AOI Prescan Routine.',...
        jsrListStr);
    end
end





