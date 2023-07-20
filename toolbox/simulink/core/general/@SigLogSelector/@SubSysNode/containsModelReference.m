function bCheckboxes=containsModelReference(h)








    if isa(h,'SigLogSelector.MdlRefNode')
        bCheckboxes=true;
        return;
    end


    children=h.getHierarchicalChildren;
    for idx=1:length(children)
        if children(idx).containsModelReference
            bCheckboxes=true;
            return;
        end
    end


    bCheckboxes=false;

end
