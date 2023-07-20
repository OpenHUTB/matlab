function focusNode(this,nodeId)
    taskObj=this.maObj.getTaskObj(nodeId);
    this.currentTreeSelection=taskObj;
    window=Advisor.UIService.getInstance.getWindowById('ModelAdvisor',this.windowId);
    window.publishToUI('Advisor::FocusNode',struct('id',nodeId));
end