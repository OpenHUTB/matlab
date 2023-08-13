function[varargout]=sim3dblksactorget(varargin)

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

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='sim3dtransform.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,200,'white');
end

function Initialization(Block)

    ParamList={...
    'CustNumOfParts',[1,1],{'gte',1};...
    'NumberOfParts',[1,1],{'gte',1};...
    'Ts',[1,1],{'st',0};...
    };
    autoblkscheckparams(Block,ParamList);
end