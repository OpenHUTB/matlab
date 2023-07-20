function hObj=DynDlgBuilder(varargin)





    hObj=PMDialogs.DynDlgBuilder;
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;


    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=get_param(varargin{1},'object');
    end


