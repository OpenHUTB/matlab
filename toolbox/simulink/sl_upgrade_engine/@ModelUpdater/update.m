function[report,cmdLineText]=update(varargin)















































    obj=ModelUpdater(varargin{:});

    restoreBrokenLinks(obj);

    updateModelForProducts(obj);

    w=warning('off','Simulink:Commands:LoadingOlderModel');
    c=onCleanup(@()warning(w));
    [report,cmdLineText]=generateReport(obj);
    delete(c);

    cleanup(obj);

end
