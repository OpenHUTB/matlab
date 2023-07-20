function hObj=DynNeDlgSource(block,varargin)



    block=pmsl_getdoublehandle(block);
    hObj=NetworkEngine.DynNeDlgSource(block);
    hObj.BlockHandle=block;
    hObj.ComponentName=get_param(block,'SourceFile');
    hObj.RequestChooser=false;
