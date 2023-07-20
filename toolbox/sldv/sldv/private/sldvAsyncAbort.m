function sldvAsyncAbort(chn)






    warnBTModeName='backtrace';
    warnBTModeState=warning('query',warnBTModeName);
    warning('off',warnBTModeName);


    restoreWarnings=onCleanup(@()warning(warnBTModeState.state,warnBTModeName));

    if~isempty(chn)






        sldvCleanAnalysis();

        chn.execute('abort');
    end

end
