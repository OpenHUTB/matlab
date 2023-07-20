function[WantBlockChoice,Index1,MT,SPID]=FullBridgeMMCInit(varargin)





    block=varargin{1};
    ModelType=varargin{2};
    n=max(1,round(varargin{3}));
    n=min(n,1000);
    Ts_user=varargin{4};
    NbIGBTs=varargin{5};

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    if PowerguiInfo.SPID
        SPID.index=1:2:2*n*NbIGBTs;
        SPID.size=2*n*NbIGBTs;
    else
        SPID.index=1:n*NbIGBTs;
        SPID.size=n*NbIGBTs;
    end

    Index1=NbIGBTs*(1:n)-(NbIGBTs-1);

    switch lower(ModelType)
    case 'switching devices'
        WantBlockChoice='IGBTdiodes';
        IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');
        TermToGoto(block,'Goto',IsLibrary);
        GroundToFrom(block,'Uswitch',IsLibrary);
        MT=1;
    case 'switching function'
        if Ts_user>0
            WantBlockChoice='SF Discrete';
        else
            WantBlockChoice='SF Continuous';
        end
        GotoToTerm(block,'Goto');

        FromToGround(block,'Uswitch');
        MT=2;
    case 'average model (uref-controlled)'
        if Ts_user>0
            WantBlockChoice='AVG Discrete';
        else
            WantBlockChoice='AVG Continuous';
        end
        GotoToTerm(block,'Goto');
        FromToGround(block,'Uswitch');
        MT=3;
    case 'aggregate model'
        if Ts_user>0
            WantBlockChoice='AGT Discrete';
        else
            WantBlockChoice='AGT Continuous';
        end
        GotoToTerm(block,'Goto');
        FromToGround(block,'Uswitch');
        MT=4;
    end

    FullBridgeMMCCback(block)