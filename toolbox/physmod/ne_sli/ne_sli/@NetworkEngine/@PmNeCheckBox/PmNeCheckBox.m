function hObj=PmNeCheckBox(varargin)



















    p=inputParser;
    addRequired(p,'BlockHandle',@ishandle);
    addRequired(p,'ValueBlkParam',@isvarname);
    addRequired(p,'Label',@ischar);
    addRequired(p,'LabelAttrb',@isnumeric);

    parse(p,varargin{:});

    hObj=NetworkEngine.PmNeCheckBox;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    r=p.Results;
    hObj.BlockHandle=r.BlockHandle;
    hObj.ValueBlkParam=r.ValueBlkParam;
    hObj.Label=r.Label;
    hObj.LabelAttrb=r.LabelAttrb;

end