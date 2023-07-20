function refreshCheckList(this)



    cs=this.getConfigSet;
    coder.advisor.internal.selectChecks(this,this.Objectives,cs);

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('HierarchyChangedEvent',this);
