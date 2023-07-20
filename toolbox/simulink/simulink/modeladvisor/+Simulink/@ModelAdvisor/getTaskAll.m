function TaskIDArray=getTaskAll(this)




    TaskIDArray={};

    for i=1:length(this.TaskCellarray)
        TaskIDArray{end+1}=this.TaskCellarray{i}.ID;%#ok<AGROW>
    end
