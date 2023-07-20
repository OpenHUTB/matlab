function changedsldvconfigtab(hDlg,tag,index)




    if isequal(tag,'Tag_ConfigSet_SLDV_tabs')
        hSrc=getDialogSource(hDlg);
        set(hSrc,[hSrc.productTag,'ActiveTab'],index);

        if hSrc.isActive
            hMdl=hSrc.getModel;
            hSrc=getActiveConfigSet(hMdl);
            set(hSrc,'ActiveTab',index);
        end
    end
