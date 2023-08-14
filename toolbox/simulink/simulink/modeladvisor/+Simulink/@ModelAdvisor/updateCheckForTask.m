function success=updateCheckForTask(this,serialNumber,newSatus,varargin)





    if nargin>3

        speedref=varargin{1};
    else

        if this.FastCheckAccessTable(serialNumber)
            speedref=this.TaskAdvisorCellArray{this.FastCheckAccessTable(serialNumber)}.Check;
        else
            speedref=this.CheckCellarray{serialNumber};
        end
    end



    if newSatus
        if speedref.SelectedByTask||(speedref.Enable&&speedref.Visible)
            speedref.SelectedByTask=true;
            success=true;
        else
            success=false;
        end
    else
        if~speedref.SelectedByTask||(speedref.Enable&&speedref.Visible)
            speedref.SelectedByTask=false;
            success=true;
        else
            success=false;
        end
    end
