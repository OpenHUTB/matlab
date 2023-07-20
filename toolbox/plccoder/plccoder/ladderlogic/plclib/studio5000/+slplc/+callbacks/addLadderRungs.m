function addLadderRungs(block)



    simStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simStatus,'stopped')

        import plccore.common.plcThrowError;
        plcThrowError('plccoder:plccore:AddRungsRuntime',simStatus);
    end

    rungNum=get_param(block,'PLCRungNumberToAdd');
    ldBlk=get_param(block,'Parent');
    if strcmpi(ldBlk,bdroot(ldBlk))
        return
    end

    railTerminalBlock=plc_find_system(ldBlk,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','PowerRailTerminal');
    railTerminalBlockName=get_param(railTerminalBlock{1},'Name');

    railStartBlock=plc_find_system(ldBlk,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','PowerRailStart');
    railStartBlockName=get_param(railStartBlock{1},'Name');

    if ischar(rungNum)
        rungNum=str2double(rungNum);
    end

    step=175;
    originalPosition=get_param(railTerminalBlock{1},'Position');
    terminalBlockPosition=originalPosition+[0,step*rungNum,0,step*rungNum];
    set_param(railTerminalBlock{1},'Position',terminalBlockPosition);

    rungTerminalBlock='Rung Terminal';
    for ii=1:rungNum
        newBlock=slplc.utils.addLibBlock(rungTerminalBlock,[ldBlk,'/',rungTerminalBlock],'MakeNameUnique','on');
        rungTerminalBlockPosition=get_param(newBlock,'Position');
        dx=rungTerminalBlockPosition(3)-rungTerminalBlockPosition(1);
        dy=rungTerminalBlockPosition(4)-rungTerminalBlockPosition(2);
        newBlockName=get_param(newBlock,'Name');
        set_param(newBlock,'Position',...
        [originalPosition(1),originalPosition(2),originalPosition(1)+dx,originalPosition(2)+dy]+[800,step*(ii-1),800,step*(ii-1)]);
        add_line(ldBlk,[railStartBlockName,'/1'],[newBlockName,'/1'],'autorouting','on');
    end

    h=get_param(railTerminalBlock{1},'LineHandles');
    delete_line(h.Inport(1));
    add_line(ldBlk,[railStartBlockName,'/1'],[railTerminalBlockName,'/1'],'autorouting','on');

    addRungsBlock=plc_find_system(ldBlk,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','AddRungs');
    addSingleRungBlock=plc_find_system(ldBlk,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','AddSingleRung');

    originalAddRungsBlockPosition=get_param(addRungsBlock{1},'Position');
    originalAddSingleRungBlockPosition=get_param(addSingleRungBlock{1},'Position');

    yDistance=terminalBlockPosition(2)-originalPosition(2);
    addRungsBlockPosition=originalAddRungsBlockPosition+[0,yDistance,0,yDistance];
    addSingleRungBlockPosition=originalAddSingleRungBlockPosition+[0,yDistance,0,yDistance];

    set_param(addRungsBlock{1},'Position',addRungsBlockPosition);
    set_param(addSingleRungBlock{1},'Position',addSingleRungBlockPosition);
end


