function hfcns=extmode_xcp_open()












    hfcns.i_UserExceptionsEnabled=@i_UserExceptionsEnabled;
    hfcns.i_UserHandleError=@i_UserHandleError;
    hfcns.i_UserInit=@i_UserInit;
    hfcns.i_UserConnect=@i_UserConnect;
    hfcns.i_UserSetParam=@i_UserSetParam;
    hfcns.i_UserGetParam=@i_UserGetParam;
    hfcns.i_UserSignalSelect=@i_UserSignalSelect;
    hfcns.i_UserSignalSelectFloating=@i_UserSignalSelectFloating;
    hfcns.i_UserTriggerSelect=@i_UserTriggerSelect;
    hfcns.i_UserTriggerSelectFloating=@i_UserTriggerSelectFloating;
    hfcns.i_UserTriggerArm=@i_UserTriggerArm;
    hfcns.i_UserTriggerArmFloating=@i_UserTriggerArmFloating;
    hfcns.i_UserCancelLogging=@i_UserCancelLogging;
    hfcns.i_UserCancelLoggingFloating=@i_UserCancelLoggingFloating;
    hfcns.i_UserStart=@i_UserStart;
    hfcns.i_UserStop=@i_UserStop;
    hfcns.i_UserPause=@i_UserPause;
    hfcns.i_UserStep=@i_UserStep;
    hfcns.i_UserContinue=@i_UserContinue;
    hfcns.i_UserGetTime=@i_UserGetTime;
    hfcns.i_UserDisconnect=@i_UserDisconnect;
    hfcns.i_UserDisconnectImmediate=@i_UserDisconnectImmediate;
    hfcns.i_UserDisconnectConfirmed=@i_UserDisconnectConfirmed;
    hfcns.i_UserTargetStopped=@i_UserTargetStopped;
    hfcns.i_UserFinalUpload=@i_UserFinalUpload;
    hfcns.i_UserCheckData=@i_UserCheckData;
end





function[glbVars,exceptionsEnabled]=i_UserExceptionsEnabled(glbVars)






    exceptionsEnabled=true;

end


function glbVars=i_UserHandleError(glbVars,~)




    if isfield(glbVars,'xcp')

        glbVars=locResetStatus(glbVars);
    end

end


function glbVars=i_UserInit(glbVars)








    extMode=get_param(glbVars.glbModel,'ExtMode');
    if strcmp(extMode,'off')
        DAStudio.error('coder_xcp:host:ExtModeMustBeOn',glbVars.glbModel);
    end

    glbVars=locResetGlobals(glbVars);


    extModeMexArgs=get_param(glbVars.glbModel,'ExtModeMexArgs');


    cs=getActiveConfigSet(glbVars.glbModel);
    assert(coder.internal.xcp.isXCPTarget(cs));
    index=get_param(cs,'ExtModeTransport');
    transport=Simulink.ExtMode.Transports.getExtModeTransport(cs,index);


    glbVars.xcp.buildDir=RTW.getBuildDir(glbVars.glbModel);
    assert(~isempty(glbVars.xcp.buildDir),'invalid build directory');




    folders=Simulink.filegen.internal.FolderConfiguration(glbVars.glbModel);
    isSimulationBuild=false;
    okayToPushNags=false;
    coder.internal.folders.MarkerFile.checkFolderConfiguration(folders,...
    isSimulationBuild,...
    okayToPushNags);


    buildInfo=coder.make.internal.loadBuildInfo(glbVars.xcp.buildDir.BuildDirectory);
    defineMap=coder.internal.xcp.a2l.DefineMapFactory.fromBuildInfo(buildInfo);
    glbVars.xcp.timestampBasedOnSimulationTime=defineMap.isKey('XCP_TIMESTAMP_BASED_ON_SIMULATION_TIME');

    glbVars.xcp.extModeMexArgs=coder.internal.xcp.parseExtModeArgs(extModeMexArgs,transport,glbVars.glbModel,glbVars.xcp.buildDir.CodeGenFolder,buildInfo);


    glbVars.xcp.verbosityLevel=glbVars.xcp.extModeMexArgs.verbosityLevel;
    glbVars.xcp.targetPollingTime=glbVars.xcp.extModeMexArgs.targetPollingTime;

    locPrintDebugInfo(glbVars,'action: EXT_INIT');
    locPrintTargetHandlerDebugInfo(glbVars);



    glbVars.xcp.target=locCreateXCPTargetHandler(glbVars.xcp.buildDir.BuildDirectory,...
    glbVars.xcp.extModeMexArgs);

end


function[glbVars,status,checksum1,checksum2,checksum3,checksum4,...
    intCodeOnly,tgtStatus]=i_UserConnect(glbVars)













    status=0;

    glbVars.xcp.BaseRatePeriod=str2double(get_param(glbVars.glbModel,'CompiledStepSize'));


    assert(~isnan(glbVars.xcp.BaseRatePeriod));

    locPrintDebugInfo(glbVars,'action: EXT_CONNECT');


    if~isfile(glbVars.xcp.extModeMexArgs.symbolsFileName)
        DAStudio.error('coder_xcp:host:SymbolsFileNotFound',glbVars.xcp.extModeMexArgs.symbolsFileName);
    end

    locPrintDebugInfo(glbVars,'Connecting to the target...');



    timeouts=repelem(glbVars.xcp.targetPollingTime,coder.internal.xcp.XCPTargetHandler.XCP_TIMEOUTS_NUMBER);
    glbVars.xcp.target.initConnection(timeouts);


    glbVars.xcp.modelStatus=glbVars.xcp.target.getModelStatus();
    tgtStatus=locConvertTargetStatus(glbVars.xcp.modelStatus);













    glbVars.xcp.target.classicTriggerAbortPendingRequests();
    glbVars.xcp.classicTriggerStatus=glbVars.xcp.target.getClassicTriggerStatus();






    disableArmWhenConnect=strcmp(get_param(glbVars.glbModel,'ExtModeArmWhenConnect'),'off');
    if disableArmWhenConnect
        glbVars.xcp.target.classicTriggerCancel();
        glbVars.xcp.classicTriggerStatus=coder.internal.xcp.ClassicTriggerStatus.UNARMED;
    end


    [checksum1,checksum2,checksum3,checksum4,intCodeOnly]=glbVars.xcp.target.getModelInfo();
    glbVars.xcp.checksum1=checksum1;
    glbVars.xcp.checksum2=checksum2;
    glbVars.xcp.checksum3=checksum3;
    glbVars.xcp.checksum4=checksum4;
    glbVars.xcp.intCodeOnly=intCodeOnly;

    locPrintModelDebugInfo(glbVars);


    purelyIntegerCode=strcmp(get_param(glbVars.glbModel,'PurelyIntegerCode'),'on');
    if boolean(intCodeOnly)~=purelyIntegerCode
        DAStudio.error('Simulink:Engine:ExtModeOpenProtocolIntegerOnlyMismatch');
    end


    stopTime=str2double(get_param(glbVars.glbModel,'StopTime'));
    glbVars.xcp.target.setModelStopTime(stopTime);



    fromRemoteTarget=true;
    startTime=glbVars.xcp.target.getModelTime(fromRemoteTarget);
    glbVars.xcp.target.setModelStartTime(startTime);

    locPrintDebugInfo(glbVars,'Enabling XCP Synchronous Data Transfer...');


    glbVars.xcp.target.prepareForSyncDataTransfer();

    if coder.internal.connectivity.featureOn('XcpEndOfSimExports')
        set_param(glbVars.glbModel,'ExtModeOpenProtocolInitAsyncQueues',0);
    else
        streamingClients=get_param(glbVars.glbModel,'StreamingClients');
        if isempty(streamingClients)
            streamingClients=Simulink.HMI.StreamingClients(glbVars.glbModel);
        end
        targetName='';
        coder.internal.xcp.createAndBindObservers(glbVars.glbModel,targetName,streamingClients);
    end

    glbVars.xcp.target.startSyncDataTransfer();



    glbVars.xcp.hasInstrumentedSignals=glbVars.xcp.target.hasInstrumentedSignals();
    isXCPProfilingDataTransferEnabled=glbVars.xcp.target.isXCPProfilingDataTransferEnabled();
    if~glbVars.xcp.hasInstrumentedSignals&&~isXCPProfilingDataTransferEnabled


        MSLDiagnostic('coder_xcp:host:NoSignalsUploaded',glbVars.glbModel).reportAsWarning;
    end
end


function[glbVars,status]=i_UserSetParam(glbVars,params)












    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_SETPARAM');

    glbVars.xcp.params=params;


    glbVars.xcp.target.setParams(params);
end


function[glbVars,status,params]=i_UserGetParam(glbVars)









    status=0;
    locPrintDebugInfo(glbVars,'action: EXT_GETPARAM');


    params=glbVars.xcp.target.getParams(glbVars.glbTunableParams);
end


function[glbVars,status]=i_UserSignalSelect(glbVars)



























































    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_SELECT_SIGNALS (Wired)');

    if glbVars.xcp.hasInstrumentedSignals
        glbVars=locInitializeFromSDIRepository(glbVars,false);
    end
end


function[glbVars,status]=i_UserSignalSelectFloating(glbVars)





    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_SELECT_SIGNALS (Floating)');

    if glbVars.xcp.hasInstrumentedSignals
        glbVars=locInitializeFromSDIRepository(glbVars,true);
    end
end


function[glbVars,status]=i_UserTriggerSelect(glbVars)






































































    status=0;

end


function[glbVars,status]=i_UserTriggerSelectFloating(glbVars)






    status=0;

end


function[glbVars,status]=i_UserTriggerArm(glbVars)




    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_ARM_TRIGGER');


    glbVars.xcp.target.classicTriggerConfiguration(glbVars.glbUpInfoWired.trigger);






    fromRemoteTarget=true;
    startTime=glbVars.xcp.target.getModelTime(fromRemoteTarget);
    glbVars.xcp.target.setModelStartTime(startTime);


    glbVars.xcp.classicTriggerStatus=coder.internal.xcp.ClassicTriggerStatus.ARMED;
    glbVars.xcp.target.classicTriggerArm();

end


function[glbVars,status]=i_UserTriggerArmFloating(glbVars)




    status=0;

end


function[glbVars,status]=i_UserCancelLogging(glbVars)




    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_CANCEL_LOGGING (Wired)');


    glbVars.xcp.target.classicTriggerCancel();

end


function[glbVars,status]=i_UserCancelLoggingFloating(glbVars)




    status=0;

end


function[glbVars,status]=i_UserStart(glbVars)



    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_MODEL_START');

    if glbVars.xcp.modelStatus==coder.internal.xcp.TargetStatus.WAITING_TO_START||...
        glbVars.xcp.modelStatus==coder.internal.xcp.TargetStatus.INITIALIZED
        locPrintDebugInfo(glbVars,'Starting model execution on the target...');

        glbVars.xcp.target.modelStart();
    end
end


function[glbVars,status]=i_UserStop(glbVars)


    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_MODEL_STOP');

    if(glbVars.xcp.modelStatus~=coder.internal.xcp.TargetStatus.RESETTING)

        glbVars.xcp.target.modelStop();
    end
end


function[glbVars,status]=i_UserPause(glbVars)



    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_MODEL_PAUSE');
end


function[glbVars,status]=i_UserStep(glbVars)




    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_MODEL_STEP');
end


function[glbVars,status]=i_UserContinue(glbVars)



    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_MODEL_CONTINUE');
end


function[glbVars,time]=i_UserGetTime(glbVars)






    if~glbVars.xcp.intCodeOnly

        time=glbVars.xcp.ExecutionTime;
    else


        time=glbVars.xcp.ExecutionTime/glbVars.xcp.BaseRatePeriod;
    end
end


function[glbVars,status]=i_UserDisconnect(glbVars)




    status=0;

    locPrintDebugInfo(glbVars,'action: EXT_DISCONNECT_REQUEST');



    glbVars.xcp.target.checkError();


    glbVars.xcp.target.setModelStopTime(glbVars.xcp.ExecutionTime);


    locPrintDebugInfo(glbVars,'Disabling XCP Synchronous Data Transfer...');
    glbVars.xcp.target.disableSyncDataTransfer();


    locPrintDebugInfo(glbVars,'Disconnecting from the target...');
    glbVars.xcp.target.resetConnection();


    glbVars=locResetStatus(glbVars);
end


function glbVars=i_UserDisconnectImmediate(glbVars)

    locPrintDebugInfo(glbVars,'action: EXT_DISCONNECT_REQUEST_NO_FINAL_UPLOAD');









    resetTarget(glbVars,glbVars.xcp.target);
end


function glbVars=i_UserDisconnectConfirmed(glbVars)





    locPrintDebugInfo(glbVars,'action: EXT_DISCONNECT_CONFIRMED');

    if isvalid(glbVars.xcp.target)

        glbVars.xcp.target.setModelStopTime(glbVars.xcp.ExecutionTime);

        try



            if glbVars.xcp.target.isXCPSyncDataTransferEnabled()

                glbVars.xcp.target.disableSyncDataTransfer();
            end
        catch ME

            locResetStatus(glbVars);
            rethrow(ME);
        end


        glbVars=locResetStatus(glbVars);
    end
end


function[glbVars,status]=i_UserTargetStopped(glbVars)














    if~isvalid(glbVars.xcp.target)



        status=true;
        return;
    end

    try

        glbVars.xcp.target.checkError();









        requestTime=glbVars.xcp.hasInstrumentedSignals;
        timeReadFromRemoteTarget=~glbVars.xcp.hasInstrumentedSignals;
        requestModelStatus=false;

        if glbVars.xcp.targetPollingTimer==0

            glbVars.xcp.targetPollingTimer=tic;
        end

        if toc(glbVars.xcp.targetPollingTimer)>glbVars.xcp.targetPollingTime
            requestTime=true;


            if(glbVars.xcp.ExecutionTime==glbVars.xcp.LastExecutionTime)

                requestModelStatus=true;
            end

            glbVars.xcp.LastExecutionTime=glbVars.xcp.ExecutionTime;
            glbVars.xcp.targetPollingTimer=tic;
        end

        if requestModelStatus

            glbVars.xcp.modelStatus=glbVars.xcp.target.getModelStatus();
            triggerStatus=glbVars.xcp.target.getClassicTriggerStatus();

            if(glbVars.xcp.modelStatus==coder.internal.xcp.TargetStatus.RUNNING&&...
                triggerStatus==coder.internal.xcp.ClassicTriggerStatus.UNARMED&&...
                glbVars.xcp.classicTriggerStatus~=coder.internal.xcp.ClassicTriggerStatus.UNARMED)

                set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',glbVars.glbUpInfoWired.index);
                glbVars.glbUpInfoWired.trigger_armed=0;
                glbVars.xcp.classicTriggerStatus=triggerStatus;
            end


            if glbVars.xcp.modelStatus==coder.internal.xcp.TargetStatus.RESETTING

                glbVars.xcp.target.classicTriggerCancel();
                set_param(glbVars.glbModel,'ExtModeOpenProtocolShutdown',0);
            else


                timeReadFromRemoteTarget=true;
            end
        end

        if requestTime
            currentTime=glbVars.xcp.target.getModelTime(timeReadFromRemoteTarget);

            if timeReadFromRemoteTarget||...
                (currentTime>=glbVars.xcp.ExecutionTime)







                glbVars.xcp.ExecutionTime=currentTime;
            end
        end


        status=(glbVars.xcp.modelStatus==coder.internal.xcp.TargetStatus.RESETTING)||...
        (glbVars.xcp.modelStatus==coder.internal.xcp.TargetStatus.RESET);

    catch originalException
        disconnectExceptionDetected=false;
        try

            resetTarget(glbVars,glbVars.xcp.target);
        catch ResetME


            disconnectException=MSLException([],'coder_xcp:host:DisconnectFromTargetApplicationError',...
            DAStudio.message('coder_xcp:host:DisconnectFromTargetApplicationError'));
            disconnectException=addCause(disconnectException,ResetME);
            multipleErrorsException=MException('MATLAB:MException:MultipleErrors',...
            DAStudio.message('coder_xcp:host:MultipleErrors'));
            multipleErrorsException=addCause(multipleErrorsException,originalException);
            multipleErrorsException=addCause(multipleErrorsException,disconnectException);

            disconnectExceptionDetected=true;
        end




        glbVars=locResetStatus(glbVars);


        set_param(glbVars.glbModel,'ExtModeOpenProtocolShutdown',0);

        if disconnectExceptionDetected
            throw(multipleErrorsException);
        else
            rethrow(originalException);
        end
    end
end


function glbVars=i_UserFinalUpload(glbVars)




    locPrintDebugInfo(glbVars,'action: EXT_FINAL_UPLOAD');


    isFinalUpload=true;


    finalUploadComplete=false;
    while~finalUploadComplete
        blockExecuted=false;



        if~isempty(glbVars.glbUpInfoWired)&&glbVars.glbUpInfoWired.trigger_armed
            [glbVars,wiredBlockExecuted]=locUserCheckData(glbVars,...
            glbVars.glbUpInfoWired,...
            isFinalUpload);
            if wiredBlockExecuted
                blockExecuted=true;
            end
            glbVars=feval(glbVars.utilsFile.i_SendTerminate,glbVars,glbVars.glbUpInfoWired.index);
        end



        if~isempty(glbVars.glbUpInfoFloating)&&glbVars.glbUpInfoFloating.trigger_armed
            [glbVars,floatingBlockExecuted]=locUserCheckData(glbVars,...
            glbVars.glbUpInfoFloating,...
            isFinalUpload);
            if floatingBlockExecuted
                blockExecuted=true;
            end
            glbVars=feval(glbVars.utilsFile.i_SendTerminate,glbVars,glbVars.glbUpInfoFloating.index);
        end

        if~blockExecuted
            finalUploadComplete=true;
        end
    end
end


function glbVars=i_UserCheckData(glbVars,upInfo)































    isFinalUpload=false;
    glbVars=locUserCheckData(glbVars,upInfo,isFinalUpload);
end











function glbVars=locInitializeFromSDIRepository(glbVars,isFloating)
    if isFloating
        upInfo=glbVars.glbUpInfoFloating;
        locPrintDebugInfo(glbVars,'Searching floating signals in Simulink Data Repository...');
    else
        upInfo=glbVars.glbUpInfoWired;
        locPrintDebugInfo(glbVars,'Searching wired signals in Simulink Data Repository...');
    end

    if~isempty(upInfo)&&~isempty(upInfo.upBlks)
        lastRun=Simulink.sdi.Run.getLatest;
        sigIdMap=coder.internal.xcp.BlockPathToSignalMap(lastRun);
        for nUpBlk=1:length(upInfo.upBlks)



            if~glbVars.xcp.timestampBasedOnSimulationTime
                MSLDiagnostic('coder_xcp:host:UploadNotSupportedWhenRealTimestampIsEnabled',upInfo.upBlks{nUpBlk}.Name).reportAsWarning;
                continue;
            end


            busBlockPath='';
            busPortIndex=0;
            currentBusSigIndex=0;


            upInfo.upBlks{nUpBlk}.XCPStartTime=glbVars.xcp.ExecutionTime;
            upInfo.upBlks{nUpBlk}.XCPPrevCommonSDIEndTime=[];
            upInfo.upBlks{nUpBlk}.XCPMissingSDISignalStartTime=[];

            for nUpBlkSrcSig=1:length(upInfo.upBlks{nUpBlk}.SrcSignals)
                srcSigBlockPath=upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.GrBlockPath;
                srcSigPortIndex=upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.GrPortIndex;

                locPrintDebugInfo(glbVars,sprintf('%s, port index %d',locRemoveNewLines(srcSigBlockPath),srcSigPortIndex));

                try

                    blockType=get_param(srcSigBlockPath,'BlockType');

                    isSFunctionInsideStateflowChart=(strcmp(blockType,'S-Function'))&&...
                    slprivate('is_stateflow_based_block',...
                    get_param(srcSigBlockPath,'Parent'));
                catch ME
                    if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')


                        isSFunctionInsideStateflowChart=false;
                    else
                        rethrow(ME);
                    end
                end

                if isSFunctionInsideStateflowChart



                    srcSigBlockPath=upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.BlockPath;
                    srcSigPortIndex=srcSigPortIndex-1;
                end

                srcSigId=sigIdMap.getSigIDFromBlockPathAndPortIndex(locRemoveNewLines(srcSigBlockPath),srcSigPortIndex);



                newBusDetected=~strcmp(busBlockPath,srcSigBlockPath)||...
                (busPortIndex~=srcSigPortIndex);

                if newBusDetected
                    busBlockPath=srcSigBlockPath;
                    busPortIndex=srcSigPortIndex;
                    currentBusSigIndex=1;
                end

                if~isempty(srcSigId)




                    srcSigId=locFindLeafSigId(currentBusSigIndex,1,srcSigId);
                end

                if isempty(srcSigId)
                    blockLink=locCreateHyperLink(upInfo.upBlks{nUpBlk}.Name);
                    sigBlockPathLink=locCreateHyperLink(srcSigBlockPath);

                    MSLDiagnostic('coder_xcp:host:InputSignalNotUploaded',blockLink,sigBlockPathLink).reportAsWarning;
                    continue;
                end

                currentBusSigIndex=currentBusSigIndex+1;

                if locSignalSizeMismatchDetected(upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig})
                    blockLink=locCreateHyperLink(upInfo.upBlks{nUpBlk}.Name);
                    sigBlockPathLink=locCreateHyperLink(srcSigBlockPath);

                    MSLDiagnostic('coder_xcp:host:SignalSizeMismatch',blockLink,sigBlockPathLink).reportAsWarning;
                    continue;
                end





                isLimitDataPointsAndDecimationSettingValid=locValidateLimitDataPointsAndDecimation(...
                upInfo.upBlks{nUpBlk}.Name,...
                srcSigBlockPath,...
                srcSigPortIndex);
                if~isLimitDataPointsAndDecimationSettingValid

                    continue;
                end

                if~isprop(upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig},'XCPSigId')
                    upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.addprop('XCPSigId');
                end
                upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.XCPSigId=srcSigId;


                if~isprop(upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig},'XCPLastValue')
                    upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.addprop('XCPLastValue');
                end
                upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.XCPLastValue=...
                locGetSigDefaultValue(srcSigId);
            end


            busBlockPath='';
            busPortIndex=0;
            currentBusSigIndex=0;

            for nUpBlkSrcSig=1:length(upInfo.upBlks{nUpBlk}.SrcMRSignals)
                blockPaths=upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.BlockPath.convertToCell;
                srcSigBlockPath=blockPaths{1};
                for i=2:length(blockPaths)
                    startIdx=strfind(blockPaths{i},'/')+1;
                    srcSigBlockPath=[srcSigBlockPath,'/',blockPaths{i}(startIdx:end)];%#ok
                end
                srcSigPortIndex=upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.PortIndex;

                srcSigBlockPathNoNewLines=locRemoveNewLines(srcSigBlockPath);
                locPrintDebugInfo(glbVars,sprintf('%s, port index %d',srcSigBlockPathNoNewLines,srcSigPortIndex));
                srcSigId=sigIdMap.getSigIDFromBlockPathAndPortIndex(srcSigBlockPathNoNewLines,srcSigPortIndex);



                newBusDetected=~strcmp(busBlockPath,srcSigBlockPath)||...
                (busPortIndex~=srcSigPortIndex);

                if newBusDetected
                    busBlockPath=srcSigBlockPath;
                    busPortIndex=srcSigPortIndex;
                    currentBusSigIndex=1;
                end

                if~isempty(srcSigId)




                    srcSigId=locFindLeafSigId(currentBusSigIndex,1,srcSigId);
                end

                if isempty(srcSigId)
                    blockLink=locCreateHyperLink(upInfo.upBlks{nUpBlk}.Name);
                    sigBlockPathLink=locCreateHyperLink(srcSigBlockPath);

                    MSLDiagnostic('coder_xcp:host:InputSignalNotUploaded',blockLink,sigBlockPathLink).reportAsWarning;
                    continue;
                end

                currentBusSigIndex=currentBusSigIndex+1;





                srcSigModelRefLevel=upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.BlockPath.getLength;
                srcSigBlockPathInRefModel=upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.BlockPath.getBlock(srcSigModelRefLevel);
                isLimitDataPointsAndDecimationSettingValid=locValidateLimitDataPointsAndDecimation(...
                upInfo.upBlks{nUpBlk}.Name,...
                srcSigBlockPathInRefModel,...
                srcSigPortIndex);
                if~isLimitDataPointsAndDecimationSettingValid

                    continue;
                end

                if~isprop(upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig},'XCPSigId')
                    upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.addprop('XCPSigId');
                end
                upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.XCPSigId=srcSigId;


                if~isprop(upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig},'XCPLastValue')
                    upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.addprop('XCPLastValue');
                end
                upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcSig}.XCPLastValue=...
                locGetSigDefaultValue(srcSigId);
            end


            for nUpBlkSrcSig=1:length(upInfo.upBlks{nUpBlk}.SrcDWorks)
                srcBlockPath=upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig}.BlockPath;
                srcDWorkName=upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig}.DWorkName;

                srcBlockPathNoNewLines=locRemoveNewLines(srcBlockPath);
                locPrintDebugInfo(glbVars,sprintf('%s, DWork name %s',srcBlockPathNoNewLines,srcDWorkName));
                srcSigId=sigIdMap.getSigIDFromBlockPathAndName(srcBlockPathNoNewLines,srcDWorkName);

                if isempty(srcSigId)
                    blockLink=locCreateHyperLink(upInfo.upBlks{nUpBlk}.Name);
                    sigBlockPathLink=locCreateHyperLink(srcBlockPath);

                    MSLDiagnostic('coder_xcp:host:InputSignalNotUploaded',blockLink,sigBlockPathLink).reportAsWarning;
                    continue;
                end

                if~isprop(upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig},'XCPSigId')
                    upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig}.addprop('XCPSigId');
                end
                upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig}.XCPSigId=srcSigId;


                if~isprop(upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig},'XCPLastValue')
                    upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig}.addprop('XCPLastValue');
                end
                upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcSig}.XCPLastValue=...
                locGetSigDefaultValue(srcSigId);
            end
        end
    end

    if isFloating
        glbVars.glbUpInfoFloating=upInfo;
    else
        glbVars.glbUpInfoWired=upInfo;
    end
end

function defaultValue=locGetSigDefaultValue(srcSigId)



    srcSig=Simulink.sdi.getSignal(srcSigId);
    if isscalar(srcSig.Dimensions)
        dims=[1,srcSig.Dimensions];
    else
        dims=srcSig.Dimensions;
    end

    data=srcSig.DataValues.Data;
    if isenum(data)


        dataType=srcSig.DataType;

        enumMetaData=meta.class.fromName(dataType);

        defaultValueMethod='getDefaultValue';
        if any(strcmp({enumMetaData.MethodList.Name},defaultValueMethod))

            defaultEnumValue=eval([dataType,'.',defaultValueMethod]);
        else

            defaultMember=enumMetaData.EnumerationMemberList(1).Name;
            defaultEnumValue=eval([dataType,'.',defaultMember]);
        end
        defaultValue=repmat(defaultEnumValue,dims);
    elseif isstring(data)

        defaultValue=string;
    else


        defaultValue=...
        zeros(dims,'like',data);
    end
end

function[glbVars,blockExecuted]=locUserCheckData(glbVars,...
    upInfo,...
    isFinalUpload)






    startTime=tic;

    blockExecuted=false;

    try
        if glbVars.xcp.hasInstrumentedSignals


            isWired=(~isempty(glbVars.glbUpInfoWired)&&...
            upInfo.index==glbVars.glbUpInfoWired.index);
            isFloating=(~isempty(glbVars.glbUpInfoFloating)&&...
            upInfo.index==glbVars.glbUpInfoFloating.index);

            if isWired||isFloating
                if upInfo.trigger_armed
                    for nUpBlk=1:length(upInfo.upBlks)
                        upBlk=upInfo.upBlks{nUpBlk};

                        if upBlk.LogEventCompleted
                            continue
                        end

                        if isempty(upBlk.SrcSignals)&&...
                            isempty(upBlk.SrcMRSignals)&&...
                            isempty(upBlk.SrcDWorks)
                            glbVars=feval(glbVars.utilsFile.i_BlockLogEventCompleted,glbVars,upInfo.index,nUpBlk);
                            continue
                        end

                        Simulink.HMI.AsyncQueueObserverAPI.sdiSynchronouslyFlushAllQueuesInThisModel(glbVars.glbModel);


                        [glbVars,...
                        executionNeeded,...
                        upBlk]=locUploadBlockSignals(glbVars,...
                        upBlk,...
                        nUpBlk,...
                        upInfo.trigger,...
                        upInfo.index,...
                        isFinalUpload);

                        if isWired
                            glbVars.glbUpInfoWired.upBlks{nUpBlk}=upBlk;
                        elseif isFloating
                            glbVars.glbUpInfoFloating.upBlks{nUpBlk}=upBlk;
                        end

                        if executionNeeded

                            glbVars=feval(glbVars.utilsFile.i_SendBlockExecute,glbVars,upInfo.index,nUpBlk);
                            blockExecuted=true;
                        end
                    end
                end
            else
                DAStudio.error('Simulink:tools:extModeOpenSLRTInvalidUpInfoType');
            end
        end
    catch originalException
        disconnectExceptionDetected=false;
        try

            resetTarget(glbVars,glbVars.xcp.target);
        catch ResetME


            disconnectException=MSLException([],'coder_xcp:host:DisconnectFromTargetApplicationError',...
            DAStudio.message('coder_xcp:host:DisconnectFromTargetApplicationError'));
            disconnectException=addCause(disconnectException,ResetME);
            multipleErrorsException=MException('MATLAB:MException:MultipleErrors',...
            DAStudio.message('coder_xcp:host:MultipleErrors'));
            multipleErrorsException=addCause(multipleErrorsException,originalException);
            multipleErrorsException=addCause(multipleErrorsException,disconnectException);

            disconnectExceptionDetected=true;
        end


        glbVars=locResetStatus(glbVars);



        set_param(glbVars.glbModel,'ExtModeOpenProtocolShutdown',0);

        if disconnectExceptionDetected
            throw(multipleErrorsException);
        else
            rethrow(originalException);
        end
    end

    overallTime=toc(startTime);



    if~isFinalUpload&&blockExecuted
        glbVars.xcp.MaxNumPointsPerSignal=locCheckForNewNumPointsPerSignal(overallTime,...
        glbVars.xcp.MaxNumPointsPerSignal,...
        upInfo.trigger.Duration);
    end
end

function newNumPointsPerSignal=...
    locCheckForNewNumPointsPerSignal(overallTime,...
    currentNumPointsPerSignal,...
    upperLimit)








    newNumPointsPerSignal=currentNumPointsPerSignal;
    tooMuchTime=2;
    tooLittleTime=0.5;
    if overallTime>tooMuchTime
        lessWorkDivisor=2;
        minNumPoints=min(10,upperLimit);
        newNumPointsPerSignal=max(round(currentNumPointsPerSignal/lessWorkDivisor),...
        minNumPoints);
    elseif overallTime<tooLittleTime
        extraWorkFactor=2;
        newNumPointsPerSignal=min(currentNumPointsPerSignal*extraWorkFactor,...
        upperLimit);
    end
end


function glbVars=locResetGlobals(glbVars)


    glbVars.xcp.timestampBasedOnSimulationTime=true;
    glbVars.xcp.verbosityLevel=0;

    glbVars.xcp.checksum1=0;
    glbVars.xcp.checksum2=0;
    glbVars.xcp.checksum3=0;
    glbVars.xcp.checksum4=0;

    glbVars.xcp.modelStatus=coder.internal.xcp.TargetStatus.RESET;
    glbVars.xcp.hasInstrumentedSignals=false;
    glbVars.xcp.targetPollingTimer=0;
    glbVars.xcp.targetPollingTime=0;
    glbVars.xcp.ExecutionTime=0;
    glbVars.xcp.LastExecutionTime=0;
    glbVars.xcp.intCodeOnly=0;
    glbVars.xcp.BaseRatePeriod=0;
    glbVars.xcp.params=[];








    glbVars.xcp.MaxNumPointsPerSignal=10;

end


function[glbVars,...
    executeBlock,...
    upBlk]=locUploadBlockSignals(glbVars,...
    upBlk,...
    nUpBlk,...
    trigger,...
    upInfoIndex,...
    isFinalUpload)
    executeBlock=false;


    if isFinalUpload

        glbVars.xcp.MaxNumPointsPerSignal=trigger.Duration;
    end



    upBlkSignals=[upBlk.SrcSignals,upBlk.SrcMRSignals,upBlk.SrcDWorks];
    mrOffset=length(upBlk.SrcSignals);
    dwOffset=length(upBlk.SrcSignals)+length(upBlk.SrcMRSignals);

    if isempty(upBlkSignals)||(isFinalUpload&&~isempty(upBlk.SrcDWorks))




        return;
    end

    numPoints=glbVars.xcp.MaxNumPointsPerSignal;
    assert(numPoints<=trigger.Duration,'numPoints must not exceed ExtMode duration!');

    baseRate=trigger.BaseRate;
    maxTimeSpan=baseRate*(numPoints-1);























    maxSDISignalRefreshTime=0.3;



    commonSDIEndTime=inf;
    maxSDIEndTime=0;

    minSDIStartTime=inf;

    maxSampleTime=0;
    allSignalsAvailable=true;
    anySignalAvailable=false;

    blockSigData=cell(1,length(upBlkSignals));

    for nSrcSig=1:length(upBlkSignals)
        if~isprop(upBlkSignals{nSrcSig},'XCPSigId')
            continue;
        end

        srcSigId=upBlkSignals{nSrcSig}.XCPSigId;


        sig=Simulink.sdi.getSignal(srcSigId);



        if sig.NumPoints==0
            allSignalsAvailable=false;
            continue;
        end

        if isempty(sig.SampleTime)







            sigSampleTime=baseRate;
        else
            sigSampleTime=str2double(sig.SampleTime);
            if isnan(sigSampleTime)


                sigSampleTime=baseRate;
            end
        end
        maxSampleTime=max(maxSampleTime,sigSampleTime);


        sigData=coder.internal.xcp.exportSDISignal(sig,...
        upBlk.XCPStartTime,...
        inf,...
        nSrcSig);
        blockSigData{nSrcSig}=sigData;

        if~isempty(sigData)&&~isempty(sigData.Time)

            sigEndTime=sigData.Time(end);
            commonSDIEndTime=min(commonSDIEndTime,sigEndTime);
            maxSDIEndTime=max(maxSDIEndTime,sigEndTime);
            minSDIStartTime=min(minSDIStartTime,sigData.Time(1));

            anySignalAvailable=true;
        else

            allSignalsAvailable=false;
        end
    end

    if~anySignalAvailable

        return;
    end

    if isempty(upBlk.XCPPrevCommonSDIEndTime)

        upBlk.XCPPrevCommonSDIEndTime=commonSDIEndTime;
    end

    if isFinalUpload

        sdiEndTime=maxSDIEndTime;
    elseif allSignalsAvailable

        sdiEndTime=commonSDIEndTime;
        upBlk.XCPMissingSDISignalStartTime=[];
    else





        if(maxSDIEndTime-upBlk.XCPPrevCommonSDIEndTime)<(2*maxSampleTime)


            return;
        else
            if isempty(upBlk.XCPMissingSDISignalStartTime)

                upBlk.XCPMissingSDISignalStartTime=tic;
            end

            if toc(upBlk.XCPMissingSDISignalStartTime)<=maxSDISignalRefreshTime


                return;
            end
        end


        sdiEndTime=upBlk.XCPPrevCommonSDIEndTime;
        upBlk.XCPMissingSDISignalStartTime=[];
    end




    endTime=min(minSDIStartTime+maxTimeSpan,sdiEndTime);
    assert(endTime>=upBlk.XCPStartTime,...
    'endTime (%f) must not be smaller than startTime (%f)',...
    endTime,upBlk.XCPStartTime);







    maxFinalEndTime=0;
    for nSrcSig=1:length(upBlkSignals)
        if~isprop(upBlkSignals{nSrcSig},'XCPSigId')
            continue;
        end

        sigData=blockSigData{nSrcSig};


        sigDataAvailable=false;
        if~isempty(sigData)&&~isempty(sigData.Time)



            sigData=getsampleusingtime(sigData,0,endTime);
            if~isempty(sigData)&&~isempty(sigData.Time)

                executeBlock=true;
                sigDataAvailable=true;

                maxFinalEndTime=max(maxFinalEndTime,sigData.Time(end));
            end
        end



        sigData=locInsertPreviousValueInTimeseriesIfNeeded(sigData,...
        sigDataAvailable,...
        minSDIStartTime,...
        upBlkSignals{nSrcSig});

        if isenum(sigData.Data)



            repository=sdi.Repository(true);
            srcSigId=upBlkSignals{nSrcSig}.XCPSigId;
            sdiDataTypeLabel=repository.getSignalDataTypeLabel(srcSigId);
            dataStorageType=Simulink.data.getEnumTypeInfo(sdiDataTypeLabel,'StorageType');

            if strcmp(dataStorageType,'int')


                bitPerIntString=sprintf('%d',get_param(glbVars.glbModel,'ProdBitPerInt'));

                newdataStorageType=[dataStorageType,bitPerIntString];

                dataStorageType=newdataStorageType;
            end


            sigData.Data=feval(dataStorageType,sigData.Data);
        end


        if isa(upBlkSignals{nSrcSig},'Simulink.ExtMode.SrcMRSignal')
            glbVars=feval(glbVars.utilsFile.i_WriteSourceMRSignal,glbVars,upInfoIndex,nUpBlk,nSrcSig-mrOffset,sigData.Time,sigData.Data);
        elseif isa(upBlkSignals{nSrcSig},'Simulink.ExtMode.SrcDWork')
            glbVars=feval(glbVars.utilsFile.i_WriteSourceDWork,glbVars,upInfoIndex,nUpBlk,nSrcSig-dwOffset,sigData.Time,sigData.Data);
        else
            glbVars=feval(glbVars.utilsFile.i_WriteSourceSignal,glbVars,upInfoIndex,nUpBlk,nSrcSig,sigData.Time,sigData.Data);
        end
    end


    if executeBlock










        maxFinalEndTime=maxFinalEndTime+eps(maxFinalEndTime);


        upBlk.XCPStartTime=maxFinalEndTime+eps(maxFinalEndTime);
    else


        upBlk.XCPStartTime=endTime;
    end
    upBlk.XCPPrevCommonSDIEndTime=[];
end

function sigData=locInsertPreviousValueInTimeseriesIfNeeded(sigData,...
    sigDataAvailable,...
    minSDIStartTime,...
    upBlkSignal)



    if sigDataAvailable


        if sigData.Time(1)>minSDIStartTime
            if isfi(sigData.Data)



                numericType=upBlkSignal.XCPLastValue.numerictype;
                tmpSigData=timeseries(int(sigData.Data),sigData.Time);

                tmpSigData=tmpSigData.addsample('Data',...
                int(upBlkSignal.XCPLastValue),...
                'Time',...
                minSDIStartTime);

                sigData=timeseries(fi(zeros(size(tmpSigData.Data)),numericType),...
                tmpSigData.Time);

                sigData.Data.int=tmpSigData.Data;
            else

                sigData=sigData.addsample('Data',...
                upBlkSignal.XCPLastValue,...
                'Time',...
                minSDIStartTime);
            end
        end

        upBlkSignal.XCPLastValue=sigData.getdatasamples(length(sigData.Time));
    else





        sigData=timeseries(upBlkSignal.XCPLastValue,minSDIStartTime);
    end
end

function sizeMismatchDetected=locSignalSizeMismatchDetected(srcSignal)






    sizeMismatchDetected=true;

    actualPortWidths=get_param(srcSignal.ActSrcHandle,'CompiledPortWidths');
    graphicalPortWidths=get_param(srcSignal.GrBlockPath,'CompiledPortWidths');

    if~isempty(actualPortWidths)&&~isempty(graphicalPortWidths)&&...
        (srcSignal.PortIndex<=length(actualPortWidths.Outport))&&...
        (srcSignal.GrPortIndex<=length(graphicalPortWidths.Outport))

        sizeMismatchDetected=actualPortWidths.Outport(srcSignal.PortIndex)>...
        graphicalPortWidths.Outport(srcSignal.GrPortIndex);
    end
end

function hSrcSigLine=locGetSrcSigLineHandle(srcSigBlockPath,srcSigPortIndex)

    hSrcSigBlock=get_param(srcSigBlockPath,'LineHandles');
    hSrcSigLine=hSrcSigBlock.Outport(srcSigPortIndex);
end

function ret=locIsScope(upBlkName)

    upBlkType=get_param(upBlkName,'BlockType');
    ret=strcmp(upBlkType,'Scope');
end


function ret=locIsToWorkspace(upBlkName)
    upBlkType=get_param(upBlkName,'BlockType');
    ret=strcmp(upBlkType,'ToWorkspace');
end

function decimationEnabled=locIsDecimationEnabled(h)

    decimateData=get(h,'DataLoggingDecimateData');
    decimationValue=str2double(get(h,'DataLoggingDecimation'));


    decimationEnabled=decimateData&&decimationValue~=1;
end

function limitDataPointsEnabled=locIsLimitDataPointsEnabled(h)

    limitDataPointsEnabled=get(h,'DataLoggingLimitDataPoints');
end

function isValid=locValidateLimitDataPointsAndDecimation(upBlkName,srcSigBlockPath,srcSigPortIndex)






    isValid=true;

    if~locIsScope(upBlkName)&&~locIsToWorkspace(upBlkName)



        return;
    end

    hSrcSigLine=locGetSrcSigLineHandle(srcSigBlockPath,srcSigPortIndex);






    if~get(hSrcSigLine,'DataLogging')

        if locIsDecimationEnabled(hSrcSigLine)||locIsLimitDataPointsEnabled(hSrcSigLine)
            blockLink=locCreateHyperLink(upBlkName);
            sigBlockPathLink=locCreateHyperLink(srcSigBlockPath);
            MSLDiagnostic('coder_xcp:host:SignalImplicitlyLoggedDecimationMaxPointsDisabled',...
            blockLink,...
            sigBlockPathLink,...
            srcSigPortIndex).reportAsWarning;
        end
        return;
    end












    if locIsDecimationEnabled(hSrcSigLine)
        blockLink=locCreateHyperLink(upBlkName);
        sigBlockPathLink=locCreateHyperLink(srcSigBlockPath);
        MSLDiagnostic('coder_xcp:host:LoggedSignalNotSupportedForUploadBlock',...
        blockLink,...
        DAStudio.message('Simulink:dialog:SigpropLblDecimationName'),...
        get_param(upBlkName,'BlockType'),...
        srcSigPortIndex,...
        sigBlockPathLink,...
        srcSigBlockPath,...
'disableDecimationOnSignal'...
        ).reportAsWarning;

        isValid=false;


    end
















    if locIsLimitDataPointsEnabled(hSrcSigLine)
        blockLink=locCreateHyperLink(upBlkName);
        sigBlockPathLink=locCreateHyperLink(srcSigBlockPath);
        MSLDiagnostic('coder_xcp:host:LoggedSignalNotSupportedForUploadBlock',...
        blockLink,...
        DAStudio.message('Simulink:dialog:SigpropLblDataPointsName'),...
        get_param(upBlkName,'BlockType'),...
        srcSigPortIndex,...
        sigBlockPathLink,...
        srcSigBlockPath,...
'disableLimitDataPointsOnSignal'...
        ).reportAsWarning;
        isValid=false;
    end
end

function resetTarget(glbVars,xcpTargetHandler)

    if isvalid(xcpTargetHandler)
        if xcpTargetHandler.isXCPSyncDataTransferEnabled()

            glbVars.xcp.target.setModelStopTime(glbVars.xcp.ExecutionTime);


            xcpTargetHandler.disableSyncDataTransfer();
        end

        if xcpTargetHandler.isXCPConnected()
            xcpTargetHandler.resetConnection();
        end
    end
end

function glbVars=locResetStatus(glbVars)

    glbVars.xcp.extModeMexArgs=[];
    glbVars.xcp.buildDir='';
    if isvalid(glbVars.xcp.target)

        glbVars.xcp.target.setModelStopTime(glbVars.xcp.ExecutionTime);
        delete(glbVars.xcp.target);
    end

    glbVars=locResetGlobals(glbVars);

end

function target=locCreateXCPTargetHandler(buildDirectory,extModeMexArgs)


    transport=extModeMexArgs.transport;


    assert(strcmp(transport,Simulink.ExtMode.Transports.XCPTCP.Transport)||...
    strcmp(transport,Simulink.ExtMode.Transports.XCPSerial.Transport)||...
    strcmp(transport,Simulink.ExtMode.Transports.XCPCAN.Transport));

    if strcmp(transport,Simulink.ExtMode.Transports.XCPTCP.Transport)

        target=coder.internal.xcp.XCPTCPTargetHandler(...
        buildDirectory,...
        extModeMexArgs.targetName,...
        extModeMexArgs.targetPort,...
        extModeMexArgs.symbolsFileName);
    elseif strcmp(transport,Simulink.ExtMode.Transports.XCPSerial.Transport)

        target=coder.internal.xcp.XCPSerialTargetHandler(...
        buildDirectory,...
        extModeMexArgs.portName,...
        extModeMexArgs.baudRate,...
        extModeMexArgs.symbolsFileName,...
        extModeMexArgs.flowControlType,...
        extModeMexArgs.openDelayInMs);
    else

        target=coder.internal.xcp.XCPCANTargetHandler(...
        buildDirectory,...
        extModeMexArgs.canVendor,...
        extModeMexArgs.canDevice,...
        extModeMexArgs.canChannel,...
        extModeMexArgs.baudRate,...
        extModeMexArgs.canIDEBitCommand,...
        extModeMexArgs.canIDCommand,...
        extModeMexArgs.canIDEBitResponse,...
        extModeMexArgs.canIDResponse,...
        extModeMexArgs.symbolsFileName);
    end
end

function link=locCreateHyperLink(elementName)


    elementText=['hilite_system(''',regexprep(elementName,'[\n\r]+',' '),''');'];
    link=targets_hyperlink_manager...
    ('new',...
    elementName,...
    elementText);
end

function outString=locRemoveNewLines(inString)
    outString=regexprep(inString,'[\n\r]+',' ');
end

function[srcSigId,busSigNumber]=locFindLeafSigId(absoluteBusSigIndex,baseBusSigIndex,baseBusSigId)



    assert(absoluteBusSigIndex>=baseBusSigIndex,'Invalid absoluteBusSigIndex');

    repository=sdi.Repository(true);

    sigChildren=repository.getSignalChildren(baseBusSigId);
    sig=Simulink.sdi.getSignal(baseBusSigId);

    isTimeSeries=~isempty(sig.DataType);
    if isempty(sigChildren)||isTimeSeries
        if isTimeSeries&&(absoluteBusSigIndex==baseBusSigIndex)
            srcSigId=baseBusSigId;
        else
            srcSigId=[];
        end
        busSigNumber=1;
        return;
    end

    srcSigId=[];
    busSigNumber=0;
    busSigIndex=baseBusSigIndex;

    for i=1:length(sigChildren)
        [sigId,sigNumber]=locFindLeafSigId(absoluteBusSigIndex,busSigIndex,sigChildren(i));
        busSigNumber=busSigNumber+sigNumber;
        busSigIndex=busSigIndex+sigNumber;

        if~isempty(sigId)
            srcSigId=sigId;
            return;
        end
    end
end

function locPrintDebugInfo(glbVars,message)

    if(glbVars.xcp.verbosityLevel>0)
        Simulink.output.info(message);
    end
end


function locPrintTargetHandlerDebugInfo(glbVars)

    if(glbVars.xcp.verbosityLevel>0)
        transport=glbVars.xcp.extModeMexArgs.transport;


        assert(strcmp(transport,Simulink.ExtMode.Transports.XCPTCP.Transport)||...
        strcmp(transport,Simulink.ExtMode.Transports.XCPSerial.Transport)||...
        strcmp(transport,Simulink.ExtMode.Transports.XCPCAN.Transport));

        if strcmp(transport,Simulink.ExtMode.Transports.XCPTCP.Transport)

            Simulink.output.info('Creating Target Handler (XCP on TCP/IP)...');
            Simulink.output.info(sprintf('Build directory: %s',glbVars.xcp.buildDir.BuildDirectory));
            Simulink.output.info(sprintf('Target name: %s',glbVars.xcp.extModeMexArgs.targetName));
            Simulink.output.info(sprintf('Target port: %d',glbVars.xcp.extModeMexArgs.targetPort));
        elseif strcmp(transport,Simulink.ExtMode.Transports.XCPSerial.Transport)

            Simulink.output.info('Creating Target Handler (XCP on Serial)...');
            Simulink.output.info(sprintf('Build directory: %s',glbVars.xcp.buildDir.BuildDirectory));
            Simulink.output.info(sprintf('Serial Port Name: %s',glbVars.xcp.extModeMexArgs.portName));
            Simulink.output.info(sprintf('Baud Rate: %d',glbVars.xcp.extModeMexArgs.baudRate));
        else

            Simulink.output.info('Creating Target Handler (XCP on CAN)...');
            Simulink.output.info(sprintf('Build directory: %s',glbVars.xcp.buildDir.BuildDirectory));
            Simulink.output.info(sprintf('CAN Vendor: %s',glbVars.xcp.extModeMexArgs.canVendor));
            Simulink.output.info(sprintf('CAN Device: %s',glbVars.xcp.extModeMexArgs.canDevice));
            Simulink.output.info(sprintf('CAN Channel: %d',glbVars.xcp.extModeMexArgs.canChannel));
            Simulink.output.info(sprintf('Baud Rate: %d',glbVars.xcp.extModeMexArgs.baudRate));
            Simulink.output.info(sprintf('XCP Command CAN IDE Bit: %d',glbVars.xcp.extModeMexArgs.canIDEBitCommand));
            Simulink.output.info(sprintf('XCP Command CAN ID: %d',glbVars.xcp.extModeMexArgs.canIDCommand));
            Simulink.output.info(sprintf('XCP Response CAN IDE Bit: %d',glbVars.xcp.extModeMexArgs.canIDEBitResponse));
            Simulink.output.info(sprintf('XCP Response CAN ID: %d',glbVars.xcp.extModeMexArgs.canIDResponse));
        end
    end
end

function locPrintModelDebugInfo(glbVars)

    if(glbVars.xcp.verbosityLevel>0)
        Simulink.output.info(sprintf('Model status: %d',glbVars.xcp.modelStatus));
        Simulink.output.info(sprintf('External mode structural checksum received from target: [0x%x, 0x%x, 0x%x, 0x%x].',...
        glbVars.xcp.checksum1,glbVars.xcp.checksum2,glbVars.xcp.checksum3,glbVars.xcp.checksum4));
        Simulink.output.info(sprintf('Target integer only code: %d',glbVars.xcp.intCodeOnly));
    end
end

function targetSimStatus=locConvertTargetStatus(status)


    if status==coder.internal.xcp.TargetStatus.INITIALIZED||...
        status==coder.internal.xcp.TargetStatus.WAITING_TO_START||...
        status==coder.internal.xcp.TargetStatus.READY_TO_RUN
        targetSimStatus=1;
    elseif status==coder.internal.xcp.TargetStatus.PAUSED
        targetSimStatus=4;
    elseif status==coder.internal.xcp.TargetStatus.RESET||...
        status==coder.internal.xcp.TargetStatus.RESETTING
        targetSimStatus=0;
    else
        targetSimStatus=3;
    end
end
