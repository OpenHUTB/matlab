function generatedFilterRadioButtonCB(userdata,cbinfo)
    vm=slreq.app.MainManager.getInstance.viewManager;

    switch userdata
    case 'noop'
    case '__internal_invoke_editor__'
        slreq.toolstrip.editFilter('edit');
    case '__internal_save__'
        dlg=slreq.internal.gui.saveFilterView();
        DAStudio.Dialog(dlg);
    case '__internal_save_all__'
        vm.saveViews();
    case '__internal_new_view__'
        slreq.toolstrip.editFilter('new');
    otherwise

        idx=str2double(userdata);
        if~isnan(idx)
            vm.setCurrentViewByIdx(idx);
        end
    end

end
