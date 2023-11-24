function result=showOptionDialogWithAdditionalMessageSync(~,parentFrame,optionDialogParameterName,messageToAppend)

    params=eval(['com.mathworks.toolbox.imaq.browser.dialogs.OptionDialogParameters.',optionDialogParameterName]);
    dialog=com.mathworks.toolbox.imaq.browser.dialogs.SyncOptionDialog(parentFrame,params,messageToAppend);

    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(false);
    result=dialog.show();

end
