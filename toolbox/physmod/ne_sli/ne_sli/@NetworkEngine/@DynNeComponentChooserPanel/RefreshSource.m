function RefreshSource(hThis,dlg,~,~)





    nesl_getfunctioninfo=nesl_private('nesl_getfunctioninfo');
    info=nesl_getfunctioninfo(hThis.ComponentName);

    nesl_promptifaddpathneeded=nesl_private('nesl_promptifaddpathneeded');
    nesl_promptifaddpathneeded(info);

    dlg.refresh();

end
