function[varargout]=autoblksstarter(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'MachineTypePopup'
        MachineTypePopup(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end
end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='energy_starter.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,200,'white');
end

function Initialization(Block)
    StarterOptions=...
    {'autolibstartercommon/Separately Excited DC Machine','Separately Excited DC Machine';
    'autolibstartercommon/PM Excited DC Machine','PM Excited DC Machine';
    'autolibstartercommon/Series Connection DC Machine','Series Connection DC Machine'};


    machine_type=get_param(Block,'machine_type');

    switch machine_type
    case 'Separately Excited DC Motor'
        autoblksenableparameters(Block,[],[],'sedcm',{'pmecm','scdcm'});
    case 'Permanent Magnet Excited DC Motor'
        autoblksenableparameters(Block,[],[],'pmecm',{'sedcm','scdcm'});
    case 'Series Connection DC Motor'
        autoblksenableparameters(Block,[],[],'scdcm',{'pmecm','sedcm'});
    otherwise
        error(message('autoblks:autoerrStarter:invalidMachine'));
    end

    switch machine_type
    case 'Separately Excited DC Motor'
        autoblksreplaceblock(Block,StarterOptions,1);
    case 'Permanent Magnet Excited DC Motor'
        autoblksreplaceblock(Block,StarterOptions,2);
    case 'Series Connection DC Motor'
        autoblksreplaceblock(Block,StarterOptions,3);
    otherwise
        error(message('autoblks:autoerrStarter:invalidMachine'));
    end


    ParamList={'Ra',[1,1],{'gt',0};...
    'La',[1,1],{'gt',0};...
    'Rf',[1,1],{'gt',0};...
    'Lf',[1,1],{'gt',0};...
    'Laf',[1,1],{'gt',0};...
    'Iaf',[1,2],{};...
    'Rapm',[1,1],{'gt',0};...
    'Kt',[1,1],{'gt',0};...
    'Lapm',[1,1],{'gt',0};...
    'Ia',[1,1],{};...
    'Rser',[1,1],{'gt',0};...
    'Lser',[1,1],{'gt',0};...
    'Iafser',[1,1],{};...
    'Lafser',[1,1],{'gt',0};...
    };

    autoblkscheckparams(Block,'Starter',ParamList);
end

function MachineTypePopup(Block)
    machine_type=get_param(Block,'machine_type');


    switch machine_type
    case 'Separately Excited DC Motor'
        autoblksenableparameters(Block,[],[],'sedcm',{'pmecm','scdcm'});
    case 'Permanent Magnet Excited DC Motor'
        autoblksenableparameters(Block,[],[],'pmecm',{'sedcm','scdcm'});
    case 'Series Connection DC Motor'
        autoblksenableparameters(Block,[],[],'scdcm',{'pmecm','sedcm'});
    otherwise
        error(message('autoblks:autoerrStarter:invalidMachine'));
    end
end