function csType=getRootConfigsetType(cs)



    csType='unknown';





    cur=cs.getComponent('any','Target');
    parent=cur.getComponent('any','Target');

    while~isempty(parent)
        cur=parent;
        parent=cur.getComponent('any','Target');
    end





    if isa(cur,'Simulink.ERTTargetCC')
        csType='ERT';
        return;
    end


    if isa(cur,'Simulink.GRTTargetCC')
        csType='GRT';
        return;
    end


    if isa(cur,'Simulink.RaccelTargetCC')
        csType='Raccel';
        return;
    end

    if isa(cur,'Simulink.STFCustomTargetCC')
        csType='STFCustom';
        return;
    end


    if isa(cur,'RTW.RSimTargetCC')
        csType='RSim';
        return;
    end


    if isa(cur,'RTW.TornadoTargetCC')
        csType='Tornado';
        return;
    end


    if isa(cur,'SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC')||...
        isa(cur,'RTWinTarget.RTWinTargetCC')
        csType='SLDRT';
        return;
    end


    if isa(cur,'TIC6000TgtPkg.C6000TargetCC')
        csType='c6000';
        return;
    end


    if isa(cur,'SimulinkRealTime.SimulinkRealTimeCC')
        csType='SLRT';
        return;
    end
