function[varargout]=sim3dblkstractor(varargin)

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

    AliasNames={'Translation','Translation';'Rotation','Rotation';'Scale','Scale'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='sim3dtractor.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end

function Initialization(Block)
    sim3d.utils.SimPool.addActorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehName=MaskObj.getParameter('ActorTag');
    set_param([Block,'/Simulation 3D Tractor'],'ActorTag',vehName.Value);
    ParamList={'SampleTime',[1,1],{'st',0};};
    autoblkscheckparams(Block,ParamList);

end