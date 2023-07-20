function tf=isAncestorOf(parentArg,childArg)







    tf=false;
    rData=slreq.data.ReqData.getInstance();
    if ischar(parentArg)
        asParent=rData.model.findElement(parentArg);
    else
        asParent=rData.getModelObj(parentArg);
    end
    if isempty(asParent)
        return;
    end
    if ischar(childArg)
        asChild=rData.model.findElement(childArg);
    else
        asChild=rData.getModelObj(childArg);
    end
    if isempty(asChild)
        return;
    end
    tf=rData.isHierarchicalParent(asParent,asChild);
end
