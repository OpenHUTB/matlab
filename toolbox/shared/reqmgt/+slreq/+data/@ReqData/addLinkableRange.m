function rangeItem=addLinkableRange(this,linkSet,srcStruct)






    linkSetObj=this.getModelObj(linkSet);
    item=this.ensureLinkableItem(linkSetObj,srcStruct);
    rangeItem=this.wrap(item);

    dataLinkSet=this.wrap(linkSetObj);
    dataLinkSet.setDirty(true);
    this.wrap(item.textItem);
end
