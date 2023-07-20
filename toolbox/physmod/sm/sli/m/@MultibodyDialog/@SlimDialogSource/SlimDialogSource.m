function hObj=SlimDialogSource(block,varargin)




    block=pmsl_getdoublehandle(block);
    hObj=MultibodyDialog.SlimDialogSource(block);
    hObj.BlockHandle=block;
