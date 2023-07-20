
function hardwareFormatNodeAddedCallback(this,deviceNode,eventdata)










    formatNode=eventdata.FormatNode;

    javaTree=java(this.javaTreePeer);
    treeModel=javaTree.getModel();
    treeModel.insertNodeInto(eventdata.FormatNode.JavaPeer,deviceNode.JavaPeer,...
    length(deviceNode.getChildren())-2);
    drawnow;
    this.selectNode(formatNode,true);
