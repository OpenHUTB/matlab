function hObj=DynEditBox(varargin)




    hObj=PMDialogs.DynEditBox;
    hObj.assignObjId();
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end
