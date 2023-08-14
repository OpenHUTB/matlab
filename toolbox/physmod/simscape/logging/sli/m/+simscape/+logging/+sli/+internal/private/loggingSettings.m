function settings=loggingSettings(model)






    settings=[];







    settings.LogName=[lGetValue(model,'Name'),'_log'];
    settings.Decimation=1;
    settings.DataHistory=5000;
    dataHistoryStr='on';
    openViewerStr='off';
    logToSDIStr='off';
    logZCStr='off';
    fastRestartStr='off';
    settings.Timestamp=0;
    doWarn=true;

    settings.LogType=pmsl_modelparameter(model,'SimscapeLogType','none');
    if~strcmp(settings.LogType,'none')
        settings.LogName=pmsl_modelparameter(model,'SimscapeLogName',...
        settings.LogName,doWarn,settings.LogName);
        if~isvarname(settings.LogName)
            pm_error('physmod:simscape:logging:sli:settings:InvalidLogName',...
            settings.LogName);
        end

        isPositiveScalarInteger=@(number)(isnumeric(number)&&...
        isscalar(number)&&floor(number)==number&&number>0);

        settings.Decimation=pmsl_modelparameter(model,'SimscapeLogDecimation',...
        settings.Decimation,doWarn,int2str(settings.Decimation));
        if~isPositiveScalarInteger(settings.Decimation)
            pm_error('physmod:simscape:logging:sli:settings:InvalidDecimation',...
            int2str(settings.Decimation));
        end

        settings.OpenViewer=strcmpi(...
        pmsl_modelparameter(model,'SimscapeLogOpenViewer',openViewerStr,...
        doWarn,openViewerStr),'on');
        settings.LogToSDI=strcmpi(...
        pmsl_modelparameter(model,'SimscapeLogToSDI',logToSDIStr,...
        doWarn,logToSDIStr),'on');

        settings.LogToDisk=strcmpi(...
        simscape.internal.getDiskLoggingPreference(),'on');
        settings.Monotonic=true;
        settings.Reinitialize=strcmpi(...
        pmsl_modelparameter(model,'FastRestart',fastRestartStr,...
        doWarn,fastRestartStr),'on');
        settings.Timestamp=pmsl_modelparameter(model,'RTWModifiedTimeStamp',...
        settings.Timestamp,doWarn,int2str(settings.Timestamp));
        settings.SimulationStatistics=strcmpi(...
        pmsl_modelparameter(model,'SimscapeLogSimulationStatistics',logZCStr,...
        doWarn,logZCStr),'on');
        settings.LogLimitData=strcmpi(...
        pmsl_modelparameter(model,'SimscapeLogLimitData',dataHistoryStr,...
        doWarn,dataHistoryStr),'on');

        if settings.LogLimitData
            settings.DataHistory=pmsl_modelparameter(model,'SimscapeLogDataHistory',...
            settings.DataHistory,doWarn,int2str(settings.DataHistory));
            if~isPositiveScalarInteger(settings.DataHistory)
                pm_error('physmod:simscape:logging:sli:settings:InvalidLimitDataPoints',...
                int2str(settings.DataHistory));
            end
        else
            settings.DataHistory=0;
        end
    end
end

function value=lGetValue(model,paramName)
    try
        value=get_param(model,paramName);
    catch
        pm_error('physmod:simscape:logging:sli:settings:SimscapeParameterNotFound',...
        model,paramName);
    end
end

