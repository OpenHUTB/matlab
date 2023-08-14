function resetCurrentNode(this)








    if isa(this.currentNode,'iatbrowser.FormatNode')
        currentNode=this.CurrentNode;
        deleteDevice(this.currentNode);
        this.currentNode=[];
        this.selectNode(currentNode,true);
    end