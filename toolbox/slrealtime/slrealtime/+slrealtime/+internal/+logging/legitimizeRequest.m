function reqRuns=legitimizeRequest(request,varargin)









    narginchk(3,3);
    if istable(request)
        validateattributes(request,{'table'},{'nonempty'});
    elseif isnumeric(request)
        validateattributes(request,{'numeric'},{'vector','nonempty','positive'});
    else
        validateattributes(request,{'string','char'},{'nonempty','vector'});
    end

    parser=inputParser();
    parser.FunctionName="slrealtime.internal.logging.legitimizeRequest";
    parser.addParameter("Target",[],@(x)validateattributes(x,{'slrealtime.Target'},{'scalar','nonempty'}));
    parser.addParameter("LocalRunTable",[],@(x)validateattributes(x,{'table'},{'nonempty'}));
    parser.parse(varargin{:});

    if~isempty(parser.Results.Target)

        queuedRuns=parser.Results.Target.FileLog.BufferedLogger.getRunQueue();
        availRuns=slrealtime.internal.logging.targetLogData(parser.Results.Target);
        availRuns=slrealtime.internal.logging.FileLogger.filterQueuedRuns(availRuns,queuedRuns);
    else

        availRuns=parser.Results.LocalRunTable;
    end

    reqRuns=table;

    if isempty(availRuns)
        error(message('slrealtime:logging:NoLogData'));
    end


    if isstring(request)

        request=unique(request);
        rows=contains(availRuns.Application,request);
        reqRuns=availRuns(rows,:);
        if length(unique(reqRuns.Application))~=length(request)
            error(message('slrealtime:logging:MissingLogData'));
        end
    elseif ischar(request)

        request=string(request);
        reqRuns=availRuns(availRuns.Application==request,:);
        if isempty(reqRuns)
            error(message('slrealtime:logging:MissingLogData'));
        end
    elseif isnumeric(request)

        reqRuns=availRuns(request,:);
    elseif istable(request)

        colNames=request.Properties.VariableNames;
        if(~any(contains(colNames,'Application'))||...
            ~isstring(request.Application)||...
            ~isdatetime(request.StartDate))
            error(message('slrealtime:logging:InvalidTable'));
        end

        rows=(contains(availRuns.Application,request.Application)&contains(...
        string(availRuns.StartDate),string(request.StartDate)));
        reqRuns=availRuns(rows,:);

        if height(reqRuns)~=height(request)
            error(message('slrealtime:logging:MissingLogData'));
        end
    end


    if~isempty(parser.Results.Target)
        tg=parser.Results.Target;
        [running,runningAppName]=tg.isRunning();
        runningAppName=string(runningAppName);
        reqRuns.Active=boolean(zeros(height(reqRuns),1));

        tc=tg.get('tc');
        isLogging=(tc.LoggingState==slrealtime.internal.logging.LoggingState.RUNNING);
        if isLogging

            modelRuns=availRuns(availRuns.Application==runningAppName,:);
            curRun=modelRuns(end,:);
            reqRuns.Active=reqRuns.Application==curRun.Application&string(reqRuns.StartDate)==string(curRun.StartDate);
        end

        hasEnableBlock=false;
        if running
            blockToken=strcat(tg.appsDirOnTarget,"/",runningAppName,"/misc/enablefilelog.dat");
            if any(contains(reqRuns.Application,runningAppName))

                if tg.isfile(blockToken)
                    hasEnableBlock=true;
                    if tc.LoggingState==slrealtime.internal.logging.LoggingState.RUNNING
                        if any(reqRuns.Active)

                            error(message('slrealtime:logging:CannotImportCurrentRun'));
                        end
                    end
                end
            end
        end
    end
end

