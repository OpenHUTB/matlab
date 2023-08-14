function doCopyItem(dlgSrc,dialogH)



    userData=dlgSrc.dialogUD;
    if dlgSrc.reqIdx>0&&dlgSrc.reqIdx<=length(dlgSrc.reqItems)
        idx=length(dlgSrc.reqItems)+1;
        dlgSrc.reqItems(idx)=dlgSrc.reqItems(dlgSrc.reqIdx);
        dlgSrc.reqItems(idx).description=['Copy of ',dlgSrc.reqItems(idx).description];
        dlgSrc.typeItems(idx)=dlgSrc.typeItems(dlgSrc.reqIdx);
        dlgSrc.reqIdx=idx;
        dialogH.enableApplyButton(true);
    end
    dialogH.refresh();
