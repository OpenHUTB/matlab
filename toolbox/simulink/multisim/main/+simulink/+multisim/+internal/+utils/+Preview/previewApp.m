function app=previewApp(designPoints)





    import matlab.ui.container.internal.AppContainer;
    import matlab.ui.internal.FigureDocumentGroup;
    import matlab.ui.internal.FigureDocument;


    appOptions.Tag="previewApp";
    appOptions.Title=message("multisim:SetupGUI:PreviewAppTitle").getString();
    appOptions.ToolstripCollapsed=true;
    app=AppContainer(appOptions);


    group=FigureDocumentGroup();
    group.Tag="views";
    app.add(group);


    figOptions.Tag="plot";
    figOptions.Title=message("multisim:SetupGUI:PreviewPlotTitle").getString();
    figOptions.DocumentGroupTag=group.Tag;
    document=FigureDocument(figOptions);
    app.add(document);

    document.Figure.AutoResizeChildren='off';
    simulink.multisim.internal.utils.Preview.plotDesignSpace(designPoints,document.Figure);


    app.Visible=true;
end