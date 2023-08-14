function next(obj)




    curTop=obj.NodeStack.top;
    if~isempty(curTop)
        topParent=curTop.Parent;
        if~isempty(topParent)
            nextEv=obj.getUnvisitedChild(topParent);
            obj.NodeStack.pop;
            obj.traverseSpine(nextEv);
        else
            obj.NodeStack.pop;
        end
    end

end
