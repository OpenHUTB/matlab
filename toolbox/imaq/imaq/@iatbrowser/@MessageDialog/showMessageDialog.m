function showMessageDialog(this,parentFrame,messageDialogParameterName,userData,cbFcn)



















    if isa(userData,'function_handle')
        error(message('imaq:imaqtool:dialogBadUserData','showMessageDialog'));
    end

    params=eval(['com.mathworks.toolbox.imaq.browser.dialogs.MessageDialogParameters.',messageDialogParameterName]);
    dialog=com.mathworks.toolbox.imaq.browser.dialogs.MessageDialog(parentFrame,params,userData);

    cb=handle(dialog.getCallback());
    this.listener=handle.listener(cb,'delayed',@callback);

    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(false);
    dialog.show();

    function callback(obj,event)
        if~isempty(cbFcn)
            cbFcn(obj,event);
        end
        delete(this.listener);
        this.listener=[];
    end

end
