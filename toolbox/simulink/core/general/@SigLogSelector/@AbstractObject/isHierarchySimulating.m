function ret=isHierarchySimulating(h)




    if h.isLoaded&&h.isValid
        ret=h.daobject.isHierarchySimulating;
    else
        ret=false;
    end

end
