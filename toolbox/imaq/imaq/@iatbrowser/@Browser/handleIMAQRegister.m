function handleIMAQRegister(this,obj,event)%#ok<INUSL>

    filename=event.JavaEvent;

    try
        imaqregister(filename);
    catch err
        md=iatbrowser.MessageDialog();
        md.showMessageDialogWithAdditionalMessage(...
        com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.getInstance.getMainFrame,...
        'IMAQREGISTER_FAILED',...
        err.getReport('basic','hyperlinks','off'),...
        [],...
        []);
        drawnow;
        return;
    end

    this.handleRefresh();

end

