function dlgSelectElementIncludeListItemAction(this,dlg,itemIdx)





    if isempty(itemIdx)
        return
    end

    this.CurrIncludeElementIdx=itemIdx;

    dlg.refresh();
    dlg.apply;


