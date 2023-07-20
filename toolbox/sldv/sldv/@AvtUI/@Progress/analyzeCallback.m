function analyzeCallback(dlgSrc,~)

















    dlgSrc.logPath='';



    if dlgSrc.breakOnCompat
        str=getString(message('Sldv:SldvRun:ProceedingWithAnalysis'));
        str=sprintf('\n%s\n',str);
        dlgSrc.appendToLog(str);
        dlgSrc.breakOnCompat=false;
    end

    modelH=get_param(dlgSrc.modelName,'Handle');
    sldvSession=sldvprivate('sldvGetActiveSession',modelH);
    if~isempty(sldvSession)

        try
            status=sldvSession.launchAnalysis();
        catch








            return;
        end

        if~status

            return;
        end
    end

end
