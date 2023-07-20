function setEditorEnabled(this,state)







    e=this.Editor;
    if isa(e,'DAStudio.Explorer')
        ed=DAStudio.EventDispatcher;
        e.setDispatcherEvents({'MESleep','MEWake'});

        if strcmpi(state,'on')
            ed.broadcastEvent('MEWake');
            this.resetDispatcherEvents();
        else
            ed.broadcastEvent('MESleep');
        end
    end

