function doUpItem(dlgSrc,dialogH)



    userData=dlgSrc.dialogUD;
    if dlgSrc.reqIdx>1
        prevItem=dlgSrc.reqItems(dlgSrc.reqIdx-1);
        dlgSrc.reqItems(dlgSrc.reqIdx-1)=dlgSrc.reqItems(dlgSrc.reqIdx);
        dlgSrc.reqItems(dlgSrc.reqIdx)=prevItem;
        prevItem=dlgSrc.typeItems(dlgSrc.reqIdx-1);
        dlgSrc.typeItems(dlgSrc.reqIdx-1)=dlgSrc.typeItems(dlgSrc.reqIdx);
        dlgSrc.typeItems(dlgSrc.reqIdx)=prevItem;
        dlgSrc.reqIdx=dlgSrc.reqIdx-1;
        dialogH.enableApplyButton(true);
    end
    dialogH.refresh();
