function populate(h)






    if isa(h,'SigLogSelector.MdlRefNode')
        return;
    end


    children=getHierChildrenForPopulate(h);


    for idx=1:length(children)


        subsys=children(idx);
        child=h.addChild(subsys);


        if~ischar(subsys)
            populate(child);
        end

    end

end
