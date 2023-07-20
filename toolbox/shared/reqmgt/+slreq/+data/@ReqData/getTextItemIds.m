function textItemIds=getTextItemIds(this,linkSet)






    linkSetObj=this.getModelObj(linkSet);
    textItems=linkSetObj.textItems.toArray;
    textItemIds=cell(1,length(textItems));
    for i=1:length(textItems)
        textItemIds{i}=textItems(i).id;
    end
end
