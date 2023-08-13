function[varargout]=sim3dblksstaticmeshactor(varargin)

    varargout{1}={};

    Block=varargin{1};

    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'SetMobility'
        SetMobility(Block);
    case 'SimulatePhysics'
        SimulatePhysics(Block);
    case 'ActorControlEnabled2'
        ActorControlEnabled2(Block);
    end
end

function Initialization(Block)
    ActorControlEnabled(Block)
    EnableOutportTransformPort(Block)
    EnableOutportCollisionPort(Block)
    autoblkscheckparams(Block,{'SampleTime',[1,1],{'st',0}});
end
function ActorControlEnabled(Block)


    MaskObject=get_param(Block,'MaskObject');
    ActorControlEnabled=MaskObject.getParameter('ActorControl');
    TranslationInportOptions={'simulink/Sources/Ground','Translation Ground';...
    'simulink/Sources/In1','Translation'};
    RotationInportOptions={'simulink/Sources/Ground','Rotation Ground';...
    'simulink/Sources/In1','Rotation'};
    ScaleInportOptions={'simulink/Sources/Ground','Scale Ground';...
    'simulink/Sources/In1','Scale'};

    if strcmp(ActorControlEnabled.Value,'off')
        autoblksreplaceblock(Block,TranslationInportOptions,1);
        autoblksreplaceblock(Block,RotationInportOptions,1);
        autoblksreplaceblock(Block,ScaleInportOptions,1);

    else
        autoblksreplaceblock(Block,TranslationInportOptions,2);
        autoblksreplaceblock(Block,RotationInportOptions,2);
        autoblksreplaceblock(Block,ScaleInportOptions,2);
    end
end

function ActorControlEnabled2(Block)
    MaskObject=get_param(Block,'MaskObject');
    ActorControlEnabled=MaskObject.getParameter('ActorControl');
    ControlledActor=MaskObject.getParameter('ControlledActor');
    SimPhys=MaskObject.getParameter('SimulatePhysics');
    EnGrav=MaskObject.getParameter('EnableGravity');

    if strcmp(ActorControlEnabled.Value,'on')
        EnGrav.Visible='off';
        set_param(Block,'EnableGravity','off');
        ControlledActor.Visible='on';
    else
        ControlledActor.Visible='off';
        if strcmp(SimPhys.Value,'on')
            EnGrav.Visible='on';
        else
            EnGrav.Visible='off';
        end
    end
end

function SetMobility(Block)

    MaskObject=get_param(Block,'MaskObject');
    ActorControlEnabled=MaskObject.getParameter('ActorControl');
    SimPhys=MaskObject.getParameter('SimulatePhysics');
    EnGrav=MaskObject.getParameter('EnableGravity');
    Mobility=MaskObject.getParameter('Mobility');

    if strcmp(Mobility.Value,'Static')
        set_param(Block,'SimulatePhysics','off');
        set_param(Block,'EnableGravity','off');
        SimPhys.Visible='off';
        EnGrav.Visible='off';
    else
        SimPhys.Visible='on';
        if strcmp(SimPhys.Value,'on')
            if strcmp(ActorControlEnabled.Value,'off')
                EnGrav.Visible='on';
            else
                EnGrav.Visible='off';
            end
        else
            EnGrav.Visible='off';
        end
    end

end

function SimulatePhysics(Block)
    MaskObject=get_param(Block,'MaskObject');
    ActorControlEnabled=MaskObject.getParameter('ActorControl');
    SimPhys=MaskObject.getParameter('SimulatePhysics');
    EnGrav=MaskObject.getParameter('EnableGravity');

    if strcmp(SimPhys.Value,'on')
        if strcmp(ActorControlEnabled.Value,'off')
            EnGrav.Visible='on';
        else
            EnGrav.Visible='off';
        end
    else
        EnGrav.Visible='off';
    end
end

function EnableOutportTransformPort(Block)


    OutputTransformEnabled=get_param(Block,'Parameter15');
    LocationOuportOptions={'simulink/Sinks/Terminator','Location Terminator';...
    'simulink/Sinks/Out1','Location'};
    OrientationOuportOptions={'simulink/Sinks/Terminator','Orientation Terminator';...
    'simulink/Sinks/Out1','Orientation'};

    if strcmp(OutputTransformEnabled,'off')
        autoblksreplaceblock(Block,LocationOuportOptions,1);
        autoblksreplaceblock(Block,OrientationOuportOptions,1);
    else
        autoblksreplaceblock(Block,LocationOuportOptions,2);
        autoblksreplaceblock(Block,OrientationOuportOptions,2);
    end
end

function EnableOutportCollisionPort(Block)


    OutputCollisionEnabled=get_param(Block,'Parameter16');
    CollisionOutportOptions={'simulink/Sinks/Terminator','Collision Terminator';...
    'simulink/Sinks/Out1','Collision_Flag'};

    if strcmp(OutputCollisionEnabled,'off')
        autoblksreplaceblock(Block,CollisionOutportOptions,1);
    else
        autoblksreplaceblock(Block,CollisionOutportOptions,2);
    end
end