function sldvAsyncClose(chn)






    warnBTModeName='backtrace';
    warnBTModeState=warning('query',warnBTModeName);
    warning('off',warnBTModeName);


    restoreWarnings=onCleanup(@()warning(warnBTModeState.state,warnBTModeName));

    if~isempty(chn)


        sldvCleanAnalysis();



        chn.execute('abort');


        chn.close();


        chn=[];
    end

end
