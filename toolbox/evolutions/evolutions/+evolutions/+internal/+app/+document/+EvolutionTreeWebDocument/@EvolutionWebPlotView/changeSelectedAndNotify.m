function changeSelectedAndNotify(this,newSelectedNode)




    if isempty(newSelectedNode)
        notify(this,'CanvasClicked');
        return;
    end

    this.changeSelected(newSelectedNode);
    evolutionId=newSelectedNode.getAttribute('EvolutionId').value;
    nodeInfo=this.EvolutionIdToInfo(evolutionId);
    evtdata=evolutions.internal.ui.GenericEventData(nodeInfo);
    notify(this,'SelectionChanged',evtdata);
end


