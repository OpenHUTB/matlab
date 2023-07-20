function refreshTree(this)




    if isa(this.MAObj,'Simulink.ModelAdvisor')&&isa(this.MAObj.ConfigUIWindow,'DAStudio.Explorer')
        fptme_WF=this.MAObj.ConfigUIWindow;


        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',fptme_WF.getRoot);
        ed.broadcastEvent('PropertyChangedEvent',fptme_WF.getRoot);


        if~isempty(fptme_WF)
            if~isempty(fptme_WF.getDialog)
                fptme_WF.getDialog.refresh;
            end
        end
    end