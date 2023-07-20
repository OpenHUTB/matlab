function[view_num,view_obj]=getCurrentViewObject(cs,~,~)





    view_num=2;
    dlg=cs.getDialogHandle;
    if isempty(dlg)
        cs.view;
        dlg=cs.getDialogHandle;
    else
        dlg.showNormal;
    end
    view_obj=dlg.getDialogSource;

