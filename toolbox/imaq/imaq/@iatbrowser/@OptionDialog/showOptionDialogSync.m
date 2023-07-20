function result=showOptionDialogSync(~,parentFrame,optionDialogParameterName)















    params=eval(['com.mathworks.toolbox.imaq.browser.dialogs.OptionDialogParameters.',optionDialogParameterName]);
    dialog=com.mathworks.toolbox.imaq.browser.dialogs.SyncOptionDialog(parentFrame,params);

    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(false);
    result=dialog.show();

end
