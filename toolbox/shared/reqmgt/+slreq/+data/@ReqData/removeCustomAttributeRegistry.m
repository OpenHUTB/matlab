function removeCustomAttributeRegistry(this,attrReg)






    if~isa(attrReg,'slreq.datamodel.AttributeRegistry')
        error('Invalid type is specified')
    end

    if~isempty(attrReg.requirementSet)
        dataSet=this.wrap(attrReg.requirementSet);
    else
        dataSet=this.wrap(attrReg.linkSet);
    end

    delItems=attrReg.items.toArray;
    for n=1:length(delItems)
        delItems(n).destroy;
    end

    removedName=attrReg.name;


    attrReg.destroy;


    dataSet.setDirty(true);


    modInfo.removedName=removedName;
    if isa(dataSet,'slreq.data.Requirement')
        this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('CustomAttributeRemoved',modInfo));
    else
        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('CustomAttributeRemoved',modInfo));
    end
end
