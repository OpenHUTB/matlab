function updateRefModels(h)






    if strcmpi(h.daobject.ProtectedModel,'on')
        h.hParent.removeProtectedModel(h);
        return;
    end



    refMdl=h.daobject.ModelName;



    bChange=false;
    if~isempty(h.hBdNode)
        if strcmp(refMdl,h.hBdNode.Name)
            return;
        end


        h.hBdNode.unpopulate;
        delete(h.hBdNode);
        h.childNodes.Clear;
        bChange=true;
    end



    h.refModelInvalid=false;
    h.hBdNode=h.addChild(refMdl);


    if bChange
        h.signalsPopulated=false;
        h.fireHierarchyChanged;
    end

end
