function uuid=removeTextItem(this,textItem)






    if~isa(textItem,'slreq.data.TextItem')||~isvalid(textItem)
        error('Invalid argument: expected slreq.data.textItem');
    end



    allDataRanges=textItem.getRanges;
    for cDataRange=allDataRanges
        allDataLinks=cDataRange.getLinks;
        for cDataLink=allDataLinks

            this.removeLink(cDataLink);
        end

        this.removeTextRange(textItem,cDataRange.id);

    end

    modelTextItem=this.getModelObj(textItem);
    uuid=modelTextItem.UUID;
    modelTextItem.destroy();
end
