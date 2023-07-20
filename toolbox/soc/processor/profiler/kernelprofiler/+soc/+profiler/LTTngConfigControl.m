classdef LTTngConfigControl<handle








    methods(Access='private')
        function out=LTTngConfigControl
        end
    end

    methods(Access='private',Static)
        function cmdPrefix=loc_getCommandPrefix(hwObj)
            [~,~,status]=hwObj.execute('sudo -l',false);
            if status~=0&&status~=141
                cmdPrefix='';
            else
                cmdPrefix='sudo ';
            end
        end
        function loc_execute(hwObj,command)
            [~,~,ret]=hwObj.execute(command,false);
            if ret>0
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',command,ret)
            end
        end
        function hwObj=constructHwObj(inArg)
            if isequal(inArg.IPAddress,'127.0.0.1')||isequal(inArg.IPAddress,'localhost')
                hwObj=matlabshared.internal.ssh2client(inArg.IPAddress,inArg.Username,inArg.Password,2200);
            else
                hwObj=matlabshared.internal.ssh2client(inArg.IPAddress,inArg.Username,inArg.Password);
            end
        end
        function startVisualizations(ModelName)
            hmiOpts.RecordOn=false;
            hmiOpts.VisualizeOn=true;
            hmiOpts.CommandLine=false;
            hmiOpts.StartTime=0;
            hmiOpts.StopTime=inf;
            hmiOpts.EnableRollback=false;
            hmiOpts.SnapshotInterval=10;
            hmiOpts.NumberOfSteps=1;
            Simulink.HMI.slhmi('sim_start',ModelName,hmiOpts);
        end
    end
    methods(Static)
        function configure(inArg)

            hwObj=soc.profiler.LTTngConfigControl.constructHwObj(inArg);

            soc.profiler.LTTngConfigControl.loc_execute(hwObj,'rm -rf /tmp/lttnglogs/');

            cmd='grep -c ^processor /proc/cpuinfo';
            [numberOfCores,~,ret]=hwObj.execute(cmd,false);
            if(ret~=0)
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',cmd,ret);
            end
            numberOfCores=str2double(numberOfCores);

            soc.profiler.LTTngConfigControl.memoryCheckForSubBuffers(hwObj,inArg,numberOfCores);

            switchTimer=200000;
            cmdPrefix=soc.profiler.LTTngConfigControl.loc_getCommandPrefix(hwObj);

            if(strcmp(inArg.Mode,'ONLINE'))
                tryCmd='pidof lttng-relayd';
                try
                    hwObj.execute(tryCmd);
                    relayDemnRunning=1;
                catch
                    relayDemnRunning=0;
                end
                if relayDemnRunning==0
                    cmd=sprintf('lttng-relayd -L tcp://%s:%d --output=/tmp/lttnglogs/ >/dev/null &',inArg.IPAddress,inArg.Port);
                    try
                        [~,~,ret]=hwObj.execute([cmdPrefix,cmd],false);
                        if(ret~=0)
                            DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',cmd,ret);
                        end
                    catch ex
                        rethrow(ex);
                    end
                    live_cmd=sprintf('lttng create %s --live --set-url=net://%s\n',inArg.ModelName,inArg.IPAddress);
                    [~,~,ret]=hwObj.execute([cmdPrefix,live_cmd],false);
                    if(ret==28)
                        soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,'lttng destroy ',inArg.ModelName]);
                        soc.profiler.LTTngConfigControl.loc_execute(hwObj,live_cmd);
                    end
                    soc.profiler.LTTngConfigControl.startVisualizations(inArg.ModelName);

                    bufSize=1048576;
                    bufCnt=16;

                    if numberOfCores<=2
                        bufCnt=8;
                    end

                    unlimitedMode=DAStudio.message('codertarget:ui:HWDiagStreamingModeUnLimValue');
                    streamingModeType=soc.profiler.LTTngConfigControl.getStreamingModeType(inArg.ModelName);

                    if strcmp(streamingModeType,unlimitedMode)
                        nTraceFilesPerCore=2;

                        availableTmpMemory=soc.profiler.LTTngConfigControl.memoryCheckForTraceFiles(hwObj,inArg,numberOfCores);

                        [kTraceFileSize,uTraceFileSize]=soc.profiler.LTTngConfigControl.getTraceFileSize(availableTmpMemory,numberOfCores,nTraceFilesPerCore);
                        soc.profiler.LTTngConfigControl.configureChannelWithTraceFile(hwObj,bufSize,bufCnt,switchTimer,kTraceFileSize,uTraceFileSize,nTraceFilesPerCore);
                    else

                        soc.profiler.LTTngConfigControl.configureChannelWithOutTraceFile(hwObj,bufSize,bufCnt,switchTimer);
                    end
                else

                    appCmd=sprintf('killall %s',inArg.ApplicationName);
                    hwObj.execute(appCmd,false);
                    DAStudio.error('soc:taskprofiler:ErrorOccuredMultipleOnlineSessionNotSupported');
                end
            elseif(strcmp(inArg.Mode,'OFFLINE'))

                cmd=sprintf('lttng create %s --output=/tmp/lttnglogs/%s ',inArg.ModelName,inArg.ModelName);
                [~,~,ret]=hwObj.execute([cmdPrefix,cmd],false);
                if(ret==28)
                    soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,'lttng destroy ',inArg.ModelName]);
                    soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,cmd]);
                end

                bufSize=131072;
                bufCnt=16;

                if numberOfCores<=2
                    bufCnt=8;
                end

                command=sprintf('lttng enable-channel --kernel --subbuf-size=%d --num-subbuf=%d channel0',bufSize,bufCnt);
                soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,command]);

                command=sprintf('lttng enable-channel -u --switch-timer=%d channel0',switchTimer);
                soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,command]);
            else
                assert(false,['''',inArg.Mode,''''' is not a valid kernel profiling mode']);
            end

            modelName=inArg.ModelName;
            if length(modelName)>15
                modelNameReg=[modelName(1:15),'*'];
            else
                modelNameReg=[modelName,'*'];
            end

            subCommand='lttng enable-event -k sched_process_fork --filter=''parent_comm == "';
            forkEventCommand=[cmdPrefix,subCommand,modelNameReg,'" || parent_comm == "_socb*" || parent_comm == "scheduler" || parent_comm == "baseTimerTask" || parent_comm == "background" || parent_comm == "Discre*"''',' -c channel0 --session=',modelName];





            subCommand='lttng enable-event -k sched_waking --filter=''comm == "';
            wakingEventCommand=[cmdPrefix,subCommand,modelNameReg,'" || comm == "_socb*" || comm == "scheduler" || comm == "baseTimerTask" || comm == "background" || comm == "Discre*"''',' -c channel0 --session=',modelName];


            subCommand='lttng enable-event -k sched_switch --filter=''prev_comm == "';
            switchEventCommand=[cmdPrefix,subCommand,modelNameReg,'" || prev_comm == "_socb*" || prev_comm == "scheduler" || prev_comm == "baseTimerTask" || prev_comm == "background" || prev_comm == "Discre*" || next_comm == "',modelNameReg,'" || next_comm == "_socb*" || next_comm == "scheduler" || next_comm == "baseTimerTask" || next_comm == "background" || next_comm == "Discre*"''',' -c channel0 --session=',modelName];


            subCommand='lttng enable-event -k sched_process_exit --filter=''comm == "';
            exitEventCommand=[cmdPrefix,subCommand,modelNameReg,'" || comm == "_socb*" || comm == "scheduler" || comm == "baseTimerTask" || comm == "background" || comm == "Discre*"''',' -c channel0 --session=',modelName];


            subCommand='lttng enable-event -k signal_generate --filter=''(comm == "';
            sigEventCommand=[cmdPrefix,subCommand,modelNameReg,'" || comm == "_socb*") && (sig == 10 || sig == 12)''',' -c channel0 --session=',modelName];


            [~,~,ret]=hwObj.execute(forkEventCommand,false);
            if ret~=0&&ret~=35
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',forkEventCommand,ret)
            end







            [~,~,ret]=hwObj.execute(wakingEventCommand,false);
            if ret~=0&&ret~=35
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',wakingEventCommand,ret)
            end

            [~,~,ret]=hwObj.execute(switchEventCommand,false);
            if ret~=0&&ret~=35
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',switchEventCommand,ret)
            end

            [~,~,ret]=hwObj.execute(exitEventCommand,false);
            if ret~=0&&ret~=35
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',exitEventCommand,ret)
            end

            [~,~,ret]=hwObj.execute(sigEventCommand,false);
            if ret~=0&&ret~=35
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',sigEventCommand,ret)
            end

            command=['lttng enable-event -u kernelprofiler:kernelprofiler_task_drop -c channel0 --session=',inArg.ModelName];
            [~,~,ret]=hwObj.execute([cmdPrefix,command],false);
            if ret~=0&&ret~=35
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',command,ret)
            end
        end
        function stop(inArg)

            hwObj=soc.profiler.LTTngConfigControl.constructHwObj(inArg);
            cmdPrefix=soc.profiler.LTTngConfigControl.loc_getCommandPrefix(hwObj);

            stopCmd=sprintf('lttng stop %s',inArg.ModelName);
            [~,~,ret]=hwObj.execute([cmdPrefix,stopCmd],false);
            if ret~=0&&ret~=81
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand','lttng stop',ret)
            end

            destroyCmd=sprintf('lttng destroy %s',inArg.ModelName);
            soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,destroyCmd]);
        end
        function destroy(inArg)

            hwObj=soc.profiler.LTTngConfigControl.constructHwObj(inArg);
            cmd='grep -c ^processor /proc/cpuinfo';
            [numberOfCores,~,ret]=hwObj.execute(cmd,false);
            if(ret~=0)
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',cmd,ret);
            end
            numberOfCores=str2double(numberOfCores);
            if strcmp(inArg.Mode,'OFFLINE')


                hwObj.execute('pkill lttng',false);


                if isfolder('kernelprofiler')
                    rmdir('kernelprofiler','s');
                end
                mkdir('kernelprofiler');

                mkdir('kernelprofiler/kernel');

                mkdir('kernelprofiler/ust');

                try
                    hwObj.scpGetFile(sprintf('/tmp/lttnglogs/%s/kernel/metadata',inArg.ModelName),'./kernelprofiler/kernel/metadata');
                    i=0;
                    while(i<numberOfCores)
                        hwObj.scpGetFile(sprintf('/tmp/lttnglogs/%s/kernel/channel0_%d',inArg.ModelName,i),sprintf('./kernelprofiler/kernel/channel0_%d',i));
                        i=i+1;
                    end
                catch ex
                    MSLDiagnostic('soc:taskprofiler:ErrorOnTraceFileCopy',ex.message).reportAsWarning;
                end

                try
                    if numberOfCores<=2
                        hwObj.scpGetFile(sprintf('/tmp/lttnglogs/%s/ust/uid/0/32-bit/metadata',inArg.ModelName),'./kernelprofiler/ust/metadata');
                    else
                        hwObj.scpGetFile(sprintf('/tmp/lttnglogs/%s/ust/uid/0/64-bit/metadata',inArg.ModelName),'./kernelprofiler/ust/metadata');
                    end
                    i=0;
                    while(i<numberOfCores)
                        if numberOfCores<=2
                            hwObj.scpGetFile(sprintf('/tmp/lttnglogs/%s/ust/uid/0/32-bit/channel0_%d',inArg.ModelName,i),sprintf('./kernelprofiler/ust/channel0_%d',i));
                        else
                            hwObj.scpGetFile(sprintf('/tmp/lttnglogs/%s/ust/uid/0/64-bit/channel0_%d',inArg.ModelName,i),sprintf('./kernelprofiler/ust/channel0_%d',i));
                        end
                        i=i+1;
                    end
                catch

                    rmdir('kernelprofiler/ust');
                end
                soc.profiler.LTTngConfigControl.startVisualizations(inArg.ModelName);

                hwObj.execute('pkill lttng',false);
            elseif strcmp(inArg.Mode,'ONLINE')

                hwObj.execute('pkill lttng',false);
            else
                assert(false,['''',inArg.Mode,''''' is not a valid kernel profiling mode']);
            end
            postfix=DAStudio.message('soc:scheduler:HWDiagFolderPostfix');
            soc.internal.profile.saveTaskInfo(inArg.ModelName,postfix);
        end
        function start(inArg)
            hwObj=soc.profiler.LTTngConfigControl.constructHwObj(inArg);
            cmdPrefix=soc.profiler.LTTngConfigControl.loc_getCommandPrefix(hwObj);

            startCmd=sprintf('lttng start %s',inArg.ModelName);
            try
                [~,~]=hwObj.execute([cmdPrefix,startCmd]);
            catch ex
                rethrow(ex);
            end

            fOut=fopen('allThrdNames.txt','w');

            cmd=sprintf('pidof %s',inArg.ApplicationName);
            try
                [pidStr,ret]=hwObj.execute(cmd);
            catch
                MSLDiagnostic('soc:taskprofiler:ErrorOnGetPid').reportAsWarning;
                ret=1;
            end

            if isempty(ret)

                pid=sscanf(pidStr,'%d');

                cmd=sprintf('ls /proc/%d/task/',pid);

                [tidStr,ret]=hwObj.execute(cmd);
                if ret~=0

                    soc.profiler.LTTngConfigControl.hardReset(inArg);
                    DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',cmd,ret)
                end

                tids=sscanf(tidStr,'%d');
                [nbThrds,~]=size(tids);
                k=1;
                while(k<=nbThrds)

                    cmd=sprintf('cat /proc/%d/task/%d/comm',pid,tids(k));

                    [thrdName,ret]=hwObj.execute(cmd);
                    if ret~=0

                        soc.profiler.LTTngConfigControl.hardReset(inArg);
                        DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',cmd,ret)
                    end

                    strToWrite=sprintf('TID = %d, Threadname= %s',tids(k),thrdName);

                    fprintf(fOut,strToWrite);
                    k=k+1;
                end
            end

            fclose(fOut);
        end
        function validate(inArg)
            hwObj=soc.profiler.LTTngConfigControl.constructHwObj(inArg);

            [~,~,ret]=hwObj.execute('which lttng',false);
            if ret>0
                DAStudio.error('soc:taskprofiler:KernelProfilerNotDetected',inArg.IPAddress)
            end
        end
        function hardReset(inArg)
            hwObj=soc.profiler.LTTngConfigControl.constructHwObj(inArg);
            cmdPrefix=soc.profiler.LTTngConfigControl.loc_getCommandPrefix(hwObj);
            hwObj.execute([cmdPrefix,'lttng destroy ',inArg.ModelName],false);
            hwObj.execute('pkill lttng',false);
        end
        function memoryCheckForSubBuffers(hwObj,inArg,numberOfCores)

            kSubBufferSize=1;
            uSubBufferSize=0.125;

            kSubBufferCount=8;
            uSubBufferCount=4;
            if strcmp(inArg.Mode,'OFFLINE')
                kSubBufferSize=0.1250;
            end
            if numberOfCores>2
                kSubBufferCount=16;
            end
            minRequiredMemory=(kSubBufferSize*kSubBufferCount*numberOfCores)+...
            (uSubBufferSize*uSubBufferCount*numberOfCores);

            memoryGetCmd='free -m | awk ''NR==2 {print $4}''';
            [cmdOutput,~,status]=hwObj.execute(memoryGetCmd,false);
            if status~=0
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',memoryGetCmd,status);
            end
            availableMemoryInMiB=str2double(cmdOutput);
            if minRequiredMemory>availableMemoryInMiB

                appCmd=sprintf('killall %s',inArg.ApplicationName);
                hwObj.execute(appCmd,false);
                DAStudio.error('soc:taskprofiler:InSufficientMemory',availableMemoryInMiB,minRequiredMemory);
            end
        end
        function availableTmpMemory=memoryCheckForTraceFiles(hwObj,inArg,numberOfCores)
            nTraceFilesPerCore=2;
            minTraceFileSize=16;
            numberOfDomains=2;
            memoryForMetadata=2;
            minReqMemory=(minTraceFileSize*nTraceFilesPerCore*numberOfCores*numberOfDomains)+memoryForMetadata;

            tmpMemoryGetCmd='df -m /tmp | awk ''NR==2 {print $4}''';
            [cmdOutput,~,status]=hwObj.execute(tmpMemoryGetCmd,false);
            if status~=0
                soc.profiler.LTTngConfigControl.hardReset(inArg);
                DAStudio.error('soc:taskprofiler:ErrorOccuredRunningRemoteLTTngCommand',tmpMemoryGetCmd,status);
            end
            availableTmpMemory=str2double(cmdOutput);
            if minReqMemory>availableTmpMemory
                appCmd=sprintf('killall %s',inArg.ApplicationName);
                hwObj.execute(appCmd,false);

                DAStudio.error('soc:taskprofiler:InSufficientMemoryForUnlimitedProfiling',availableTmpMemory,minReqMemory);
            else

                availableTmpMemory=availableTmpMemory-memoryForMetadata;
            end
        end
        function streamingModeType=getStreamingModeType(modelName)
            try

                streamingModeType=DAStudio.message('codertarget:ui:HWDiagStreamingModeUnLimValue');

                valStore=DAStudio.message('codertarget:ui:HWDiagStreamingModeTypeStorage');
                cfgSet=getActiveConfigSet(modelName);
                if codertarget.data.isParameterInitialized(cfgSet,valStore)
                    streamingModeType=codertarget.data.getParameterValue(cfgSet,valStore);
                end
            catch

                streamingModeType=DAStudio.message('codertarget:ui:HWDiagStreamingModeUnLimValue');
            end
        end
        function configureChannelWithOutTraceFile(hwObj,bufSize,bufCnt,switchTimer)
            cmdPrefix=soc.profiler.LTTngConfigControl.loc_getCommandPrefix(hwObj);
            kCommand=sprintf('lttng enable-channel --kernel --subbuf-size=%d --num-subbuf=%d channel0',bufSize,bufCnt);
            uCommand=sprintf('lttng enable-channel -u --switch-timer=%d channel0',switchTimer);
            soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,kCommand]);
            soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,uCommand]);
        end
        function configureChannelWithTraceFile(hwObj,subBufferSize,subBufferCount,switchTimer,kTraceFileSize,uTraceFileSize,nTraceFilesPerCore)
            cmdPrefix=soc.profiler.LTTngConfigControl.loc_getCommandPrefix(hwObj);
            kCommand=sprintf('lttng enable-channel --kernel --subbuf-size=%d --num-subbuf=%d --tracefile-size=%s --tracefile-count=%d channel0',subBufferSize,subBufferCount,kTraceFileSize,nTraceFilesPerCore);
            uCommand=sprintf('lttng enable-channel -u --switch-timer=%d --tracefile-size=%s --tracefile-count=%d channel0',switchTimer,uTraceFileSize,nTraceFilesPerCore);
            soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,kCommand]);
            soc.profiler.LTTngConfigControl.loc_execute(hwObj,[cmdPrefix,uCommand]);
        end
        function[kTraceFileSize,uTraceFileSize]=getTraceFileSize(availableTmpMemory,numberOfCores,nTraceFilesPerCore)
            kMemoryAllocated=(70*availableTmpMemory)/100;
            kTraceFileSize=kMemoryAllocated/(numberOfCores*nTraceFilesPerCore);

            kTraceFileSize=power(2,floor(log2(kTraceFileSize)));

            kMemoryAllocated=kTraceFileSize*numberOfCores*nTraceFilesPerCore;

            uMemoryAllocated=availableTmpMemory-kMemoryAllocated;
            uTraceFileSize=uMemoryAllocated/(numberOfCores*nTraceFilesPerCore);

            uTraceFileSize=power(2,floor(log2(uTraceFileSize)));

            kTraceFileSize=[num2str(kTraceFileSize),'M'];
            uTraceFileSize=[num2str(uTraceFileSize),'M'];
        end
    end
end
