function generateReducerLog(rManager,err)








    if~exist(rManager.getOptions().OutputFolder,'dir')


        return;
    end


    if~isempty(err)&&isa(err,'MException')&&...
        any(strcmp(err.identifier,rManager.getEnvironment().ErrorsForNoLog))
        return;
    end


    callbacks=Simulink.variant.reducer.types.VRedCallback;
    if isempty(err)
        callbacks=i_getCallbacks(rManager);
    end



    if rManager.getOptions().GenerateReport
        rManager.ReportDataObj.Callbacks=callbacks;
    end

    logFileObj=Simulink.variant.reducer.LogHandler();






    logFileObj.createLog(rManager.getOptions().AbsOutDirPath);

    logMsg=message('Simulink:Variants:MATLABTimeStamp',datestr(now),version);
    logFileObj.write(logMsg.getString());

    logMsg=message('Simulink:Variants:ReducerLogMsg',...
    rManager.getOptions().TopModelName,rManager.getOptions().TopModelOrigName);
    logFileObj.write(logMsg.getString());
    logFileObj.appendLines();

    logMsg=message('Simulink:Variants:ReducerLogCautionMsg');
    logFileObj.write(logMsg.getString());
    logFileObj.appendLines(2);


    logMsg=message('Simulink:Variants:ReducerCommandPrefix');
    logFileObj.write(logMsg.getString());
    logFileObj.appendLines();

    logFileObj.write(rManager.getOptions().Command);
    logFileObj.appendLines(2);


    logStateflowChartsWithVariantTransitions(rManager,logFileObj);


    mdlCallbacks=callbacks.mdlCallbacks;
    if~isempty(mdlCallbacks)
        logMsg=message('Simulink:Variants:ReducerModelCallbackMsg');
        logFileObj.write(logMsg.getString());
        logFileObj.appendLines();
        for mdlCallbkId=1:numel(mdlCallbacks)
            logFileObj.write([mdlCallbacks(mdlCallbkId).ModelName,': ']);
            logFileObj.appendLines();
            for callbkId=1:numel(mdlCallbacks(mdlCallbkId).Callbacks)
                logFileObj.write(mdlCallbacks(mdlCallbkId).Callbacks{callbkId});
                logFileObj.appendLines();
            end
            logFileObj.appendLines();
        end
        logFileObj.appendLines();
    end

    blkCallbacks=callbacks.blkCallbacks;
    if~isempty(blkCallbacks)
        logMsg=message('Simulink:Variants:ReducerBlockCallbackMsg');
        logFileObj.write(logMsg.getString());
        logFileObj.appendLines();
        for blkCallbkId=1:numel(blkCallbacks)
            logFileObj.write([blkCallbacks(blkCallbkId).BlkPaths,': ']);
            logFileObj.appendLines();
            for callbkId=1:numel(blkCallbacks(blkCallbkId).Callbacks)
                logFileObj.write(blkCallbacks(blkCallbkId).Callbacks{callbkId});
                logFileObj.appendLines();
            end
            logFileObj.appendLines();
        end
        logFileObj.appendLines();
    end

    portCallbacks=callbacks.portCallbacks;
    if~isempty(portCallbacks)
        logMsg=message('Simulink:Variants:ReducerPortCallbackMsg');
        logFileObj.write(logMsg.getString());
        logFileObj.appendLines();
        for portCallbkId=1:numel(portCallbacks)
            logFileObj.write([portCallbacks(portCallbkId).BlkPaths,': ']);
            logFileObj.appendLines();
            for callbkId=1:numel(portCallbacks(portCallbkId).Callbacks)
                logFileObj.write(portCallbacks(portCallbkId).Callbacks{callbkId});
                logFileObj.appendLines();
            end
            logFileObj.appendLines();
        end
        logFileObj.appendLines();
    end

    maskCallbacks=callbacks.maskCallbacks;
    if~isempty(maskCallbacks)
        logMsg=message('Simulink:Variants:ReducerMaskCallbackMsg');
        logFileObj.write(logMsg.getString());
        logFileObj.appendLines();
        for maskCallbkId=1:numel(maskCallbacks)
            logFileObj.write(maskCallbacks(maskCallbkId).BlkPaths);
            logFileObj.appendLines();
        end
        logFileObj.appendLines();
    end

    failureMessageDetails={};

    if~isempty(err)

        ifCauseExists=isprop(err,'cause');
        if ifCauseExists&&~isempty(err.cause)
            failureMessageDetails=cell(1,numel(err.cause));
            for i=1:numel(err.cause)
                cause=err.cause{i};
                failureMessageDetails{1,i}=cause.message;
            end
        end

        errMsgHeader=message('Simulink:Variants:ReducerLogErrorPrefix');
        logFileObj.write(errMsgHeader.getString());
        logFileObj.appendLines();


        errMsg=regexprep(err.message,'<a\s+href\s*=\s*"[^"]*"[^>]*>(.*?)</a>','$1');
        logFileObj.write(errMsg);
        logFileObj.appendLines();

        if~isempty(failureMessageDetails)
            causedBy=message('Simulink:Variants:CausedBy');
            causedBy=causedBy.getString();
            logFileObj.write(causedBy);
            for i=1:numel(failureMessageDetails)
                errMsg=regexprep(failureMessageDetails{i},'<a\s+href\s*=\s*"[^"]*"[^>]*>(.*?)</a>','$1');
                logFileObj.write(errMsg);
                logFileObj.appendLines();
            end
        end
    else
        successMsg=message('Simulink:Variants:VariantReducerSuccessDiffModelNames',...
        rManager.getOptions().RedModelFullName);
        logFileObj.write(successMsg.getString());
        logFileObj.appendLines();

    end

    warnings=rManager.Warnings;
    if~isempty(warnings)
        warnMsgHeader=message('Simulink:Variants:ReducerLogWarningPrefix');
        logFileObj.write(warnMsgHeader.getString());
        logFileObj.appendLines();
        for i=1:numel(warnings)
            warnMsg=regexprep(warnings{i}.message,'<a\s+href\s*=\s*"[^"]*"[^>]*>(.*?)</a>','$1');
            logFileObj.write(warnMsg);
            logFileObj.appendLines();
        end
    end
end

function logStateflowChartsWithVariantTransitions(rManager,logFileObj)
    if isempty(rManager.ProcessedModelInfoStructsVec)
        return;
    end

    compActiveBlocks={rManager.ProcessedModelInfoStructsVec(1).ConfigInfos.CompiledBlocks};
    compActiveBlocks=vertcat(compActiveBlocks{:});
    compActiveBlocks=unique(compActiveBlocks);

    sfBlks=[];

    for blkI=1:numel(compActiveBlocks)
        blk=compActiveBlocks{blkI};

        blkH=getSimulinkBlockHandle(blk);
        if(blkH==-1)
            continue;
        end

        blk=i_getModifiedBlockPath(blk,rManager.BDNameRedBDNameMap);
        blkH=getSimulinkBlockHandle(blk);
        if(blkH==-1)
            continue;
        end

        if~Simulink.variant.utils.isSFChart(blkH)
            continue;
        end

        chartInfo=Simulink.variant.utils.getSFObj(blk,Simulink.variant.utils.StateflowObjectType.CHART);
        if isempty(chartInfo)
            continue;
        end

        chartId=chartInfo.Id;
        varTransInfo=Stateflow.Variants.VariantMgr.getAllVariantConditionsInChart(chartId);
        if isempty(varTransInfo)
            continue;
        end

        sfBlks(end+1)=blkH;%#ok<AGROW>
    end

    if isempty(sfBlks)
        return;
    end



    if rManager.getOptions().GenerateReport
        rManager.ReportDataObj.SFChartContainingVariantTrans=sfBlks(:);
    end

    msg=message('Simulink:VariantReducer:VarSFTransNotSupported');
    logFileObj.write(msg.getString());
    logFileObj.appendLines();

    for sfBlkI=1:numel(sfBlks)
        logFileObj.write(getfullname(sfBlks(sfBlkI)));
        logFileObj.appendLines();
    end
    logFileObj.appendLines();
end


