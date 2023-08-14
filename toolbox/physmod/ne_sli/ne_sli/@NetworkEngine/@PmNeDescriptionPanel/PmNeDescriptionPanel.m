function hObj=PmNeDescriptionPanel(varargin)




    hObj=NetworkEngine.PmNeDescriptionPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;


    p=inputParser();
    p.addOptional('blockHandle',0,@(n)isscalar(n)&&isnumeric(n));
    p.addOptional('descrText','<<Blank>>',@ischar);
    p.addOptional('blockTitle','<<Blank>>',@ischar);
    p.parse(varargin{:});


    hObj.BlockHandle=p.Results.blockHandle;
    hObj.DescrText=p.Results.descrText;
    hObj.BlockTitle=p.Results.blockTitle;


    hObj.Need2Realize=true;
    hObj.Label='';

end
