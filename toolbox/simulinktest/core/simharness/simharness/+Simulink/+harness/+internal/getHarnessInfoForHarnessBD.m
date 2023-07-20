function result=getHarnessInfoForHarnessBD(harnessBD)




    result=[];

    sysBD=Simulink.harness.internal.getHarnessOwnerBD(harnessBD);
    if isempty(sysBD)
        return;
    end

    if slfeature('MultipleHarnessOpen')>0
        harnessBDName=get_param(harnessBD,'Name');
        result=Simulink.harness.find(sysBD,'Name',harnessBDName);
    else
        result=Simulink.harness.find(sysBD,'OpenOnly','on');
    end
