function slavteng_activity_callback(tcompUdi,jnk)







    warnBTModeName='backtrace';
    warnBTModeState=warning('query',warnBTModeName);
    warning('off',warnBTModeName);


    restoreWarnings=onCleanup(@()warning(warnBTModeState.state,warnBTModeName));

    if~isempty(tcompUdi.progressUI)
        tcompUdi.progressUI.activity();


        if~slavteng('feature','IncrementalHighlighting')

            modelH=tcompUdi.analysisInfo.designModelH;
            session=sldvprivate('sldvGetActiveSession',modelH);
            if session.HighlightStatusFlag
                tcompUdi.progressUI.highlightPartialResults();
            end
        else

            tcompUdi.progressUI.highlightPartialResults();
        end
    end

end
