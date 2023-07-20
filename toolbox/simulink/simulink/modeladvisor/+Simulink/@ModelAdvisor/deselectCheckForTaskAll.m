function success=deselectCheckForTaskAll(this)




    success=false;

    selectCount=0;
    for j=1:length(this.CheckCellarray)

        if this.updateCheckForTask(j,false)
            selectCount=selectCount+1;
        end
    end

    if selectCount==length(this.CheckCellarray)
        success=true;
    end
