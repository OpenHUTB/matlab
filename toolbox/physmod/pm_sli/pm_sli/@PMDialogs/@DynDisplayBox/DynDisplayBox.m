function hObj=DynDisplayBox(varargin)




    hObj=PMDialogs.DynDisplayBox;
    hObj.assignObjId();
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end
