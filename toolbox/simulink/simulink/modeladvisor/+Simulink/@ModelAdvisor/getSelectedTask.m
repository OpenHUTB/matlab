function[TaskIDArray,TaskSerialNumArray]=getSelectedTask(this)




    TaskIDArray={};
    TaskSerialNumArray={};

    am=Advisor.Manager.getInstance;
    for i=1:length(this.TaskCellarray)
        if this.TaskCellarray{i}.Selected&&~isempty(am.slCustomizationDataStructure.taskCellArray{i}.ChildrenObj)
            TaskIDArray{end+1}=this.TaskCellarray{i}.ID;%#ok<AGROW>
            TaskSerialNumArray{end+1}=i;%#ok<AGROW>
        end
    end
