




























function[orderedCheckIndex,orderedTaskIndex,orderedCheckIndexCGIR,orderedCheckIndexSLDV]=getExecutionOrder(this,rerunTaskID,rerunMode,fromTaskAdvisorNode)


    execorder=struct();


    if rerunMode&&isa(fromTaskAdvisorNode,'ModelAdvisor.Node')
        for i=1:length(rerunTaskID)


            if isnumeric(rerunTaskID{i})&&rerunTaskID{i}>0&&rerunTaskID{i}<=length(this.TaskAdvisorCellArray)
                rerunTaskIndex=rerunTaskID{i};
            else
                DAStudio.error('ModelAdvisor:engine:InvalidTaskIndex');
            end

            if isa(this.TaskAdvisorCellArray{rerunTaskIndex},'ModelAdvisor.Task')&&...
                this.TaskAdvisorCellArray{rerunTaskIndex}.MACIndex~=0
                rerunCheckIndex=this.TaskAdvisorCellArray{rerunTaskIndex}.MACIndex;
                checkObj=this.TaskAdvisorCellArray{rerunTaskIndex}.Check;
            else
                DAStudio.error('Simulink:tools:MAInvalidCheckID');
            end

            if rerunCheckIndex>0

                rerunEnabled=checkObj.Selected||...
                (checkObj.Enable&&checkObj.Visible);
            else
                rerunEnabled=false;
            end


            if rerunEnabled
                execorder=setExecOrder(execorder,checkObj.CallbackContext,rerunCheckIndex,rerunTaskIndex);
            end
        end

    elseif rerunMode
        for i=1:length(rerunTaskID)
            if isnumeric(rerunTaskID{i})&&rerunTaskID{i}>0&&rerunTaskID{i}<=length(this.CheckCellArray)
                rerunCheckIndex=rerunTaskID{i};

            elseif ischar(rerunTaskID{i})

                if this.CheckIDMap.isKey(rerunTaskID{i})
                    rerunCheckIndex=this.CheckIDMap(rerunTaskID{i});
                else
                    newID=ModelAdvisor.convertCheckID(rerunTaskID{i});
                    if~isempty(newID)
                        modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',rerunTaskID{i},newID);
                        rerunTaskID{i}=newID;
                        if this.CheckIDMap.isKey(rerunTaskID{i})
                            rerunCheckIndex=this.CheckIDMap(rerunTaskID{i});
                        end
                    else
                        DAStudio.error('ModelAdvisor:engine:CmdAPINotValidCheckID',rerunTaskID{i});
                    end
                end
            end


            checkObj=this.CheckCellArray{rerunCheckIndex};
            rerunEnabled=checkObj.Selected||...
            (checkObj.Enable&&checkObj.Visible);

            if rerunEnabled
                execorder=setExecOrder(execorder,checkObj.CallbackContext,rerunCheckIndex,[]);
            end
        end

    else

        for recordCounter=1:length(this.CheckCellArray)

            if this.FastCheckAccessTable(recordCounter)

                CurrentCheckObj=this.TaskAdvisorCellArray{this.FastCheckAccessTable(recordCounter)}.Check;
            else
                CurrentCheckObj=this.CheckCellArray{recordCounter};
            end

            if this.StartInTaskPage
                currentCheckSelected=CurrentCheckObj.SelectedByTask;
            else
                currentCheckSelected=CurrentCheckObj.Selected;
            end

            if currentCheckSelected
                execorder=setExecOrder(execorder,CurrentCheckObj.CallbackContext,recordCounter,[]);
            end

        end
    end







    [orderedCheckIndexNone,orderedTaskIndexNone]=getIndices(execorder,'None');
    [orderedCheckIndexDIY,orderedTaskIndexDIY]=getIndices(execorder,'DIY');
    [orderedCheckIndexCompile,orderedTaskIndexCompile]=getIndices(execorder,'PostCompile');
    [orderedCheckIndexCGIR,orderedTaskIndexCGIR]=getIndices(execorder,'CGIR');
    [orderedCheckIndexCoverage,orderedTaskIndexCoverage]=getIndices(execorder,'Coverage');
    [orderedCheckIndexCompileForCodegen,orderedTaskIndexCompileForCodegen]=getIndices(execorder,'PostCompileForCodegen');
    [orderedCheckIndexSLDV,orderedTaskIndexSLDV]=getIndices(execorder,'SLDV');




    orderedCheckIndex=[orderedCheckIndexNone,orderedCheckIndexDIY,...
    orderedCheckIndexCompile,orderedCheckIndexCGIR,...
    orderedCheckIndexCoverage,orderedCheckIndexCompileForCodegen,orderedCheckIndexSLDV];

    orderedTaskIndex=[orderedTaskIndexNone,orderedTaskIndexDIY,...
    orderedTaskIndexCompile,orderedTaskIndexCGIR,...
    orderedTaskIndexCoverage,orderedTaskIndexCompileForCodegen,orderedTaskIndexSLDV];
end

function execorder=setExecOrder(execorder,CompileMode,rerunCheckIndex,rerunTaskIndex)

    if~isfield(execorder,CompileMode)
        execorder.(CompileMode)=struct('checkIdxs',[],'taskIdxs',[]);
    end

    execorder.(CompileMode).checkIdxs{end+1}=rerunCheckIndex;
    if~isempty(rerunTaskIndex)
        execorder.(CompileMode).taskIdxs{end+1}=rerunTaskIndex;
    end

end

function[checkIndices,taskIndices]=getIndices(execorder,CompileMode)
    if isfield(execorder,CompileMode)
        checkIndices=execorder.(CompileMode).checkIdxs;
        taskIndices=execorder.(CompileMode).taskIdxs;
    else
        checkIndices=[];
        taskIndices=[];
    end
end