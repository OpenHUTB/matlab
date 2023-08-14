function child=getUnvisitedChild(obj,ei)




    child=[];
    for idx=1:numel(ei.Children)
        curChild=ei.Children(idx);
        if~obj.VisitedNodes.isKey(curChild.Id)
            child=curChild;
            break;
        end
    end
end
