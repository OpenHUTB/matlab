function[varargout]=sim3dblks3dped(varargin)

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
    AliasNames={'X','X';'Y','Y';'Yaw','Yaw'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);
    IconInfo.ImageName='sim3dpedestrian.png';
    [~,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1);
    IconInfo.position=IconInfo.position+[20,0,0,0];
    IconInfo.image='sim3dpedestrian.svg';
end


function Initialization(Block)
    sim3d.utils.SimPool.addActorTag(Block);
    ParamList={'SampleTime',[1,1],{'st',0};...
    'Scale',[1,3],{'gt',0};};
    autoblkscheckparams(Block,ParamList);
    TransformOutportEnabled=get_param(Block,'TransformOutportEnabled');
    TranslationOutportOptions={'simulink/Sinks/Terminator','Location Terminator';...
    'simulink/Sinks/Out1','Location'};

    if strcmp(TransformOutportEnabled,'off')
        autoblksreplaceblock(Block,TranslationOutportOptions,1);
    else
        autoblksreplaceblock(Block,TranslationOutportOptions,2);
        set_param([Block,'/Location'],'Unit','m')
    end

    RotationOutportOptions={'simulink/Sinks/Terminator','Orientation Terminator';...
    'simulink/Sinks/Out1','Orientation'};
    if strcmp(TransformOutportEnabled,'off')
        autoblksreplaceblock(Block,RotationOutportOptions,1);
    else
        autoblksreplaceblock(Block,RotationOutportOptions,2);
        set_param([Block,'/Orientation'],'Unit','rad')
    end

end