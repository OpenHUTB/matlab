function[status,dscr]=disableAnalysisBtn(cs,x)




    dscr='';
    mdl=cs.getModel;

    if Sldv.HarnessUtils.isSldvGenHarness(mdl)
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        [status,dscr]=configset.internal.custom.disableOnStandalone(cs,x);
    end

end


