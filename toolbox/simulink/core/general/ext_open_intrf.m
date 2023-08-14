function ext_open_intrf(varargin)




















    mlock;




    persistent models;




    narginchk(1,Inf);





    model=varargin{1};
    args=varargin(2:end);




    if isempty(models)
        models(1).model=model;
        models(1).glbVars=[];
        models(1).messageQueue=[];
        idx=1;
    else
        idx=find(strcmp(model,{models.model})==1);
        if isempty(idx)
            models(end+1)=struct('model',model,'glbVars',[],'messageQueue',[]);
            idx=length(models);
        else
            assert(length(idx)==1);
        end
    end





    if isfield(models(idx).glbVars,'glbCheckDataIsProcessing')&&...
        models(idx).glbVars.glbCheckDataIsProcessing
        models(idx).messageQueue{end+1}=varargin;
        return;
    end





    action=args{1};
    args=args(2:end);









    switch(action)
    case 'Init'
        try
            models(idx).glbVars.glbModel=args{1};
            models(idx).glbVars.intrfFile=feval(args{2});
            models(idx).glbVars.utilsFile=feval(args{3});
            models(idx).glbVars.glbUpInfoWired=[];
            models(idx).glbVars.glbUpInfoFloating=[];
            models(idx).glbVars.restarting=false;
















            models(idx).glbVars.glbCheckDataIsProcessing=Simulink.ExtMode.BooleanHandle;
            models(idx).messageQueue=[];

            models(idx).glbVars=i_UserInit(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'Connect'
        try
            [models(idx).glbVars,status,checksum1,checksum2,checksum3,checksum4,...
            intCodeOnly,tgtStatus]=i_UserConnect(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendConnectResponse(models(idx).glbVars,1,0,0,0,0,0,0);
            return;
        end
        try
            i_SendConnectResponse(models(idx).glbVars,status,checksum1,checksum2,...
            checksum3,checksum4,intCodeOnly,tgtStatus);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'SetParam'
        try
            params=args{1};
            [models(idx).glbVars,status]=i_UserSetParam(models(idx).glbVars,params);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendSetParamResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendSetParamResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'GetParam'
        try
            paramDetails=args{1};
            [models(idx).glbVars,status,paramDetailsFilled]=i_UserGetParam(models(idx).glbVars,paramDetails);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);

            i_SendGetParamResponse(models(idx).glbVars,1,[]);
            return;
        end
        try
            i_SendGetParamResponse(models(idx).glbVars,status,paramDetailsFilled);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'SignalSelect'
        try
            models(idx).glbVars.glbUpInfoWired.upBlks=i_ParseUpBlks(args{1});
            models(idx).glbVars.glbUpInfoWired.index=args{1}.Index;
            models(idx).glbVars.glbUpInfoWired.trigger_armed=0;
            [models(idx).glbVars,status]=i_UserSignalSelect(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendSignalSelectResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            i_SendSignalSelectResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'SignalSelectFloating'
        try
            models(idx).glbVars.glbUpInfoFloating.upBlks=i_ParseUpBlks(args{1});
            models(idx).glbVars.glbUpInfoFloating.index=args{1}.Index;
            models(idx).glbVars.glbUpInfoFloating.trigger_armed=0;
            [models(idx).glbVars,status]=i_UserSignalSelectFloating(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendSignalSelectResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            i_SendSignalSelectResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoFloating.index);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'TriggerSelect'
        try
            models(idx).glbVars.glbUpInfoWired.trigger=args{1};
            [models(idx).glbVars,status]=i_UserTriggerSelect(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendTriggerSelectResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            i_SendTriggerSelectResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'TriggerSelectFloating'
        try
            models(idx).glbVars.glbUpInfoFloating.trigger=args{1};
            [models(idx).glbVars,status]=i_UserTriggerSelectFloating(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendTriggerSelectResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            i_SendTriggerSelectResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoFloating.index);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'TriggerArm'
        try
            [models(idx).glbVars,status]=i_UserTriggerArm(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            models(idx).glbVars.glbUpInfoWired.trigger_armed=0;
            i_SendTriggerArmResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            models(idx).glbVars.glbUpInfoWired.trigger_armed=1;
            i_SendTriggerArmResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'TriggerArmFloating'
        try
            [models(idx).glbVars,status]=i_UserTriggerArmFloating(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            models(idx).glbVars.glbUpInfoFloating.trigger_armed=0;
            i_SendTriggerArmResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            models(idx).glbVars.glbUpInfoFloating.trigger_armed=1;
            i_SendTriggerArmResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoFloating.index);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'CancelLogging'
        try
            models(idx).glbVars.glbUpInfoWired.trigger_armed=0;
            [models(idx).glbVars,status]=i_UserCancelLogging(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendCancelLoggingResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoWired.index);
            set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoWired.index);
            return;
        end
        try
            i_SendCancelLoggingResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoWired.index);
            set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoWired.index);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'CancelLoggingFloating'
        try
            if~isempty(models(idx).glbVars.glbUpInfoFloating)
                models(idx).glbVars.glbUpInfoFloating.trigger_armed=0;
                [models(idx).glbVars,status]=i_UserCancelLoggingFloating(models(idx).glbVars);
            end
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendCancelLoggingResponse(models(idx).glbVars,1,models(idx).glbVars.glbUpInfoFloating.index);
            set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoFloating.index);
            return;
        end
        try
            if~isempty(models(idx).glbVars.glbUpInfoFloating)
                i_SendCancelLoggingResponse(models(idx).glbVars,status,models(idx).glbVars.glbUpInfoFloating.index);
                set_param(models(idx).glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',models(idx).glbVars.glbUpInfoFloating.index);
            end
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'Start'
        try
            [models(idx).glbVars,status]=i_UserStart(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendStartResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendStartResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'Stop'
        try
            [models(idx).glbVars,status]=i_UserStop(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendStopResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendStopResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'Pause'
        try
            [models(idx).glbVars,status]=i_UserPause(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendPauseResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendPauseResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'Step'
        try
            [models(idx).glbVars,status]=i_UserStep(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendStepResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendStepResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'Continue'
        try
            [models(idx).glbVars,status]=i_UserContinue(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendContinueResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendContinueResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'GetTime'
        try
            [models(idx).glbVars,time]=i_UserGetTime(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            return;
        end
        try
            i_SendGetTimeResponse(models(idx).glbVars,time);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'Disconnect'
        try
            [models(idx).glbVars,status]=i_UserDisconnect(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendDisconnectResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendDisconnectResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'DisconnectImmediate'
        try
            models(idx).glbVars=i_UserDisconnectImmediate(models(idx).glbVars);
            models(idx).glbVars=i_cleanupGlbUpInfo(models(idx).glbVars);


        catch ME
            models(idx).glbVars=i_cleanupGlbUpInfo(models(idx).glbVars);
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            return;
        end


    case 'DisconnectConfirmed'
        try
            models(idx).glbVars=i_UserDisconnectConfirmed(models(idx).glbVars);


        catch ME
            models(idx).glbVars=i_cleanupGlbUpInfo(models(idx).glbVars);
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            return;
        end


    case 'FinalUpload'
        try
            models(idx).glbVars=i_UserFinalUpload(models(idx).glbVars);
            models(idx).glbVars=i_cleanupGlbUpInfo(models(idx).glbVars);


        catch ME
            models(idx).glbVars=i_cleanupGlbUpInfo(models(idx).glbVars);
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            return;
        end


    case 'CheckData'
        if models(idx).glbVars.restarting
            return;
        end
        try



            models(idx).messageQueue=i_ProcessMessageQueue(models(idx).messageQueue);






            cGlbCheckDataIsProcessing=models(idx).glbVars.glbCheckDataIsProcessing.set;




            if~isempty(models(idx).glbVars.glbUpInfoWired)&&...
                ~isempty(models(idx).glbVars.glbUpInfoWired.upBlks)&&...
                models(idx).glbVars.glbUpInfoWired.trigger_armed
                models(idx).glbVars=i_UserCheckData(models(idx).glbVars,models(idx).glbVars.glbUpInfoWired);
                models(idx).glbVars=feval(models(idx).glbVars.utilsFile.i_SendTerminate,models(idx).glbVars,models(idx).glbVars.glbUpInfoWired.index);
            end




            if~isempty(models(idx).glbVars.glbUpInfoFloating)&&...
                ~isempty(models(idx).glbVars.glbUpInfoFloating.upBlks)&&...
                models(idx).glbVars.glbUpInfoFloating.trigger_armed
                models(idx).glbVars=i_UserCheckData(models(idx).glbVars,models(idx).glbVars.glbUpInfoFloating);
                models(idx).glbVars=feval(models(idx).glbVars.utilsFile.i_SendTerminate,models(idx).glbVars,models(idx).glbVars.glbUpInfoFloating.index);
            end




            [models(idx).glbVars,status]=i_UserTargetStopped(models(idx).glbVars);
            if(status)
                i_SendStopResponse(models(idx).glbVars,0);
            end






        catch ME
            [models(idx).glbVars,status]=i_UserTargetStopped(models(idx).glbVars);
            if(status)
                i_SendStopResponse(models(idx).glbVars,0);
            end

            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);




            return;
        end
        cGlbCheckDataIsProcessing.delete;


    case 'StopForRestart'
        models(idx).glbVars.restarting=true;
        try
            [models(idx).glbVars,status]=i_UserStop(models(idx).glbVars);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            i_SendStopForRestartResponse(models(idx).glbVars,1);
            return;
        end
        try
            i_SendStopForRestartResponse(models(idx).glbVars,status);
        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
        end


    case 'StartForRestart'
        try
            h=uiscopes.find;
            for i=1:length(h)
                displays=h(i).Visual.Displays;
                for j=1:length(displays)
                    lines=displays{j}.Lines;
                    try
                        lines.reset;
                    catch
                    end
                end
            end
            [models(idx).glbVars,~]=i_UserStart(models(idx).glbVars);
            models(idx).glbVars.restarting=false;
        catch ME
            models(idx).glbVars.restarting=false;
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            return;
        end


    case 'ProcessUpBlock'
        try
            upBlockIdx=args{1};
            srcType=args{2};
            srcIdx=args{3};
            data=args{4};
            time=args{5};
            models(idx).glbVars=i_UserProcessUpBlock(models(idx).glbVars,upBlockIdx,srcType,srcIdx,data,time);


        catch ME
            models(idx).glbVars=i_ThrowError(models(idx).glbVars,action,ME);
            return;
        end


    otherwise
        DAStudio.error('Simulink:tools:extModeOpenInvCommand');

    end
end

function glbVars=i_ThrowError(glbVars,action,ME)





    err=ME.message;

    [glbVars,exceptionsEnabled]=i_ExceptionsEnabled(glbVars);

    if(~exceptionsEnabled)







        specialTag='Targets_External_mode_Error';





        openErrDlgs=findall(0,'Tag',specialTag);
        for k=1:length(openErrDlgs)
            delete(openErrDlgs(k));
        end




        errHandle=errordlg(DAStudio.message('Simulink:tools:extModeOpenGenericError',...
        action,err),'Error');




        set(errHandle,'Tag',specialTag);
    end




    glbVars=i_UserHandleError(glbVars,action);

    if(exceptionsEnabled)


        rethrow(ME);
    end

end




function glbVars=i_cleanupGlbUpInfo(glbVars)

    glbVars.glbUpInfoWired=[];
    glbVars.glbUpInfoFloating=[];

end





function[glbVars,exceptionsEnabled]=i_ExceptionsEnabled(glbVars)


    exceptionsEnabled=false;

    if isfield(glbVars.intrfFile,'i_UserExceptionsEnabled')
        [glbVars,exceptionsEnabled]=feval(glbVars.intrfFile.i_UserExceptionsEnabled,glbVars);
    end

end

function i_SendConnectResponse(glbVars,status,checksum1,checksum2,...
    checksum3,checksum4,intCodeOnly,tgtStatus)



    mat=cell(1,7);
    mat{1}=status;
    mat{2}=checksum1;
    mat{3}=checksum2;
    mat{4}=checksum3;
    mat{5}=checksum4;
    mat{6}=intCodeOnly;
    mat{7}=tgtStatus;
    set_param(glbVars.glbModel,'ExtModeOpenProtocolConnectResponse',mat);

end


function i_SendSetParamResponse(glbVars,status)



    set_param(glbVars.glbModel,'ExtModeOpenProtocolSetParamResponse',status);

end


function i_SendGetParamResponse(glbVars,status,params)



    mat=cell(1,2);
    mat{1}=status;
    mat{2}=params;
    set_param(glbVars.glbModel,'ExtModeOpenProtocolGetParamResponse',mat);

end


function i_SendSignalSelectResponse(glbVars,status,index)




    mat=cell(1,2);
    mat{1}=status;
    mat{2}=index;
    set_param(glbVars.glbModel,'ExtModeOpenProtocolSignalSelectResponse',mat);

end


function i_SendTriggerSelectResponse(glbVars,status,index)




    mat=cell(1,2);
    mat{1}=status;
    mat{2}=index;
    set_param(glbVars.glbModel,'ExtModeOpenProtocolTriggerSelectResponse',mat);

end


function i_SendTriggerArmResponse(glbVars,status,index)




    mat=cell(1,2);
    mat{1}=status;
    mat{2}=index;
    set_param(glbVars.glbModel,'ExtModeOpenProtocolArmTriggerResponse',mat);

end


function i_SendCancelLoggingResponse(glbVars,status,index)




    mat=cell(1,2);
    mat{1}=status;
    mat{2}=index;
    set_param(glbVars.glbModel,'ExtModeOpenProtocolCancelLoggingResponse',mat);

end


function i_SendStartResponse(glbVars,status)



    set_param(glbVars.glbModel,'ExtModeOpenProtocolStartResponse',status);

end


function i_SendStopResponse(glbVars,status)




    set_param(glbVars.glbModel,'ExtModeOpenProtocolShutdown',status);

end


function i_SendPauseResponse(glbVars,status)



    set_param(glbVars.glbModel,'ExtModeOpenProtocolPauseResponse',status);

end

function i_SendStepResponse(glbVars,status)



    set_param(glbVars.glbModel,'ExtModeOpenProtocolStepResponse',status);

end

function i_SendContinueResponse(glbVars,status)



    set_param(glbVars.glbModel,'ExtModeOpenProtocolContinueResponse',status);

end

function i_SendGetTimeResponse(glbVars,time)



    set_param(glbVars.glbModel,'ExtModeOpenProtocolGetTimeResponse',time);

end

function i_SendDisconnectResponse(glbVars,status)



    set_param(glbVars.glbModel,'ExtModeOpenProtocolDisconnectResponse',status);

end

function i_SendStopForRestartResponse(glbVars,status)





    set_param(glbVars.glbModel,'ExtModeOpenProtocolStopForRestartResponse',status);

end

function messageQueue=i_ProcessMessageQueue(messageQueue)







    if~isempty(messageQueue)
        messageQueueLen=length(messageQueue);
        for messageIdx=1:messageQueueLen
            message=messageQueue{messageIdx};
            argsStr=[];
            argsLen=length(message);
            for argIdx=1:argsLen
                argsStr=[argsStr,'message{',num2str(argIdx),'}'];%#ok
                if argIdx~=argsLen
                    argsStr=[argsStr,', '];%#ok
                end
            end
            messageStr=[mfilename,'(',argsStr,');'];
            eval(messageStr);
        end
        messageQueue=[];
    end
end

function parsedUpBlks=i_ParseUpBlks(selectSigsMsg)




    parsedUpBlks=cell(size(selectSigsMsg.UploadBlocks));

    if~isempty(selectSigsMsg.UploadBlocks)





        for nUpBlk=1:length(selectSigsMsg.UploadBlocks)
            parsedUpBlks{nUpBlk}.Name=selectSigsMsg.UploadBlocks(nUpBlk).Name;
            parsedUpBlks{nUpBlk}.LogEventCompleted=false;




            srcSignals=selectSigsMsg.UploadBlocks(nUpBlk).SrcSignals;
            str={};
            for i=1:length(srcSignals)
                blockPath=srcSignals{i}.BlockPath;
                portIndex=srcSignals{i}.PortIndex;
                unconnected=(strcmp(blockPath,'<unconnected>'))&&(portIndex==-1);

                if(~unconnected)

                    str{i}=[blockPath,num2str(portIndex)];%#ok
                end
            end
            [~,uniqueIdx]=unique(str);




            parsedUpBlks{nUpBlk}.SrcSignals=cell(1,length(uniqueIdx));
            for i=1:length(uniqueIdx)
                parsedUpBlks{nUpBlk}.SrcSignals{i}=srcSignals{uniqueIdx(i)};
            end




            srcMRSignals=selectSigsMsg.UploadBlocks(nUpBlk).SrcMRSignals;
            str={};
            for i=1:length(srcMRSignals)
                blockPath=srcMRSignals{i}.BlockPath;
                portIndex=srcMRSignals{i}.PortIndex;
                unconnected=(strcmp(blockPath,'<unconnected>'))&&(portIndex==-1);

                if(~unconnected)

                    tempStr='';
                    for nBlk=1:blockPath.getLength()
                        tempStr=[tempStr,blockPath.getBlock(nBlk)];%#ok
                    end
                    str{i}=[tempStr,num2str(portIndex)];%#ok
                end
            end
            [~,uniqueIdx]=unique(str);




            parsedUpBlks{nUpBlk}.SrcMRSignals=cell(1,length(uniqueIdx));
            for i=1:length(uniqueIdx)
                parsedUpBlks{nUpBlk}.SrcMRSignals{i}=srcMRSignals{uniqueIdx(i)};
            end




            srcDWorks=selectSigsMsg.UploadBlocks(nUpBlk).SrcDWorks;
            str={};
            for i=1:length(srcDWorks)
                blockPath=srcDWorks{i}.BlockPath;
                dworkName=srcDWorks{i}.DWorkName;


                str{i}=[blockPath,dworkName];%#ok
            end
            [~,uniqueIdx]=unique(str);




            parsedUpBlks{nUpBlk}.SrcDWorks=cell(1,length(uniqueIdx));
            for i=1:length(uniqueIdx)
                parsedUpBlks{nUpBlk}.SrcDWorks{i}=srcDWorks{uniqueIdx(i)};
            end
        end
    end

end

function glbVars=i_UserHandleError(glbVars,action)

    glbVars=feval(glbVars.intrfFile.i_UserHandleError,glbVars,action);

end

function glbVars=i_UserInit(glbVars)

    glbVars=feval(glbVars.intrfFile.i_UserInit,glbVars);

end

function[glbVars,status,checksum1,checksum2,checksum3,checksum4,...
    intCodeOnly,tgtStatus]=i_UserConnect(glbVars)

    [glbVars,status,checksum1,checksum2,checksum3,checksum4,...
    intCodeOnly,tgtStatus]=feval(glbVars.intrfFile.i_UserConnect,glbVars);

end

function[glbVars,status]=i_UserSetParam(glbVars,params)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserSetParam,glbVars,params);

end

function[glbVars,status,params]=i_UserGetParam(glbVars,params)



    glbVars.glbTunableParams=params;
    [glbVars,status,params]=feval(glbVars.intrfFile.i_UserGetParam,glbVars);

end

function[glbVars,status]=i_UserSignalSelect(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserSignalSelect,glbVars);

end

function[glbVars,status]=i_UserSignalSelectFloating(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserSignalSelectFloating,glbVars);

end

function[glbVars,status]=i_UserTriggerSelect(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserTriggerSelect,glbVars);

end

function[glbVars,status]=i_UserTriggerSelectFloating(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserTriggerSelectFloating,glbVars);

end

function[glbVars,status]=i_UserTriggerArm(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserTriggerArm,glbVars);

end

function[glbVars,status]=i_UserTriggerArmFloating(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserTriggerArmFloating,glbVars);

end

function[glbVars,status]=i_UserCancelLogging(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserCancelLogging,glbVars);

end

function[glbVars,status]=i_UserCancelLoggingFloating(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserCancelLoggingFloating,glbVars);

end

function[glbVars,status]=i_UserStart(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserStart,glbVars);

end

function[glbVars,status]=i_UserStop(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserStop,glbVars);

end

function[glbVars,status]=i_UserPause(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserPause,glbVars);

end

function[glbVars,status]=i_UserStep(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserStep,glbVars);

end

function[glbVars,status]=i_UserContinue(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserContinue,glbVars);

end

function[glbVars,time]=i_UserGetTime(glbVars)

    [glbVars,time]=feval(glbVars.intrfFile.i_UserGetTime,glbVars);

end

function[glbVars,status]=i_UserDisconnect(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserDisconnect,glbVars);

end

function glbVars=i_UserDisconnectImmediate(glbVars)

    glbVars=feval(glbVars.intrfFile.i_UserDisconnectImmediate,glbVars);

end

function glbVars=i_UserDisconnectConfirmed(glbVars)

    glbVars=feval(glbVars.intrfFile.i_UserDisconnectConfirmed,glbVars);

end

function[glbVars,status]=i_UserTargetStopped(glbVars)

    [glbVars,status]=feval(glbVars.intrfFile.i_UserTargetStopped,glbVars);

end

function glbVars=i_UserFinalUpload(glbVars)

    glbVars=feval(glbVars.intrfFile.i_UserFinalUpload,glbVars);

end

function glbVars=i_UserCheckData(glbVars,upInfo)

    glbVars=feval(glbVars.intrfFile.i_UserCheckData,glbVars,upInfo);

end

function glbVars=i_UserProcessUpBlock(glbVars,upBlockIdx,srcType,srcIdx,data,time)

    glbVars=feval(glbVars.intrfFile.i_UserProcessUpBlock,glbVars,upBlockIdx,srcType,srcIdx,data,time);

end
