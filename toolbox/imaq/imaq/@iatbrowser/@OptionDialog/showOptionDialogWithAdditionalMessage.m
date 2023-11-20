function showOptionDialogWithAdditionalMessage(this,parentFrame,optionDialogParameterName,messageToAppend,userData,varargin)

    if isa(userData,'function_handle')
        error(message('imaq:imaqtool:dialogBadUserData','showOptionDialog'))
    end
    params=eval(['com.mathworks.toolbox.imaq.browser.dialogs.OptionDialogParameters.',optionDialogParameterName]);
    dialog=com.mathworks.toolbox.imaq.browser.dialogs.OptionDialog(parentFrame,params,userData,messageToAppend);

    delete(this.listeners);

    for ii=1:nargin-5
        cb=handle(dialog.getCallbackForOption(ii-1));
        if ii==1
            this.listeners=handle.listener(cb,'delayed',varargin{ii});
        else
            this.listeners(ii)=handle.listener(cb,'delayed',varargin{ii});
        end
    end

    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(false);
    dialog.show();

end
