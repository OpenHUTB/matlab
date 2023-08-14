function[varargout]=autoblksalternator(varargin)



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


    IconInfo.ImageName='energy_alternator.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,60,150,'white');
end

function Initialization(Block)


    ParamList={'Kv',[1,1],{'gt',0};...
    'Rf',[1,1],{'gt',0};...
    'Lf',[1,1],{'gt',0};...
    'Fv',[1,1],{'gt',0};...
    'Fc',[1,1],{'gt',0};...
    'Fv',[1,1],{'gt',0};...
    'Vfmax',[1,1],{'gt',0};...
    'Vfmin',[1,1],{'lt',0};...
    'Kc',[1,1],{'gte',0};...
    'Kb',[1,1],{'gte',0};...
    'Kw',[1,1],{'gte',0};...
    'Vd',[1,1],{'gte',0};...
    'Rs',[1,1],{'gte',0};...
    };

    autoblkscheckparams(Block,'Reduced Lundell Alternator',ParamList);
end