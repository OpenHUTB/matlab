function sysObjNodeCloneHelper(this,other)
    otherNode=other.GraphNode;
    if~isempty(otherNode)&&isvalid(otherNode)
        dataflow.internal.allocateNode(this);
        sysObjCloneHelper(this.GraphNode,otherNode);
    end
end
