function success=selectTaskAll(this)




    success=false;

    selectCount=0;
    for j=1:length(this.TaskCellarray)

        if this.updateTask(j,true)
            selectCount=selectCount+1;
        end
    end

    if selectCount==length(this.TaskCellarray)
        success=true;
    end
