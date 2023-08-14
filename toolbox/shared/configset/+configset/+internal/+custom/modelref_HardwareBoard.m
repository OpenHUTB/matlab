function result=modelref_HardwareBoard(csTop,csChild,varargin)















    distrTargetWithHWNode=varargin{3};

    topHardwareBoard=get_param(csTop,'HardwareBoard');
    childHardwareBoard=get_param(csChild,'HardwareBoard');

    if distrTargetWithHWNode&&strcmp(childHardwareBoard,'None')
        result=false;
    else
        result=~isequal(topHardwareBoard,childHardwareBoard);
    end

end
