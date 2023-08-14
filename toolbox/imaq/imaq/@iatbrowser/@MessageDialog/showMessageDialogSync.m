function showMessageDialogSync(~,parentFrame,messageDialogParameterName)













    params=eval(['com.mathworks.toolbox.imaq.browser.dialogs.MessageDialogParameters.',messageDialogParameterName]);
    dialog=com.mathworks.toolbox.imaq.browser.dialogs.SyncMessageDialog(parentFrame,params);

    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(false);
    dialog.show();

end
