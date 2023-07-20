

















function compileMode=getNextProcedureCompileMode(this,firstCall,...
    compIds,currentTimeStamp,...
    normalNoneCompileTasksSelected)



    persistent taskInfo;

    if isempty(taskInfo)||firstCall
        taskInfo=this.getTaskInfoForExecution();


        for n=1:length(taskInfo.procedureTaskCompileInfo)
            taskInfo.procedureTaskCompileInfo{n}.lastIdx=-1;
            taskInfo.procedureTaskCompileInfo{n}.nextIdx=1;
        end
    end



    if firstCall
        modes=Advisor.CompileModes.empty();

        for n=1:length(taskInfo.procedureTaskCompileInfo)
            modes(end+1)=...
            taskInfo.procedureTaskCompileInfo{n}.ModeList(1);%#ok<AGROW>
        end

        if any(modes==Advisor.CompileModes.None)
            compileMode=Advisor.CompileModes.None;
        elseif normalNoneCompileTasksSelected
            compileMode=Advisor.CompileModes.None;
        else


            compileMode=modes.getMostFrequent();
        end

    else



        modes=Advisor.CompileModes.empty();

        for n=1:length(taskInfo.procedureTaskCompileInfo)

            pInfo=taskInfo.procedureTaskCompileInfo{n};








            if pInfo.nextIdx==1

                modes(end+1)=pInfo.ModeList(1);%#ok<AGROW>





            elseif pInfo.nextIdx>1
                for ni=1:length(compIds)

                    lastIndex=pInfo.TaskIdxList{pInfo.lastIdx};

                    maObj=this.getMAObjs(compIds{n});




                    result=maObj{1}.TaskAdvisorCellArray{lastIndex};

                    lastTaskFailed=~result.Check.Success&&...
                    (result.Check.ErrorSeverity==1);

                    lastTaskExecutedWithThisRun=...
                    (result.RunTime==currentTimeStamp);

                    if~lastTaskFailed&&lastTaskExecutedWithThisRun


                        modes(end+1)=pInfo.ModeList(pInfo.nextIdx);%#ok<AGROW>
                        break
                    end

                end
            else

            end
        end


        if~isempty(modes)

            compileMode=modes.getMostFrequent();
        else
            compileMode=[];
        end
    end



    for n=1:length(taskInfo.procedureTaskCompileInfo)

        nextIdx=taskInfo.procedureTaskCompileInfo{n}.nextIdx;



        if taskInfo.procedureTaskCompileInfo{n}.ModeList(nextIdx)==...
compileMode


            if length(taskInfo.procedureTaskCompileInfo{n}.ModeChangeIndices)>1

                taskInfo.procedureTaskCompileInfo{n}.ModeChangeIndices(1)=[];
                nextIdx=taskInfo.procedureTaskCompileInfo{n}.ModeChangeIndices(1);
            else
                nextIdx=[];
            end

            taskInfo.procedureTaskCompileInfo{n}.nextIdx=nextIdx;

            if~isempty(nextIdx)
                taskInfo.procedureTaskCompileInfo{n}.lastIdx=nextIdx-1;
            else
                taskInfo.procedureTaskCompileInfo{n}.lastIdx=[];
            end
        end
    end
end
