function exportSignals(tg,hasFileLogRun)






    try

        tc=tg.get('tc');
        mldatxfile=getAppFile(tg,tc.ModelProperties.Application);
        appObj=slrealtime.internal.Application(mldatxfile);
        metadata=slrealtime.internal.deserializeMetadata(appObj,'/signalExport/','signalLogging');


        if strcmp(metadata.SignalLogging,'on')
            signals=[];
            if~isempty(tg.SDIRunId)&&Simulink.sdi.isValidRunID(tg.SDIRunId)

                signals=Simulink.sdi.internal.getStreamedRunDataForModel(tc.ModelProperties.Application,'logsout',[],[],'signal',[],false,[],tg.TargetSettings.name);
            end


            if isempty(tg.SDIRunId)&&hasFileLogRun
                if~isempty(tg.FileLog.BufferedLogger.SDIRunId)&&Simulink.sdi.isValidRunID(tg.FileLog.BufferedLogger.SDIRunId)

                    signals=Simulink.sdi.internal.getStreamedRunDataForModel(tc.ModelProperties.Application,'logsout',[],[],'signal',[],false,[],tg.TargetSettings.name);
                end
            end

            if~isempty(signals)


                assignin('base',metadata.SignalLoggingName,signals);
            elseif evalin('base','exist(''logsOut'',''var'')==1')&&isempty(signals)



                signals=[];
                assignin('base',metadata.SignalLoggingName,signals);
            end

        end

    catch ME

        if(strcmp(ME.identifier,'MATLAB:dispatcher:noMatchingConstructor'))
            error(message('slrealtime:target:signalExportError',tg.TargetSettings.name,string(message('slrealtime:target:appDoesNotExist'))));
        else
            error(message('slrealtime:target:signalExportError',tg.TargetSettings.name,''));
        end
    end

end


