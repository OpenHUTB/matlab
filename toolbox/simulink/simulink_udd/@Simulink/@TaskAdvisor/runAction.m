function runAction(this)





    if~isempty(this.MAC)
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('MESleep');
        try
            this.MAObj.runAction(this.MACIndex,this);
        catch E
            ed.broadcastEvent('MEWake');
            rethrow(E);
        end
        ed.broadcastEvent('MEWake');
    end
