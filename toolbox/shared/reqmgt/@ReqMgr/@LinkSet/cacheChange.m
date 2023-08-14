function cacheChange(dlgSrc,dialogH)



    if~isempty(dlgSrc.reqItems)
        desc=dialogH.getWidgetValue('descEdit');
        dlgSrc.reqItems(dlgSrc.reqIdx).description=desc;
        doc=dialogH.getWidgetValue('docEdit');
        dlgSrc.reqItems(dlgSrc.reqIdx).doc=doc;



        if dialogH.isEnabled('locEdit')
            docTypes=rmi.linktype_mgr('all');
            locMark=dialogH.getWidgetValue('locEdit');

            if~isempty(strtrim(locMark))
                docSys=docTypes(dlgSrc.typeItems(dlgSrc.reqIdx));
                dlgSrc.typeIdx=dlgSrc.typeItems(dlgSrc.reqIdx);
                locIdx=dialogH.getWidgetValue('locBookMark')+1;
                if locIdx>0
                    locChar=docSys.LocDelimiters(locIdx);
                else

                    locChar='#';
                end
                dlgSrc.reqItems(dlgSrc.reqIdx).id=[locChar,locMark];
            else
                dlgSrc.reqItems(dlgSrc.reqIdx).id='';
            end
        end

        tagDesc=dialogH.getWidgetValue('tagEdit');
        if~isempty(strtrim(tagDesc))
            dlgSrc.reqItems(dlgSrc.reqIdx).keywords=tagDesc;
        else
            dlgSrc.reqItems(dlgSrc.reqIdx).keywords='';
        end
    end
