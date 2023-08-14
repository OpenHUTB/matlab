function hObj=PmGuiDropDown(varargin)



















    p=inputParser;
    addRequired(p,'BlockHandle',@ishandle);
    addRequired(p,'ValueBlkParam',@isvarname);
    addRequired(p,'Label',@ischar);
    addRequired(p,'LabelAttrb',@isnumeric);
    addRequired(p,'Choices',@iscell);
    addRequired(p,'ChoiceVals',@isnumeric);
    addRequired(p,'MapVals',@iscell);

    parse(p,varargin{:});

    hObj=NetworkEngine.PmGuiDropDown;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    r=p.Results;
    hObj.BlockHandle=r.BlockHandle;
    hObj.ValueBlkParam=r.ValueBlkParam;
    hObj.Label=r.Label;
    hObj.LabelAttrb=r.LabelAttrb;
    hObj.Choices=r.Choices;
    hObj.ChoiceVals=r.ChoiceVals;
    hObj.MapVals=r.MapVals;

end