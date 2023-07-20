function hObj=PMDefaultMaskDlg(block,varargin)









    block=get_param(block,'Handle');
    hObj=PMDialogs.PMDefaultMaskDlg(block);

    hObj.BlockHandle=block;



