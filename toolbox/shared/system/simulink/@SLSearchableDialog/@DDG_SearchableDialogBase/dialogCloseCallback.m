function dialogCloseCallback(this,dlg)






    TimerObj=this.TimerObj;
    if~isempty(TimerObj)
        if strcmp(TimerObj.Running,'on')
            stop(TimerObj);
        end
        delete(TimerObj);
    end


    this.closeCallback(dlg);
