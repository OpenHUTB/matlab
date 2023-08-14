function ret=plotUpdateCompRuns(~,sigID1,hFig)



    ret=sigID1;
    if~Simulink.sdi.isValidSignalID(sigID1)
        ret=-1;
        return;
    end


    sigID2=Simulink.sdi.getAlignedID(sigID1);
    eng=Simulink.sdi.Instance.engine;
    if isempty(sigID2)&&isequal(eng.comparedSignal1,sigID1)
        sigID2=eng.comparedSignal2;
    end
    if~Simulink.sdi.isValidSignalID(sigID2)
        ret=-1;
        return;
    end
    try
        result=eng.DiffRunResult.getResultBySignalIDs(sigID1,sigID2);
    catch
        ret=-1;
        return
    end


    if~isempty(result)&&~result.unitsMatch
        msg=getString(message('SDI:sdi:unitsDidNotMatch'));
        hAxes=axes('Parent',hFig,'Visible',hFig.Visible);
        text(0.3,0.5,msg,'Parent',hAxes);
        return
    end


    ss=Simulink.sdi.CustomSnapshot;
    ss.plotComparison(result);
    ss.snapshot('figure',hFig);
end