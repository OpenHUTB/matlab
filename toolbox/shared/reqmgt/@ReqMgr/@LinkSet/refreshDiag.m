function refreshDiag(dlgSrc,dialogH)







    applyButtonWasEnabled=dialogH.hasUnappliedChanges;
    modified=false;


    if isempty(dlgSrc.reqItems)||isempty(dlgSrc.reqItems(dlgSrc.reqIdx).doc)
        dialogH.setWidgetValue('docEdit','');
        modified=true;
    end

    if~isempty(dlgSrc.reqItems)
        [locEditValue,~,~]=getBookMarkEntries(dlgSrc);
        if isempty(locEditValue)
            dialogH.setWidgetValue('locEdit','');
            modified=true;
        end
    end


    if modified&&~applyButtonWasEnabled
        dialogH.enableApplyButton(false);
    end


    dialogH.refresh();
