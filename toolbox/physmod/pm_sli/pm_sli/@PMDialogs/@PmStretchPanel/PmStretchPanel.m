function hObj=PmStretchPanel(varargin)




    hObj=PMDialogs.PmStretchPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    hBlock=0;
    if(nargin>0)
        hBlock=varargin{1};
    end


    hObj.BlockHandle=hBlock;
