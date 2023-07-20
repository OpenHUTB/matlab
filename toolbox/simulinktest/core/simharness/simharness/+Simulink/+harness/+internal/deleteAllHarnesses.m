function deleteAllHarnesses(sys)

    bdname=sys;
    if ishandle(sys)
        bdname=get_param(sys,'Name');
    end

    if Simulink.harness.isHarnessBD(bdname)
        return;
    end

    if~isempty(Simulink.harness.internal.getHarnessList(bdname))
        Simulink.harness.internal.deleteHarnesses(bdname);
    end






