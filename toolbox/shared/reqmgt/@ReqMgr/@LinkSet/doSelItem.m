function doSelItem(dlgSrc,dialogH)



    if(~isempty(dlgSrc.reqItems))
        cacheChange(dlgSrc,dialogH);
        idx=dialogH.getWidgetValue('lb');
        if isempty(idx)
            return;
        end
        dlgSrc.reqIdx=idx+1;
    end
    dlgSrc.docContents={};
    dlgSrc.refreshDiag(dialogH);
end
