function hObj=PmDlgBuilder(varargin)




    hObj=PMDialogs.PmDlgBuilder;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;


    hObj.BlockHandle=[];

    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end

    hObj.OnBlockSchema='';
    hObj.PanelObjLst=[];



