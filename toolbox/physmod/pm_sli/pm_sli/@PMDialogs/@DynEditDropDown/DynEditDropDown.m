function hObj=DynEditDropDown(varargin)




    hObj=PMDialogs.DynEditDropDown;
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;
    hObj.assignObjId();

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end
