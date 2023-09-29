function[varargout]=sim3dblksrayget(varargin)

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


function Initialization(Block)
    autoblkscheckparams(Block,{'Ts',[1,1],{'st',0}});
end


function IconInfo=DrawCommands(Block)
    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);

    IconInfo.ImageName='sim3dray.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,100,'white');
end
