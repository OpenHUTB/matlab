function refreshDialog(dlg)





    assert(isa(dlg,'DAStudio.Dialog'));
    controller=dlg.getDialogSource;
    if isa(controller,'configset.dialog.HTMLView')
        controller.Source.resetAdapter();
        if isa(controller.Source.Source,'Simulink.ConfigSetRef')

            dlg.refresh;
        end
    end
