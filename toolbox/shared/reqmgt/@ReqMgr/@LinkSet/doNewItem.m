function doNewItem(dlgSrc,dialogH)




    if isempty(dlgSrc.reqItems)
        dlgSrc.reqIdx=1;
        dlgSrc.reqItems=struct('doc','',...
        'id','',...
        'linked',1,...
        'description',getString(message('Slvnv:reqmgt:NoDescriptionEntered')),...
        'keywords','',...
        'reqsys','other'...
        );
    else
        dlgSrc.reqIdx=length(dlgSrc.reqItems)+1;
        reqItems=dlgSrc.reqItems;
        reqItems(dlgSrc.reqIdx).description=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
        reqItems(dlgSrc.reqIdx).reqsys='other';
        reqItems(dlgSrc.reqIdx).doc='';
        reqItems(dlgSrc.reqIdx).id='';
        reqItems(dlgSrc.reqIdx).linked=1;
        reqItems(dlgSrc.reqIdx).keywords='';
        dlgSrc.reqItems=reqItems;
    end
    dlgSrc.typeItems(dlgSrc.reqIdx)=0;
    dialogH.enableApplyButton(true);
    dlgSrc.refreshDiag(dialogH);

