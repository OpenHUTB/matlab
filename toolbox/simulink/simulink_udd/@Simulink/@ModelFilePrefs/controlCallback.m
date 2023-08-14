function controlCallback(~,dlg)












    v=dlg.getWidgetValue('NotifyUpdating');
    dlg.setEnabled('NotifyAction',v~=0);


