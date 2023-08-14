function hObj=PowerSysDialog(block,varargin)









    block=get_param(block,'Handle');
    hObj=POWERSYS.PowerSysDialog(block);

    hObj.BlockHandle=block;


