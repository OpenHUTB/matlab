function refreshChange(dlgSrc,dialogH)



    cacheChange(dlgSrc,dialogH);
    if(~isempty(dlgSrc.reqItems))
        currentIdx=dialogH.getWidgetValue('lb')+1;
        if(dlgSrc.reqIdx==currentIdx)

            dialogH.refresh();
        end
    end
