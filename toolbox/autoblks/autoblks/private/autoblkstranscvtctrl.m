function[varargout]=autoblkstranscvtctrl(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end
end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='trans_controller_cvt.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,60,150,'white');
end

function Initialization(Block)

    ParamList={...
    'rp_max',[1,1],{'gt',0;'lt',10};...
    'rs_max',[1,1],{'gt',0;'lt',10};...
    'rp_min',[1,1],{'gt',0;'lt',10};...
    'rs_min',[1,1],{'gt',0;'lt',10};...
    'rgap',[1,1],{'gt',0;'lt',10};...
    'thetaWedge',[1,1],{'gt',0;'lt',90};...
    };
    autoblkscheckparams(Block,'AUTOBLKSTRANSCVTCTRL',ParamList);
end