function changeDescItem(dlgSrc,dialogH)




    desc=dialogH.getWidgetValue('descEdit');
    if~isempty(dlgSrc.reqItems)
        dlgSrc.reqItems(dlgSrc.reqIdx).description=rmiut.filterChars(desc,false);
    end
    currentIdx=dialogH.getWidgetValue('lb')+1;
    if dlgSrc.reqIdx==currentIdx
        dialogH.refresh();
    end
