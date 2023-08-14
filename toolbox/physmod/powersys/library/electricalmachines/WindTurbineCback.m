function WindTurbineCback(Block)






    BlockName=getfullname(Block);

    ME=get_param(Block,'MaskEnables');

    aMaskObj=Simulink.Mask.get(Block);
    TurbineTabControl=aMaskObj.getDialogControl('turbinedata');

    ExternalTm=strcmp('on',get_param(BlockName,'ExternalTm'));
    if ExternalTm
        TurbineTabControl.Visible='off';
    else
        TurbineTabControl.Visible='on';
    end

    ExternalVref=strcmp('on',get_param(BlockName,'ExternalVref'));
    if ExternalVref
        ME{22}='off';
    else
        ME{22}='on';
    end

    ExternalQref=strcmp('on',get_param(BlockName,'ExternalQref'));
    if ExternalQref
        ME{24}='off';
    else
        ME{24}='on';
    end

    ExternalIqref=strcmp('on',get_param(BlockName,'ExternalIqref'));
    if ExternalIqref
        ME{26}='off';
    else
        ME{26}='on';
    end

    set_param(BlockName,'MaskEnables',ME);

    MV=get_param(Block,'MaskVisibilities');
    switch get_param(BlockName,'ControlVQ');

    case 'Voltage regulation'

        MV{22}='on';
        MV{23}='on';
        MV{24}='off';
        MV{25}='off';
        MV{28}='on';
        MV{29}='on';
        MV{30}='off';
        MV{35}='on';
        MV{36}='off';

    case 'Var regulation'

        MV{22}='off';
        MV{23}='off';
        MV{24}='on';
        MV{25}='on';
        MV{28}='off';
        MV{29}='off';
        MV{30}='on';
        MV{35}='off';
        MV{36}='on';

    end
    set_param(BlockName,'MaskVisibilities',MV);