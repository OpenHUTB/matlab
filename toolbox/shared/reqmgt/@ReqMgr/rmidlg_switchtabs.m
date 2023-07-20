function rmidlg_switchtabs(dlgH,tag,tabIndex)%#ok<INUSL>




    h=dlgH.getDialogSource();
    h.tabIndex=tabIndex;
    h.switchTab=tabIndex;
    if tabIndex==1
        if~isempty(h.reqItems)
            if~isempty(h.reqItems(h.reqIdx).doc)&&~strcmp(h.reqItems(h.reqIdx).doc,' ')

                h.updateContents(dlgH,false);
            end
        end
    end
