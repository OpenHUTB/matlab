function deselectNode(this,nodeId)
    taskObj=this.maObj.getTaskObj(nodeId);
    taskObj.deselect();
    taskObj.Selected=false;
    window=Advisor.UIService.getInstance.getWindowById('ModelAdvisor',this.windowId);
    window.publishToUI('Advisor::DeselectNode',struct('id',nodeId));
end