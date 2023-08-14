function traverseSpine(obj,ei)




    while~isempty(ei)
        obj.NodeStack.push(ei);
        obj.VisitedNodes(ei.Id)=true;
        ei=obj.getUnvisitedChild(ei);
    end
end
