function item=getStringFormat(h)



    item=[];










    if ismethod(h,'getExtensionStringFormat')
        item=h.getExtensionStringFormat(item,1);
    end
