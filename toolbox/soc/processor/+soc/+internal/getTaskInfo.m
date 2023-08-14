function info=getTaskInfo(modelName,taskName)





    reg=soc.internal.ESBRegistry.manageInstance('getfullmodelreferencehierarchy',modelName,'ESB');
    allTaskNames={reg.Tasks(:).Name};
    [isTaskFound,tskIdx]=ismember(taskName,allTaskNames);
    assert(isTaskFound,['The task ''',taskName,''' is not in the registry']);

    taskData=reg.Tasks(tskIdx);
    eventID=taskData.EventID;

    info.Error='';
    info.Name=taskName;
    info.IOBlockHandle='';
    info.DeviceType='';
    info.Period=-1;

    info.PollFcn='';
    info.PollFcnInit='';
    info.PollFcnTerm='';
    info.PollFcnArg='';
    info.PollConfig='';
    info.PollIncludeFile='';
    info.PollIncludePath='';
    info.PollSrcFile='';
    info.PollSrcPath='';

    if isequal(eventID,'clock')
        info.Type='Timer-driven';
        info.Period=taskData.Period;
    else
        info.Type='Event-driven';
        allEventBlocks=[reg.EventSrcBlocks(:),reg.EventSnkBlocks(:)];
        info=verifyNoMultipleEventSourcesForTask(modelName,allEventBlocks,taskName,info);
        if~isempty(info.Error),return;end
        for blkIdx=1:numel(allEventBlocks)

            eventData=allEventBlocks(blkIdx).Events;
            if~isempty(eventData.IOBlockHandle)&&~isempty(eventData.TaskFcnPollCmd)
                blockTaskName=soc.internal.connectivity.getTaskNameForFcnCallSubs(eventData.IOBlockHandle,modelName);
                if isequal(taskName,blockTaskName)
                    info.PollFcn=eventData.TaskFcnPollCmd;
                    info.PollFcnArg=eventData.TaskFcnPollCmdArg;
                    break;
                end
            end
        end


        if isempty(info.PollFcn)&&~isProxyTask(modelName,taskName)

            tskMgrBlkName=soc.internal.connectivity.getTaskManagerBlock(modelName);
            evtType=soc.internal.taskmanager.getEventSourceTypeForTask(tskMgrBlkName,taskName);

            if ismember(evtType,{'Audio Capture Interface','Video Capture Interface'})

            else






                info.DeviceType='IPCoreInterrupt';

                blk_name=soc.internal.taskmanager.getEventSourceForTask(tskMgrBlkName,taskName);

                ipcore_name=soc.util.formatIPCoreName(blk_name);
                devtree_name=soc.if.CustomDeviceTreeUpdater.getValidDeviceName(ipcore_name);

                deviceName=[devtree_name,'0'];
                deviceNamePathPrefix='/sys/class/mathworks_ip/';
                deviceNamePathPostfix='/device/fpga_irq_0';
                deviceNameFullStr=['"',deviceNamePathPrefix,deviceName,deviceNamePathPostfix,'"'];
                poolConfigName=['poll_config_',deviceName];

                info.PollIncludeFile='mw_interrupt_poll.h';
                info.PollIncludePath=fullfile(soc.internal.getRootDir,'include');
                info.PollSrcFile='mw_interrupt_poll.c';
                info.PollSrcPath=fullfile(soc.internal.getRootDir,'src');

                info.PollFcn='mw_int_poll';
                info.PollFcnInit=['mw_int_setup_poll(&',poolConfigName,',',deviceNameFullStr,')'];
                info.PollFcnTerm='mw_int_close_poll';
                info.PollFcnArg=[poolConfigName,'_ptr'];
                info.PollConfig=['mw_int_poll_config ',poolConfigName];
            end
        end
    end

    buildInfo=codertarget.interrupts.internal.getModelBuildInfo(modelName);
    if~isempty(buildInfo)
        if~isempty(info.PollIncludePath)
            addIncludePaths(buildInfo,info.PollIncludePath);
        end
        if~isempty(info.PollIncludeFile)
            addIncludeFiles(buildInfo,info.PollIncludeFile,info.PollIncludePath,'BuildDir');
        end
        if~isempty(info.PollSrcFile)
            addSourceFiles(buildInfo,info.PollSrcFile,info.PollSrcPath,'BuildDir');
        end
    end

end


function ret=isProxyTask(ModelName,TaskName)
    try
        ret=soc.internal.connectivity.isProxyTask(ModelName,TaskName);
    catch
        ret=false;
    end
end


function info=verifyNoMultipleEventSourcesForTask(modelName,allEventBlocks,...
    taskName,info)
    srcBlksInThisTask={};
    for blkIdx=1:numel(allEventBlocks)

        eventData=allEventBlocks(blkIdx).Events;
        blkHandle=eventData.IOBlockHandle;
        if~isempty(blkHandle)&&~isempty(eventData.TaskFcnPollCmd)
            blockTaskName=...
            soc.internal.connectivity.getTaskNameForFcnCallSubs(blkHandle,modelName);
            if isequal(taskName,blockTaskName)
                srcBlksInThisTask{end+1}=blkHandle;%#ok<AGROW>
            end
        end
    end
    if isequal(numel(srcBlksInThisTask),1),return;end
    src1='';
    for i=1:numel(srcBlksInThisTask)
        thisBlk=srcBlksInThisTask{i};
        maskBlk=locGetMaskedBlock(thisBlk);
        if isequal(get_param(maskBlk,'EnableEvent'),'on')
            if isempty(src1)
                src1=get_param(maskBlk,'Name');
            else
                src2=get_param(maskBlk,'Name');
                info.Error=[...
                'The subsystem connected to the task ',taskName,' contains '...
                ,'these blocks that both enable event-based execution: '...
                ,src1,' and ',src2,', which is not allowed. '...
                ,'Disable event-based execution for one of these blocks.'];
                break;
            end
        end
    end
    function blk=locGetMaskedBlock(ioBlk)
        blk=get_param(ioBlk,'Parent');
        blk=get_param(blk,'Parent');
        blk=get_param(blk,'Parent');
    end
end