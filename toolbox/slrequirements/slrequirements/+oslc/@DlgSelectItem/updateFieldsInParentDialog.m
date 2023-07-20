function[status,msg]=updateFieldsInParentDialog(parentDlgH,reqstruct)






    try
        dlgSrc=parentDlgH.getSource();
        parentDlgH.setWidgetValue('docEdit',reqstruct.doc);
        dlgSrc.changeDocItem(parentDlgH);
        parentDlgH.setWidgetValue('locEdit',reqstruct.id);
        dlgSrc.doLocChange(parentDlgH);
        parentDlgH.setWidgetValue('descEdit',reqstruct.description);
        dlgSrc.changeDescItem(parentDlgH);
        status=true;
        msg='';
    catch ex
        status=false;
        msg=ex.message;
    end
end
