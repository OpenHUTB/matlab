classdef TreeInterface<handle



    properties
    end

    methods(Abstract)
        node=getRoot(obj)
        index=getIndex(obj,node)
        node=getNodeByIndex(obj,index)
        val=isLeaf(obj,node)
        val=isChildOfParent(obj,node,parentNode)
        children=getChildren(obj,node)
        children=getChildrenReverse(obj,node)
        child=getFirstChild(obj,node)
        child=getLastChild(obj,node)
        parent=getParent(obj,node)
        height=getNodeHeight(obj,node)
        width=getNodeWidth(obj,node)
    end

end

