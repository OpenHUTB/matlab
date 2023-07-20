function doLocChange(dlgSrc,dialogH)




    if(~isempty(dlgSrc.reqItems))
        docTypes=rmi.linktype_mgr('all');
        typeIdx=dlgSrc.typeItems(dlgSrc.reqIdx);
        docSys=docTypes(typeIdx);

        locMark=dialogH.getWidgetValue('locEdit');
        if~isempty(strtrim(locMark))

            locIdx=dialogH.getWidgetValue('locBookMark')+1;
            locIdx=max([locIdx,1]);
            locChar=docSys.LocDelimiters(locIdx);

            dlgSrc.reqItems(dlgSrc.reqIdx).id=[locChar,locMark];
            if strcmp(dlgSrc.reqItems(dlgSrc.reqIdx).description,getString(message('Slvnv:reqmgt:NoDescriptionEntered')))
                dlgSrc.reqItems(dlgSrc.reqIdx).description=locMark;
                dialogH.refresh();
            end
        else
            dlgSrc.reqItems(dlgSrc.reqIdx).id='';
        end
    end
