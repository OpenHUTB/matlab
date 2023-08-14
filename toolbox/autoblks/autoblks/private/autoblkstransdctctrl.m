function[varargout]=autoblkstransdctctrl(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 0
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end
end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'Gear Request','GearReq';'Info','Info';'Nominal Gear','NomGear';'Clutch A','ClutchA';'Clutch B','ClutchB'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='trans_controller_dct.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,60,150,'white');
end

function Initialization(Block)

    ParamList={...
    'G_o',[1,1],{'int',0};...
    'tc',[1,1],{'gt',0};...
    'ts',[1,1],{'gt',0};...
    'dt',[1,1],{'st',0};...
    };
    autoblkscheckparams(Block,'AUTOBLKSTRANSDCTCTRL',ParamList);
end