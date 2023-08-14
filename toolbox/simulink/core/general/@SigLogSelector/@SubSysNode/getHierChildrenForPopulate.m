function children=getHierChildrenForPopulate(h)





    children=h.daobject.getHierarchicalChildren;
    children=SigLogSelector.filter(children);

end
