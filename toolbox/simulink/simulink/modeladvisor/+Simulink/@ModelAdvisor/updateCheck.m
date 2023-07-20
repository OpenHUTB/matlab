function success=updateCheck(this,serialNumber,newSatus,varargin)





    success=false;


    if serialNumber<0
        return
    end
    speedCheckCell=[];
    if nargin>3

        speedCheckCell=varargin{1};
    end






    if isempty(speedCheckCell)||iscell(speedCheckCell.Group)

        if this.FastCheckAccessTable(serialNumber)
            speedCheckCell=this.TaskAdvisorCellArray{this.FastCheckAccessTable(serialNumber)}.Check;
        else
            speedCheckCell=this.CheckCellarray{serialNumber};
        end
    end

    if newSatus
        if speedCheckCell.Selected||(speedCheckCell.Enable&&speedCheckCell.Visible)
            speedCheckCell.Selected=true;
            success=true;
        else
            success=false;
        end
    else
        if~speedCheckCell.Selected||(speedCheckCell.Enable&&speedCheckCell.Visible)
            speedCheckCell.Selected=false;
            success=true;
        else
            success=false;
        end
    end
