function applyFilter(this,dlg,varargin)





    this.DialogData.FilterExp=varargin{1};


    if~strcmp(this.DialogData.FilterExp,this.DialogData.OldFilterExp)
        this.DialogData.OldFilterExp=this.DialogData.FilterExp;
        if isempty(this.TimerObj)
            this.TimerObj=timer('TimerFcn',{@refreshResults,this,dlg},...
            'StartDelay',this.DialogData.Delay);
        end
        TimerObj=this.TimerObj;


        if strcmp(TimerObj.Running,'on')
            stop(TimerObj);
        end
        start(TimerObj);
    end

end


function refreshResults(~,~,this,dlg)



    refreshResultsImp(this,dlg);

end
