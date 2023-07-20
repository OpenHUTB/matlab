function children=getHierarchicalChildren(h)







    children=[];


    if h.refModelInvalid||isempty(h.hBdNode)||~ishandle(h.hBdNode)...
        ||h.hBdNode.isClosing||~h.hBdNode.isLoaded
        return;
    end


    children=h.hBdNode.getHierarchicalChildren;

end
