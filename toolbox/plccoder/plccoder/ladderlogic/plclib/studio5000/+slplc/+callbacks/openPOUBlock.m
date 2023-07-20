function openPOUBlock(pouBlock,varargin)



    if isempty(varargin)
        routineName='Logic';
    else
        routineName=varargin{1};
    end

    routineBlockPath=slplc.utils.getInternalBlockPath(pouBlock,routineName);
    open_system(routineBlockPath,'force');
    set_param(routineBlockPath,'ZoomFactor','FitSystem');
    close_system(pouBlock);

end