

function out=isCustomAttributeRegistryInUse(this,attrReg)

    out=false;

    attrItems=attrReg.items.toArray();
    for i=1:length(attrItems)
        attrItem=attrItems(i);
        reqItem=attrItem.requirementItem;
        if isa(reqItem,'slreq.datamodel.ExternalRequirement')
            out=true;
            break;
        end
    end

end

