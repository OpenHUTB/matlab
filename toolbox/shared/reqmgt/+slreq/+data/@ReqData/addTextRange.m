function textRange=addTextRange(this,textItem,id,range)






    textItemObj=this.getModelObj(textItem);
    linkset=textItemObj.artifact;
    itemObj=this.addRangeItem(linkset,textItemObj,id,range);
    textRange=this.wrap(itemObj);

    this.wrap(textItemObj);
end
