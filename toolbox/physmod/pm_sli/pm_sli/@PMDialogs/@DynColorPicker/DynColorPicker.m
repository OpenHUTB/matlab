function hObj=DynMechGraphicsPanel(varargin)





    hObj=PMDialogs.DynColorPicker;
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;
    hObj.assignObjId();

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end

