function[varargout]=sim3dblksdolly(varargin)

    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'SetInitialValues'
        SetInitialValues(Block);
    end
end


function IconInfo=DrawCommands(Block)
    AliasNames={'Translation','Translation';'Rotation','Rotation';'Scale','Scale'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);

    IconInfo.ImageName='sim3ddolly.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end


function Initialization(Block)
    sim3d.utils.SimPool.addActorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehName=MaskObj.getParameter('ActorTag');
    set_param([Block,'/Simulation 3D Dolly'],'ActorTag',vehName.Value);
    ParamList={'SampleTime',[1,1],{'st',0};};
    autoblkscheckparams(Block,ParamList);
end


function SetInitialValues(Block)
    MaskObj=get_param(Block,'MaskObject');
    vehType=MaskObj.getParameter('Mesh');

    if(strcmp(vehType.Value,'Two-axle dolly'))
        set_param(Block,'Scale','ones(8,3)');
    elseif(strcmp(vehType.Value,'Three-axle dolly'))
        set_param(Block,'Scale','ones(11,3)');
    else
        set_param(Block,'Scale','ones(5,3)');
    end

end