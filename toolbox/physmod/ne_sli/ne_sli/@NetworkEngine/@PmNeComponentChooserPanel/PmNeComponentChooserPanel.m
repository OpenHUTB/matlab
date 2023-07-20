function hObj=PmNeComponentChooserPanel(varargin)








    hObj=NetworkEngine.PmNeComponentChooserPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    pm_assert(ishandle(varargin{1}));
    hObj.BlockHandle=varargin{1};


    hObj.Enabled=true;

end
