function hObj=PmDescriptionPanel(varargin)




    hObj=PMDialogs.PmDescriptionPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    hBlock=0;
    if(nargin>0)
        hBlock=varargin{1};
    end


    hObj.BlockHandle=hBlock;
    hObj.DescrText='<<BLANK>>';


    hObj.Need2Realize=true;
    hObj.BlockTitle='<<BLANK>>';
