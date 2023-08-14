function hObj=DynNeUtilDlgSource(block,varargin)


    block=pmsl_getdoublehandle(block);
    hObj=NetworkEngine.DynNeUtilDlgSource(block);
    hObj.BlockHandle=block;
end
