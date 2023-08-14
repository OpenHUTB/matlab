function url=registerDiagViewer(modelName)







    import slvariants.internal.manager.ui.config.VMgrConstants;

    url='';%#ok<NASGU> 

    diagMdlName=[VMgrConstants.DiagMdlNamePrefix,modelName];


    slmsgviewer.RegisterDockedObserver(diagMdlName,diagMdlName);

    urls=slmsgviewer.GetUrl(diagMdlName);
    url=urls{1};

    url=[url,'&modelName=',diagMdlName];

end


