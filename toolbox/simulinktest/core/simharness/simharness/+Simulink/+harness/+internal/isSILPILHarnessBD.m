function result=isSILPILHarnessBD(harnessBD)
    result=false;

    harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(harnessBD);
    if isempty(harnessInfo)
        return;
    end

    assert(length(harnessInfo)==1);
    result=((harnessInfo.verificationMode==1)||(harnessInfo.verificationMode==2));

