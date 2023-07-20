function startLabelEditing(leg,peer)












    item=findEntry(leg,peer);
    if~isempty(item)&&isvalid(item)
        hText=item.Label.TextComp;
        if~isempty(hText)&&isvalid(hText)
            doMethod(leg,'start_textitem_edit',hText);
        end
    end


end