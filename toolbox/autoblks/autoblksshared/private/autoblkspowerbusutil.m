function varargout=autoblkspowerbusutil(varargin)



    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'OpenFcn'
        OpenFcn(Block)
    case 'CloseFcn'
        CloseFcn(Block)
    end

end


function Initialization(Block)


    SwitchInport(Block,'PwrTrnsfrd','PwrTrnsfrdCheckBox')
    SwitchInport(Block,'PwrNotTrnsfrd','PwrNotTrnsfrdCheckBox')
    SwitchInport(Block,'PwrStored','PwrStoredCheckBox')

    InportNames={'PwrTrnsfrd';'PwrNotTrnsfrd';'PwrStored'};

    FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end

end


function OpenFcn(Block)
    obj=autoblks.pwr.PwrInfoBus(Block);

    obj.GetInputSignals;
    obj.ShowDialog;
end

function CloseFcn(Block)
    obj=autoblks.pwr.PwrInfoBus(Block);
    obj.CloseDialog;
end


function SwitchInport(Block,PortName,CheckBoxName)

    InportOption={'autolibpowerinfoutilscommon/No Power Bus Input',['No ',PortName,' Input'];...
    'autolibpowerinfoutilscommon/Power Bus Input',[PortName,' Input']};
    if strcmp(get_param(Block,CheckBoxName),'off')
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
    else
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,2);
        ph=get_param(NewBlkHdl,'PortHandles');
        LineHdl=get_param(ph.Inport(1),'Line');
        Inport=get_param(LineHdl,'SrcBlockHandle');
        set_param(Inport,'Name',PortName)
    end

    ph=get_param(NewBlkHdl,'PortHandles');
    set_param(ph.Outport,'Name',PortName)
end