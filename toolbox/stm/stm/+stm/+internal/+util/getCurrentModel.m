function mdl=getCurrentModel()



    mdl=bdroot;


    if isempty(mdl)
        return
    end

    if~isempty(mdl)&&...
        Simulink.harness.isHarnessBD(mdl)
        mdl=getHarnessOwnerBD(mdl);
    end
end

function res=getHarnessOwnerBD(sys)

    bdname=sys;
    if ishandle(sys)
        bdname=get_param(sys,'Name');
    end
    res=Simulink.harness.internal.getHarnessOwnerBD(bdname);
end
