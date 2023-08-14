function success=runTask(this)




    success=false;

    this.deselectCheckForTaskAll;

    this.StartInTaskPage=true;


    for i=1:length(this.TaskCellArray)
        if this.TaskCellArray{i}.Selected
            for j=1:length(this.TaskCellArray{i}.CheckIndex)
                recordSerialNum=str2double(this.TaskCellArray{i}.CheckIndex{j});
                this.updateCheckForTask(recordSerialNum,true);
            end
        end
    end

    this.run(true);

    success=true;


