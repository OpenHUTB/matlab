function[profData]=profile_execution_unpack(rawData,profileInfo,ideObj)







































































    lsbFirst=profileInfo.processor.lsbFirst;
    wsize=profileInfo.processor.wordsize;

    version=1;
    oRunMaxSection=1;
    tMaxSection=1;
    logSection=1;

    numTimerTasks=length(rawData.tMax);
    timePerTick=1e-12;

    oRunFlagsMax=double(rawData.oRunMax);

    tMax=rawData.tMax*timePerTick*profileInfo.timer.timePerTickUnits;


    if(logSection==1)

        numPoints=rawData.numPoints;
        taskIds=rawData.loggedData(1:2:end-1);
        taskTicks=rawData.loggedData(2:2:end);



        taskTicks=i_process_timer(taskTicks,wsize,ideObj);


        taskIdList=unique(abs(taskIds));


        numPeriodicTaskProfilingTasks=length(setdiff(taskIdList,profileInfo.tasks.ids));

        numTimerTasks=numPeriodicTaskProfilingTasks;


        numAsyncProfilingTasks=length(taskIdList)-numPeriodicTaskProfilingTasks;

        complete_taskIdList=length(taskIdList)==(numTimerTasks+numAsyncProfilingTasks);
        if(~complete_taskIdList)

            asyncTasks_taskIdList=taskIdList(((length(taskIdList)+1)-numAsyncProfilingTasks):(length(taskIdList)));

            asyncTasks_taskIdList=asyncTasks_taskIdList.';

            periodicTasks_taskIdList=1:double(numTimerTasks);

            periodicTasks_taskIdList=periodicTasks_taskIdList.';

            taskIdList=vertcat(periodicTasks_taskIdList,asyncTasks_taskIdList);
        end






        [taskActivity]=i_task_activity(taskIds,taskIdList,ideObj);
    end

    profData.numTimerTasks=numTimerTasks;
    profData.wsize=wsize;
    if(oRunMaxSection==1)



        profData.oRunMax=oRunFlagsMax;
    end
    if(tMaxSection==1)
        profData.tMax=tMax;
    end
    if(logSection==1)
        profData.taskActivity=taskActivity;
        profData.taskIdList=taskIdList;
        profData.taskTs=taskTicks*timePerTick*profileInfo.timer.timePerTickUnits;
        profData.taskTicks=taskTicks;
        profData.timePerTick=timePerTick*profileInfo.timer.timePerTickUnits;

    end

    profData=profiling_data_warning(profData,complete_taskIdList,ideObj);



    function timerTicks=i_process_timer(timerTicks,wsize,ideObj)




        if length(timerTicks)==1
            timerTicks_diff=0.8;





        else
            timerTicks_diff=diff(timerTicks);
        end




        if sum(sign(timerTicks_diff))<0
            timerTicks_diff=-timerTicks_diff;
        end




        jump_idx=find(timerTicks_diff<0);

        timerTicks_max=2^wsize;

        if~isempty(jump_idx)
            timerTicks_diff(jump_idx)=timerTicks_diff(jump_idx)+timerTicks_max;
        end




        timerTicks=[0;cumsum(timerTicks_diff)'];









        function[taskActivity]=i_task_activity(full_ids,taskIdList,ideObj)

            taskActivity=[];

            ids_idx=zeros(size(full_ids));
            for i=1:length(taskIdList)
                ids_idx((full_ids==taskIdList(i)))=i;
                ids_idx((full_ids==-(taskIdList(i))))=-i;
            end
            if any(ids_idx==0)
                nsampl_prof=length(ids_idx);
                nsampl_coll=nsampl_prof-length(find(ids_idx==0));
                DAStudio.error('ERRORHANDLER:pjtgenerator:ProfilerIncompleteData',nsampl_prof,nsampl_coll);
            end


            stack=zeros(size(taskIdList));
            stack_pointer=0;


            taskActivity=repmat('i',length(ids_idx),length(taskIdList));


            taskActivity(1,:)=repmat('i',1,length(taskIdList));


            taskStates=taskActivity(1,:);

            for i=1:length(ids_idx)
                id=ids_idx(i);
                if id>0

                    taskP=find(taskStates=='e');

                    if~isempty(taskP)
                        stack_pointer=stack_pointer+1;
                        stack(stack_pointer)=taskP;

                        taskStates(taskP)='p';
                    end

                    taskStates(id)='e';
                else

                    taskStates(-id)='i';

                    if(stack_pointer>0)
                        taskP=stack(stack_pointer);
                        stack_pointer=stack_pointer-1;
                        taskStates(taskP)='e';
                    end
                end
                taskActivity(i,:)=taskStates;
            end




            function[profData]=profiling_data_warning(profData,complete_taskIdList,ideObj)

                profData.warning='';


                if(~complete_taskIdList)
                    warning_profData=['There is an insufficient number of data points: the recorded profiling data does not '...
                    ,'contain sufficient information to report on this timer based task. It may be possible to capture data to report on '...
                    ,'this task by increasing the number of data points in the target Options pane of the Configuration Parameters '...
                    ,'which is located under the Code Generation category. '];

                    profData.warning=warning_profData;
                end
