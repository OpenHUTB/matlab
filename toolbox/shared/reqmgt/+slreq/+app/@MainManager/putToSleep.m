function putToSleep(this)





    this.notify('SleepUI');

    if~isempty(this.reqRoot)
        this.reqRoot.reqDataChangeListener.Enabled=false;
    end
end

