function abortAnalysis(dlgSrc,dialogH)%#ok<INUSD>






    setStopFlags(dlgSrc);

    activeSession=sldvprivate('sldvGetActiveSession',dlgSrc.testComp.analysisInfo.designModelH);




    assert(~isempty(activeSession)&&isvalid(activeSession));


































    if(activeSession.isAnalysisRunning())
        activeSession.terminateAnalysis();
    end

end

function setStopFlags(dlgSrc)
    dlgSrc.abortSignal=true;
    dlgSrc.stopped=true;
    if~isempty(dlgSrc.dialogH)&&~dlgSrc.closed
        dlgSrc.dialogH.refresh();
    end

end
