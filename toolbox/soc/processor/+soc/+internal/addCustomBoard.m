function addCustomBoard(folder,parentTgt,boardName,deviceType,platform,varargin)




    switch platform
    case 'xilinx'
        codertarget.zynq.internal.addCustomBoard(folder,parentTgt,...
        boardName,deviceType,platform,varargin);
    case 'intel'
        codertarget.alterasoc.internal.addCustomBoard(folder,parentTgt,...
        boardName,deviceType,platform,varargin);
    otherwise
        assert(false,'Invalid platform. Valid platforms are xilinx and intel.');
    end

end