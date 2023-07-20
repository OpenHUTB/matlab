function focusInformerNode(this,nodeObj)
    if iscell(nodeObj)
        nodeObj=this.getTaskObj(nodeObj{1});
    elseif ischar(nodeObj)
        nodeObj=this.getTaskObj(nodeObj);
    end

    nodeObj.updateResultGUI();
end