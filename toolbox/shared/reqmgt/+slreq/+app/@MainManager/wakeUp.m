function wakeUp(this)








    if~isempty(this.reqRoot)
        reqSetCount=this.reqRoot.ensureDasTrees();
        if reqSetCount>0
            this.linkRoot.ensureDasTrees();
        end
    end


    if~isempty(this.reqRoot)
        this.reqRoot.reqDataChangeListener.Enabled=true;
    end
    this.notify('WakeUI');

end

