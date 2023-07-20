function hObj=DynDescriptionPanel(varargin)




    hObj=PMDialogs.DynDescriptionPanel;
    hObj.CreateInstanceFcn=PMDialogs.DynCreateInstance;
    hObj.assignObjId();


    if(nargin>0&&ishandle(varargin{1}))
        hObj.BlockHandle=varargin{1};
    end

    hObj.DescrText='<<BLANK>>';


    hObj.Need2Realize=true;
    hObj.BlockTitle='Description';
