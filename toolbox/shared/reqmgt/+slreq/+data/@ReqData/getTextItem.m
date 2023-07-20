function textItem=getTextItem(this,linkSet,id)






    linkSetObj=this.getModelObj(linkSet);
    textItemObj=this.findTextItem(linkSetObj,id);
    if isempty(textItemObj)
        textItem=[];
    else
        textItem=this.wrap(textItemObj);
    end
end
