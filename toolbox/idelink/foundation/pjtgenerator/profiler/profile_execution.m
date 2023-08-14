function profData=profile_execution(IDE_Obj,varargin)
















    if nargin==1
        MSLDiagnostic('ERRORHANDLER:utils:ObsoleteFunction','PROFILE_EXECUTION','PROFILE').reportAsWarning;
    end



    switch varargin{1}
    case 'subsystem'
        subsystemProfilingOn=1;
    otherwise
        subsystemProfilingOn=0;
    end




    procrunning=IDE_Obj.isrunning;
    if(procrunning)
        MSLDiagnostic('ERRORHANDLER:pjtgenerator:ProfilerTargetIsNotHalted').reportAsWarning;
        IDE_Obj.halt;
    end

    try












        padrnumTimerTasks=address(IDE_Obj,'pnumTimerTasks');


        if numel(padrnumTimerTasks)<2
            page_memtype=0;
        else
            page_memtype=padrnumTimerTasks(2);
        end

        adrnumTimerTasks=double(read(IDE_Obj,padrnumTimerTasks,'uint32'));
        numTimerTasks=double(read(IDE_Obj,[adrnumTimerTasks,page_memtype],'uint32'));

        adrnumISRTasks=double(read(IDE_Obj,address(IDE_Obj,'pnumISRTasks'),'uint32'));
        numISRTasks=double(read(IDE_Obj,[adrnumISRTasks,page_memtype],'uint32'));

        adrnumIdleTasks=double(read(IDE_Obj,address(IDE_Obj,'pnumIdleTasks'),'uint32'));
        numIdleTasks=double(read(IDE_Obj,[adrnumIdleTasks,page_memtype],'uint32'));

        adroRunMax=double(read(IDE_Obj,address(IDE_Obj,'poRunMax'),'uint32'));
        rawData.oRunMax=double(read(IDE_Obj,[adroRunMax,page_memtype],'uint32',numTimerTasks));

        adrtMax=double(read(IDE_Obj,address(IDE_Obj,'ptMax'),'uint32'));
        rawData.tMax=double(read(IDE_Obj,[adrtMax,page_memtype],'uint32',numTimerTasks));

        adrnumPoints=double(read(IDE_Obj,address(IDE_Obj,'pnumPoints'),'uint32'));
        rawData.numPoints=double(read(IDE_Obj,[adrnumPoints,page_memtype],'uint32'));

        adrloggedData=double(read(IDE_Obj,address(IDE_Obj,'ploggedData'),'uint32'));
        rawData.loggedData=double(read(IDE_Obj,[adrloggedData,page_memtype],'int32',rawData.numPoints));

        adrtimePerTickUnits=double(read(IDE_Obj,address(IDE_Obj,'ptimerPsPerTick'),'uint32'));
        timePerTickUnits=double(read(IDE_Obj,[adrtimePerTickUnits,page_memtype],'uint32'));

        adrtimerCntWordSz=double(read(IDE_Obj,address(IDE_Obj,'ptimerCntWordSz'),'uint32'));
        timerCntWordSz=double(read(IDE_Obj,[adrtimerCntWordSz,page_memtype],'uint32'));
    catch ex %#ok<NASGU>
        DAStudio.error('ERRORHANDLER:pjtgenerator:ProfilerCannotReadData');
    end


    if(procrunning)
        IDE_Obj.run;
    end


    profileInfo.timer.timePerTickUnits=timePerTickUnits;
    profileInfo.processor.wordsize=timerCntWordSz;
    profileInfo.processor.lsbFirst=0;
    profileInfo.tasks.names={};
    profileInfo.tasks.ids=[];

    taskData.numSyncTasks=numTimerTasks;
    taskData.numISRTasks=numISRTasks;
    taskData.numIdleTasks=numIdleTasks;

    if~isempty(rawData)


        endOfValidData=checkDataIntegrity(rawData,taskData);
        incompleteDataFlg=0;
        if(endOfValidData<rawData.numPoints)

            rawData.loggedData=rawData.loggedData(1:endOfValidData);

            incompleteDataFlg=1;
        end












        profData=profile_execution_unpack(rawData,profileInfo,IDE_Obj);

        if subsystemProfilingOn





            profData=gen_subsystem_name_list(profData);

            profile_subsystem_execution_report(profData);

            profData=profile_execution_plot(profData,incompleteDataFlg);


            profData=formatTaskToSubsys(profData);

        else





            profData=gen_task_name_list(profData,taskData);

            profile_execution_report(profData);

            profData=profile_execution_plot(profData,incompleteDataFlg);
        end

    end

    function endOfValidData=checkDataIntegrity(rawData,taskData)






        actualNumPoints=nnz(rawData.loggedData(1:2:end));
        if 0==actualNumPoints

            DAStudio.error('ERRORHANDLER:pjtgenerator:ProfilerNoData');
        elseif actualNumPoints~=rawData.numPoints/2


            MSLDiagnostic('ERRORHANDLER:pjtgenerator:ProfilerIncompleteData',...
            int32(rawData.numPoints/2),int32(actualNumPoints)).reportAsWarning;
        end




        tIDs=rawData.loggedData(1:2:end-1);

        stack=[];
        for i=1:length(find(tIDs))

            endOfValidData=i*2;

            if tIDs(i)>0

                stack(end+1)=tIDs(i);%#ok<AGROW> % push
            else

                marker=stack(end);


                if marker~=-1*tIDs(i)


                    runningTasks=genTaskName(stack(1),taskData);
                    for j=2:length(stack)
                        runningTasks=[runningTasks,', ',genTaskName(stack(j)),taskData];%#ok<AGROW>
                    end
                    MSLDiagnostic('ERRORHANDLER:pjtgenerator:ProfilerFoundIncompleteTasks',runningTasks).reportAsWarning;


                    endOfValidData=endOfValidData-2;


                    return;
                end

                stack=stack(1:end-1);
            end

        end

        function taskName=genTaskName(taskID,taskData)



            if(taskID>taskData.numSyncTasks+taskData.numISRTasks)
                taskName='Idle';
            elseif(taskID>taskData.numSyncTasks)
                ofs=taskData.numSyncTasks+1;
                taskName=['Task ',num2str(taskID-ofs)];
            else
                if taskID==1
                    taskName='Base-Rate';
                else
                    taskName=['Sub-Rate ',num2str(taskID-1)];
                end
            end


            function profData=gen_task_name_list(profData,taskData)



                taskIdList=profData.taskIdList;


                if any(sort(taskIdList)~=taskIdList)
                    DAStudio.error('ERRORHANDLER:pjtgenerator:ProfilerTaskIdsNotSorted');
                end


                taskNameList={};

                for i=1:length(taskIdList)
                    taskNameList{i}=genTaskName(taskIdList(i),taskData);%#ok<AGROW>
                end

                profData.taskNameList=taskNameList;

                function profData=gen_subsystem_name_list(profData)



                    S=accessPersistentProfileInfo;

                    taskNameList={};
                    for i=1:length(profData.taskIdList)
                        subsysName=S.sys(profData.taskIdList(i)).name;
                        subsysName=strrep(subsysName,sprintf('\n'),' ');
                        taskNameList{i}=subsysName;%#ok<AGROW>
                    end
                    profData.taskNameList=taskNameList;
                    profData.modelName=S.modelName;
























                    function subsysData=formatTaskToSubsys(profData)


                        subsysData.numTimerSubsystems=profData.numTimerTasks;
                        subsysData.wsize=profData.wsize;
                        subsysData.subsystemActivity=profData.taskActivity;
                        subsysData.subsystemIdList=profData.taskIdList;
                        subsysData.subsysTs=profData.taskTs;
                        subsysData.subsysTicks=profData.taskTicks;
                        subsysData.timePerTick=profData.timePerTick;
                        subsysData.warning=profData.warning;
                        subsysData.subsysNameList=profData.taskNameList;
                        subsysData.recordedSubsysIdx=profData.recordedTaskIdx;






