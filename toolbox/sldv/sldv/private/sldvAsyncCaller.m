function[chn,updateListener,doneListener,status]=sldvAsyncCaller(cmd,args,cwd,fName,resFile,listenResultUpdateEvents,callback)







    if nargin<7
        callback=[];
    end


    chn=[];
    updateListener=[];
    doneListener=[];
    status=false;




    warnBTModeName='backtrace';
    warnBTModeState=warning('query',warnBTModeName);
    warning('off',warnBTModeName);


    restoreWarnings=onCleanup(@()warning(warnBTModeState.state,warnBTModeName));

    opts.Command=fullfile(cmd);
    opts.Arguments=[args(2:end),resFile,fName];
    opts.Cwd=fullfile(cwd);
    opts.Delimiter=';';


















    plugindir=fullfile(toolboxdir('shared'),'sldv','bin',computer('arch'));

    if slavteng('feature','PlatformDvo')
        chn=matlabshared.asyncio.internal.Channel(fullfile(plugindir,'libmwsldv_dvoanalyzer_asyncio_device'),...
        fullfile(plugindir,'dvoconverterplugin'),...
        Options=opts);
    else
        chn=matlabshared.asyncio.internal.Channel(fullfile(plugindir,'dvocallerplugin'),...
        fullfile(plugindir,'dvoconverterplugin'),...
        Options=opts);
    end




    if~isempty(callback)
        inStream=chn.InputStream;








        if listenResultUpdateEvents
            updateListener=addlistener(inStream,'DataWritten',@(eventSource,eventData)callback.onAnalysisUpdate(eventSource,eventData));
        end


        doneListener=addlistener(chn,'Done','PostSet',@(eventSource,~)callback.onAnalysisDone(eventSource));
    else




        chn.DataEventsDisabled=true;
    end



    status=false;
    try
        chn.open();
        status=true;
    catch MEx
        LoggerId='sldv::shared::asyncio';
        sldvprivate('SLDV_LOG_DEBUG',LoggerId,MEx.message);
        delete(chn);
        chn=[];
        updateListener=[];
        doneListener=[];
        return;
    end

end



