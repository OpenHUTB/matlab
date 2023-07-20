function retVal=callTLCService(action,tlcCmd,tlcProfilerOn,...
    buildDir,modelName,tlcLogsSaveDir)



















    persistent sharedTLCServerHandle;
    if(isempty(sharedTLCServerHandle))
        sharedTLCServerHandle=-1;
    end


    persistent callStats
    if isempty(callStats)
        callStats=LocResetStats(callStats);
    end

    retVal=[];


    switch(action)
    case 'OutputStats'

        retVal=callStats;
        return;
    case 'CleanUpSharedServer'
        tlcServerList=tlc('list',sharedTLCServerHandle);
        if(sharedTLCServerHandle>=0&&...
            ~isempty(tlcServerList)&&...
            ismember(sharedTLCServerHandle,tlcServerList))
            tlc('close',sharedTLCServerHandle);
        end
        return;
    case 'ResetStats'
        callStats=LocResetStats(callStats);
        return;
    case 'ProvideTLCService'

    otherwise
        DAStudio.error('RTW:buildProcess:callTLCServiceInvalidAction');
    end




    curTLCHandle=-1;
    try

        curTLCHandle=-1;

        if tlcProfilerOn


            serviceMode='OneServerPerCallMode';
        else

            serviceMode=get_param(0,'SlBuildTLCServiceMode');
        end

        switch(serviceMode)
        case 'NoServerMode'

            curTLCHandle=-1;
            callStats.statsNumNoServerCalls=...
            callStats.statsNumNoServerCalls+1;

        case 'OneServerPerSessionMode'

            callStats.statsNumOneServerPerSessionCalls=...
            callStats.statsNumOneServerPerSessionCalls+1;
            tlcServerList=tlc('list',sharedTLCServerHandle);




            if(sharedTLCServerHandle<0||...
                isempty(tlcServerList)||...
                ~ismember(sharedTLCServerHandle,tlcServerList))
                sharedTLCServerHandle=tlc('new');
                callStats.statsNumOneServerPerSessionCreates=...
                callStats.statsNumOneServerPerSessionCreates+1;
            end
            curTLCHandle=sharedTLCServerHandle;


            tlc('cleanglobalscope',curTLCHandle);

        case 'OneServerPerCallMode'

            curTLCHandle=tlc('new');
            callStats.statsNumOneServerPerCallCalls=...
            callStats.statsNumOneServerPerCallCalls+1;

        otherwise
            DAStudio.error('RTW:buildProcess:callTLCServiceUnhandledMode');
        end


        if tlcProfilerOn
            tlc('startprofiler',curTLCHandle);
        end

        if(curTLCHandle<0)


            tlcCmdArgs={};
        else

            tlcCmdArgs={'execcmdline',curTLCHandle};
        end




        tlcStatus=feval(tlcCmd{1},tlcCmdArgs{:},tlcCmd{2:end});
        if(tlcStatus==-2)
            DAStudio.error('RTW:buildProcess:userInterrupt');
        end
    catch exc

        if curTLCHandle>=0
            tlc('close',curTLCHandle);
        end



        if~isequal(curTLCHandle,sharedTLCServerHandle)
            callTLCService('CleanUpSharedServer');
        end
        rethrow(exc);
    end




    if~isempty(tlcLogsSaveDir)
        stowe_away_tlc_logs_for_testing(modelName,buildDir,tlcLogsSaveDir);
    end


    if tlcProfilerOn

        tlc('stopprofiler',curTLCHandle);
        h=tlc('getprofiler',curTLCHandle);
        slprofreport(h,buildDir,modelName);
    end


    if strcmp(serviceMode,'OneServerPerCallMode')

        tlc('close',curTLCHandle);
    end







    function callStats=LocResetStats(callStats)
        callStats.statsNumNoServerCalls=0;
        callStats.statsNumOneServerPerSessionCreates=0;
        callStats.statsNumOneServerPerSessionCalls=0;
        callStats.statsNumOneServerPerCallCalls=0;



