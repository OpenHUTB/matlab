function hObj=DynDlgSource(block,varargin)



    block=get_param(block,'Handle');
    hObj=PMDialogs.DynDlgSource(block);
    hObj.BlockHandle=block;
    hObj.DialogRefresh=false;