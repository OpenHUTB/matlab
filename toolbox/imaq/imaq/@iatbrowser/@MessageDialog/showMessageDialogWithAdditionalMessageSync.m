function showMessageDialogWithAdditionalMessageSync(~,parentFrame,messageDialogParameterName,messageToAppend,userData,cbFcn)

















    params=eval(['com.mathworks.toolbox.imaq.browser.dialogs.MessageDialogParameters.',messageDialogParameterName]);
    dialog=com.mathworks.toolbox.imaq.browser.dialogs.SyncMessageDialog(parentFrame,params,messageToAppend);

    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(false);
    dialog.show();

end
