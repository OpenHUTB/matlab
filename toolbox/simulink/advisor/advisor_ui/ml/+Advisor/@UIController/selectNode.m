function selectNode(this,nodeId)
    taskObj=this.maObj.getTaskObj(nodeId);
    taskObj.select();
    taskObj.Selected=true;
    this.currentTreeSelection=taskObj;
    window=Advisor.UIService.getInstance.getWindowById('ModelAdvisor',this.windowId);
    window.publishToUI('Advisor::SelectNode',struct('id',nodeId));
end