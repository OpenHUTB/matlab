function tooltip=HardwareBoard_Unknown_TT(cs,~)

    cs=cs.getConfigSet;

    boardName=cs.get_param('HardwareBoard');
    if isempty(boardName)
        boardName='None';
    end

    tooltip=message('codertarget:utils:UnknownBoard',boardName).getString();



