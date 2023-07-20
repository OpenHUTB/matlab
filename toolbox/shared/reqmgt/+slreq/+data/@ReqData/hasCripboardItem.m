function[tf,isJustification]=hasCripboardItem(this)






    clipboard=this.getClipboardReqSet();
    tf=false;
    isJustification=false;

    if~isempty(clipboard)
        itemsArray=clipboard.items.toArray();
        tf=length(itemsArray)>0;
        if tf
            isJustification=isa(itemsArray(1),'slreq.datamodel.Justification');
        end
    end
end
