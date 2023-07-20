function out=serializeNode(this,NodeObj)
    if isempty(NodeObj)
        out=[];
        return
    end
    out=this.serializeSingleNode(NodeObj);
    if isa(NodeObj,'ModelAdvisor.Group')
        for i=1:numel(NodeObj.ChildrenObj)
            if isempty(NodeObj.ChildrenObj{i}.ParentObj)
                NodeObj.ChildrenObj{i}.ParentObj=NodeObj;
            end
            out=[out,this.serializeSingleNode(NodeObj.ChildrenObj{i})];
        end
    end
end
