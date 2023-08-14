function init_logging(model,selectiveLoggingPaths,isRapidAccel)




    if nargin==2
        isRapidAccel=false;
    end


    settings=loggingSettings(model);


    if strcmpi(settings.LogType,'none')
        builtin('_ssc_remove_simulation_manager',model);
    end



    noBlockSelected=strcmpi(settings.LogType,'local')&&...
    isempty(selectiveLoggingPaths);

    isLogged=~strcmpi(settings.LogType,'none');
    isLoggingSupported=false;
    if isLogged


        isLoggingSupported=checkLoggingSupport(model,isRapidAccel);
    end

    if isLogged&&isLoggingSupported
        simscape.logging.sli.internal.addVarToSimulationOutput(...
        model,settings.LogName);


        options.logName=settings.LogName;
        options.decimation=uint32(settings.Decimation);
        options.isSelective=strcmpi(settings.LogType,'local');
        options.selectiveLoggingPaths=selectiveLoggingPaths;





        logToSDI=settings.LogToSDI;
        if logToSDI&&(isRapidAccel||...
            strcmpi(get_param(model,'SimulationMode'),'rapid-accelerator'))
            logToSDI=false;
        end
        options.recordInSDI=logToSDI;
        options.recordInDisk=settings.LogToDisk;
        options.monotonic=settings.Monotonic;
        options.reinitialize=settings.Reinitialize;
        options.timestamp=settings.Timestamp;
        options.simulationStatistics=settings.SimulationStatistics;
        options.logPoints=settings.DataHistory;
        options.isRapidAccel=isRapidAccel;

        builtin('_ssc_create_logging_manager',model,options);

        openViewer=strcmpi(get_param(model,'SimscapeLogOpenViewer'),'on');
        if openViewer
            if~noBlockSelected
                simscape.logging.sli.internal.loggingListeners(model,@lOpenViewer);
                blockDiagram=get_param(model,'Object');
                cbId='SimscapeLoggingListener';
                if(blockDiagram.hasCallback('PreClose',cbId))
                    blockDiagram.removeCallback('PreClose',cbId);
                end
                blockDiagram.addCallback('PreClose',cbId,...
                @()(simscape.logging.sli.internal.loggingListeners(model,[])));
            else
                pm_warning('physmod:simscape:logging:sli:kernel:NoBlockSelected',model);
                simscape.logging.sli.internal.loggingListeners(model,[]);
            end
        else
            simscape.logging.sli.internal.loggingListeners(model,[]);
        end
    end
end

function lOpenViewer(model,varname,node)
    if strcmpi(get_param(model,'SimscapeLogToSDI'),'on')
        Simulink.sdi.view;
    else
        simscape.logging.internal.explore(node,'',varname);
    end
end
