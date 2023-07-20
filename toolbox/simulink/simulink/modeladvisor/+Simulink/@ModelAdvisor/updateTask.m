function success=updateTask(this,serialNumber,newSatus)





    success=false;


    if newSatus
        if this.TaskCellarray{serialNumber}.Selected||(this.TaskCellarray{serialNumber}.Enable&&this.TaskCellarray{serialNumber}.Visible)
            this.TaskCellarray{serialNumber}.Selected=true;
            success=true;
        else
            success=false;
        end
    else
        if~this.TaskCellarray{serialNumber}.Selected||(this.TaskCellarray{serialNumber}.Enable&&this.TaskCellarray{serialNumber}.Visible)
            this.TaskCellarray{serialNumber}.Selected=false;
            success=true;
        else
            success=false;
        end
    end
