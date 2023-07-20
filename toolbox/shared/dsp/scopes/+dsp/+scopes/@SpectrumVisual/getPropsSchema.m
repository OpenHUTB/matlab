function propsSchema=getPropsSchema(this,~)




    hCfg=this.Config;
    [title_lbl,title]=uiscopes.getWidgetSchema(hCfg,'Title','edit',1,1);

    legend=uiscopes.getWidgetSchema(hCfg,'Legend','checkbox',2,1);
    grid=uiscopes.getWidgetSchema(hCfg,'Grid','checkbox',2,2);
    if~isSpectrogramMode(this)

        legend.ColSpan=[1,1];
        grid.ColSpan=[2,2];
    end
    [minylim_lbl,minylim]=uiscopes.getWidgetSchema(hCfg,'MinYLim','edit',3,1);
    [maxylim_lbl,maxylim]=uiscopes.getWidgetSchema(hCfg,'MaxYLim','edit',4,1);
    [ylabel_lbl,ylabel]=uiscopes.getWidgetSchema(hCfg,'YLabel','edit',5,1);

    [cm_lbl,cm]=uiscopes.getWidgetSchema(hCfg,'ColorMap','combobox',6,1);
    cm.Entries={'jet(256)','hot(256)','bone(256)','cool(256)','copper(256)','gray(256)','parula(256)'};
    cm.Editable=true;
    [minClim_lbl,minClim]=uiscopes.getWidgetSchema(hCfg,'MinColorLim','edit',7,1);
    [maxClim_lbl,maxClim]=uiscopes.getWidgetSchema(hCfg,'MaxColorLim','edit',8,1);




    [~,viewType]=uiscopes.getWidgetSchema(hCfg,'ViewType','edit',9,1);
    viewType.Visible=false;


    isCCDF=isCCDFMode(this);
    isSpectrogram=isSpectrogramMode(this);
    isSpectrum=~isSpectrogram&&~isCCDF;
    isCombinedView=isCombinedViewMode(this);

    legend.Enabled=isSpectrum||isCombinedView;
    legend.Visible=isSpectrum||isCombinedView;
    minylim.Enabled=isSpectrum||isCombinedView;
    minylim.Visible=isSpectrum||isCombinedView;
    minylim_lbl.Visible=isSpectrum||isCombinedView;
    maxylim.Enabled=isSpectrum||isCombinedView;
    maxylim.Visible=isSpectrum||isCombinedView;
    maxylim_lbl.Visible=isSpectrum||isCombinedView;
    ylabel.Enabled=isSpectrum||isCombinedView;
    ylabel.Visible=isSpectrum||isCombinedView;
    ylabel_lbl.Visible=isSpectrum||isCombinedView;


    cm.Enabled=isSpectrogram||isCombinedView;
    cm.Visible=isSpectrogram||isCombinedView;
    cm_lbl.Visible=isSpectrogram||isCombinedView;
    minClim.Enabled=isSpectrogram||isCombinedView;
    minClim.Visible=isSpectrogram||isCombinedView;
    minClim_lbl.Visible=isSpectrogram||isCombinedView;
    maxClim.Enabled=isSpectrogram||isCombinedView;
    maxClim.Visible=isSpectrogram||isCombinedView;
    maxClim_lbl.Visible=isSpectrogram||isCombinedView;


    propsSchema.Type='group';
    propsSchema.Items={...
    title_lbl,title,...
    legend,...
    grid,...
    minylim_lbl,minylim,...
    maxylim_lbl,maxylim,...
    ylabel_lbl,ylabel,...
    cm_lbl,cm,...
    minClim_lbl,minClim,...
    maxClim_lbl,maxClim,...
    viewType};

    if isCCDF

        propsSchema.LayoutGrid=[2,2];
        propsSchema.RowStretch=[0,1];
    elseif isCombinedView
        propsSchema.LayoutGrid=[8,2];
        propsSchema.RowStretch=[zeros(1,7),1];
    else
        propsSchema.LayoutGrid=[5,2];
        propsSchema.RowStretch=[zeros(1,4),1];
    end
    propsSchema.Name=uiscopes.message('DisplayPropertiesTabLabel');
end
