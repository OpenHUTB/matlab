function hObj=DynCheckBox(varargin)




    hObj=PMDialogs.DynCheckBox;
    hObj.assignObjId();
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;
    hObj.ResolveBuddyTags=false;
    hObj.MyTag='';

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end
