function children=getChildren(h)





    children=[];


    if h.refModelInvalid
        return;
    end



    me=SigLogSelector.getExplorer;
    if isequal(h,me.unloadingModelRefNode)
        return;
    end


    if h.signalsPopulated
        if~isempty(h.hBdNode)&&ishandle(h.hBdNode)
            children=h.hBdNode.getChildren();
        end
        return;
    end


    if isempty(h.hBdNode)
        h.updateRefModels;
    end


    if~h.hBdNode.isLoaded
        if~h.hBdNode.loadObject()
            h.refModelInvalid=true;
            return;
        end
        h.firePropertyChange;
    end


    children=h.hBdNode.getChildren();
    h.signalsPopulated=true;

end
