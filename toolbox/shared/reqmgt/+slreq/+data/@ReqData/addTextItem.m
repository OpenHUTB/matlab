function[textItem,textItemObj]=addTextItem(this,linkset,id,content)






    if isa(linkset,'slreq.data.LinkSet')
        linkset=this.getModelObj(linkset);
    end
    textItemObj=slreq.datamodel.TextItem(this.model);
    textItemObj.id=id;
    textItemObj.content=content;
    linkset.textItems.add(textItemObj);

    textItem=this.wrap(textItemObj);
end
