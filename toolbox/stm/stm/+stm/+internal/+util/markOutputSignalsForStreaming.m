function[msgList,instrumentedSignals,dsmOverrides,modelToUse]=markOutputSignalsForStreaming(modelToRun,signalsToMark)














    msgList={};
    modelToUse=modelToRun;
    instrumentedSignals=containers.Map;
    dsmOverrides=containers.Map;
    for signal=signalsToMark
        baseModel=extractBefore(signal.BlockPath,'/');
        if~strcmp(baseModel,modelToRun)


            if~strcmp(modelToRun,signal.TopModel)
                msg=stm.internal.MRT.share.getString('stm:OutputView:SignalNotFoundInModel',signal.Name,'',signal.BlockPath,modelToRun);
                msg=replace(msg,newline,' ');
                msgList{end+1}=msg;%#ok<AGROW>
                continue;
            end
        end

        tmp=strfind(signal.BlockPath,'/');
        modelToUse=signal.BlockPath(1:tmp(1)-1);

        if instrumentedSignals.isKey(modelToUse)==false


            load_system(modelToUse);
            instrumentedSignals(modelToUse)=stm.internal.MRT.share.getInstrumentedSignals(modelToUse);

            preserve_dirty=Simulink.PreserveDirtyFlag(get_param(modelToUse,'Handle'),'blockDiagram');%#ok<NASGU>
        end

        dsmInfo=struct('dsmBlocks',[],'dsmVars',[]);
        if signal.ElementType==stm.internal.SignalLoggingTypes.DsmBlock

            if~strcmp(get_param(signal.BlockPath,'DataLogging'),'on')
                set_param(signal.BlockPath,'DataLogging','on');


                if dsmOverrides.isKey(modelToUse)
                    dsmInfo=dsmOverrides(modelToUse);
                end
                dsmInfo.dsmBlocks=[dsmInfo.dsmBlocks,{signal.BlockPath}];
                dsmOverrides(modelToUse)=dsmInfo;
            end
        elseif signal.ElementType==stm.internal.SignalLoggingTypes.SimulinkSignalObj

            prevState=stm.internal.SignalLogging.setGlobalDataStoreLogging(signal.Name,signal.SDIBlockPath,true,modelToUse);

            if~prevState
                if dsmOverrides.isKey(modelToUse)
                    dsmInfo=dsmOverrides(modelToUse);
                end
                dsVbl=struct('Name',signal.Name,'SourceType',signal.SDIBlockPath);
                dsmInfo.dsmVars=[dsmInfo.dsmVars,dsVbl];
            end
            dsmOverrides(modelToUse)=dsmInfo;
        else

            try
                bHasSDIStreaming=~isempty(which('Simulink.sdi.markSignalForStreaming'));
                if(bHasSDIStreaming)
                    Simulink.sdi.markSignalForStreaming(signal.BlockPath,signal.PortIndex,'on');
                else
                    phs=get_param(signal.BlockPath,'PortHandles');
                    set_param(phs.Outport,'DataLogging','on');
                end
            catch ME


                if signal.id~=-1
                    rethrow(ME);
                end
            end
        end
    end
    clear preserve_dirty;

end
