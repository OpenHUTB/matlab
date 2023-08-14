function refresh(csr)




    if csr.IsDialogCache=="on"
        try
            csr.getConfigSetSource.refresh;

            csr.getConfigSetSource.refresh('LocalConfigSet');
        catch
        end
    end
    try
        csr.refresh;

        csr.refresh('LocalConfigSet');
    catch
    end
    configset.internal.util.refreshHTMLView(csr);
