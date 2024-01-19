function displayPropsGroup=createDisplayPropertiesGroup(this,hDlg)
    [selectedDisplay_lbl,selectedDisplay]=getSelectedDisplayWidgetSchema(this,1,1);
    [title_lbl,title]=getSelectedDisplayPropertyWidgetSchema(this,'Title','edit',2,1);
    legend=getSelectedDisplayPropertyWidgetSchema(this,'Legend','checkbox',3,1);
    grid=getSelectedDisplayPropertyWidgetSchema(this,'Grid','checkbox',3,2);
    plotMagPhase=getSelectedDisplayPropertyWidgetSchema(this,'PlotMagPhase','checkbox',4,1);
    plotMagPhase.DialogRefresh=true;
    [minylim_lbl,minylim]=getSelectedDisplayPropertyWidgetSchema(this,'MinYLimReal','edit',5,1);
    [maxylim_lbl,maxylim]=getSelectedDisplayPropertyWidgetSchema(this,'MaxYLimReal','edit',6,1);
    [ylabel_lbl,ylabel]=getSelectedDisplayPropertyWidgetSchema(this,'YLabelReal','edit',7,1);

    if isa(this.Application.DataSource,'Simulink.scopes.source.WiredSource')
        ytip=getString(message('Spcuilib:scopes:YLabelRealLabelToolTip'));
        ylabel_lbl.ToolTip=ytip;
        ylabel.ToolTip=ytip;
    end
    [minylimmag_lbl,minylimmag]=getSelectedDisplayPropertyWidgetSchema(this,'MinYLimMag','edit',5,1);
    [maxylimmag_lbl,maxylimmag]=getSelectedDisplayPropertyWidgetSchema(this,'MaxYLimMag','edit',6,1);
    val=uiservices.getWidgetValue(plotMagPhase,hDlg);
    minylim_lbl.Visible=~val;
    minylim.Visible=~val;
    maxylim_lbl.Visible=~val;
    maxylim.Visible=~val;
    ylabel_lbl.Visible=~val;
    ylabel.Visible=~val;
    minylimmag_lbl.Visible=val;
    minylimmag.Visible=val;
    maxylimmag_lbl.Visible=val;
    maxylimmag.Visible=val;
    minylim.ObjectMethod='onYLimitChanged';
    maxylim.ObjectMethod='onYLimitChanged';
    minylimmag.ObjectMethod='onYLimitChanged';
    maxylimmag.ObjectMethod='onYLimitChanged';
    displayPropsGroup.Tag='DisplayPropertiesGroup';
    displayPropsGroup.Type='group';
    displayPropsGroup.Items={selectedDisplay_lbl,selectedDisplay,title_lbl,title};
    displayPropsGroup.Items=[displayPropsGroup.Items,{legend}];
    displayPropsGroup.Items=[displayPropsGroup.Items,{grid,plotMagPhase,minylim_lbl,minylim,maxylim_lbl,maxylim,ylabel_lbl,ylabel,minylimmag_lbl,minylimmag,maxylimmag_lbl,maxylimmag}];
    displayPropsGroup.LayoutGrid=[9,2];
    displayPropsGroup.RowStretch=[zeros(1,8),1];

end
