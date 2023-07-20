function[Ts,WantBlockChoice]=DistributedParameterLineInit(block)






    DistributedParameterLineIcon(block);

    DistributedParameterLineCback(block);
    power_initmask();

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        WantBlockChoice='Phasor';

        FromToGround(block,'From');

        GotoToTerm(block,'Goto');
    end
    if PowerguiInfo.Discrete
        WantBlockChoice='Discrete';
        IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');

        GroundToFrom(block,'From',IsLibrary);

        TermToGoto(block,'Goto',IsLibrary);
    end
    if PowerguiInfo.Continuous
        WantBlockChoice='Continuous';
        IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');

        GroundToFrom(block,'From',IsLibrary);

        TermToGoto(block,'Goto',IsLibrary);
    end