function typeSel(dlgSrc,dialogH)



    if~isempty(dlgSrc.reqItems)
        dlgSrc.typeIdx=dialogH.getWidgetValue('typeEdit');
        dlgSrc.typeItems(dlgSrc.reqIdx)=dlgSrc.typeIdx;
        docTypes=rmi.linktype_mgr('all');
        if dlgSrc.typeIdx>0
            dlgSrc.reqItems(dlgSrc.reqIdx).id='';
            docTypeItem=docTypes(dlgSrc.typeIdx);
            dlgSrc.reqItems(dlgSrc.reqIdx).reqsys=docTypeItem.Registration;
            if~isempty(docTypeItem.Extensions)
                docExt=docTypeItem.Extensions(1);
                docExt=['*',docExt{1}];
                for i=2:length(docTypeItem.Extensions)
                    docExt=[docExt,';'];%#ok<*AGROW>
                    docExtNext=docTypeItem.Extensions(i);
                    docExt=[docExt,'*',docExtNext{1}];
                end
                dlgSrc.extensions=docExt;
            else
                dlgSrc.extensions='';
            end
        end

        currentIdx=dialogH.getWidgetValue('lb')+1;
        if dlgSrc.reqIdx==currentIdx
            dlgSrc.refreshDiag(dialogH);
        end
    end
