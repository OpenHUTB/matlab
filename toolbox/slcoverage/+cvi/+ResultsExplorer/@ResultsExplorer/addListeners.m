function addListeners(obj)






    ed=DAStudio.EventDispatcher;
    obj.hierarchyChangedListener=handle.listener(ed,'HierarchyChangedEvent',...
    @(s,e)cvi.ResultsExplorer.ResultsExplorer.hierarchyChangedCallback(s,e,obj));
