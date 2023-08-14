function dlgStruct=getDialogSchema(this,dummy)











    create_new_dialog=rfblksis_dialog_open(this);


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;


    res=rfblksGetLeafWidgetBase('edit','','R',this,'R');
    res.RowSpan=[1,1];
    res.ColSpan=[lwidget,rwidget];

    resprompt=rfblksGetLeafWidgetBase('text','Resistance (ohms):',...
    'ResPrompt',0);
    resprompt.RowSpan=[1,1];
    resprompt.ColSpan=[lprompt,rprompt];

    ind=rfblksGetLeafWidgetBase('edit','','L',this,'L');
    ind.RowSpan=[2,2];
    ind.ColSpan=[lwidget,rwidget];

    indprompt=rfblksGetLeafWidgetBase('text','Inductance (H):',...
    'IndPrompt',0);
    indprompt.RowSpan=[2,2];
    indprompt.ColSpan=[lprompt,rprompt];

    cap=rfblksGetLeafWidgetBase('edit','','C',this,'C');
    cap.RowSpan=[3,3];
    cap.ColSpan=[lwidget,rwidget];

    capprompt=rfblksGetLeafWidgetBase('text','Capacitance (F):',...
    'CapPrompt',0);
    capprompt.RowSpan=[3,3];
    capprompt.ColSpan=[lprompt,rprompt];

    if any(strcmp(this.Block.MaskType,{'Shunt R','Series R'}))
        res.Visible=1;
        ind.Visible=0;
        cap.Visible=0;
    elseif any(strcmp(this.Block.MaskType,{'Shunt L','Series L'}))
        res.Visible=0;
        res.RowSpan=[2,2];
        ind.Visible=1;
        ind.RowSpan=[1,1];
        cap.Visible=0;
    elseif any(strcmp(this.Block.MaskType,{'Shunt C','Series C'}))
        res.Visible=0;
        res.RowSpan=[3,3];
        ind.Visible=0;
        cap.Visible=1;
        cap.RowSpan=[1,1];
    else
        res.Visible=1;
        ind.Visible=1;
        cap.Visible=1;
    end
    resprompt.Visible=res.Visible;
    resprompt.RowSpan=res.RowSpan;
    indprompt.Visible=ind.Visible;
    indprompt.RowSpan=ind.RowSpan;
    capprompt.Visible=cap.Visible;
    capprompt.RowSpan=cap.RowSpan;

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[4,4];
    spacerMain.ColSpan=[lprompt,rprompt];


    [mydata,sourcefreq_entry]=rfblksget_vis_data(this);

    [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
    create_new_dialog,sourcefreq_entry,'rfblksplotparam');



    mainPane=rfblksGetContainerWidgetBase('panel','','MainPane');
    mainPane.Items={res,resprompt,ind,indprompt,cap,capprompt,...
    spacerMain};
    mainPane.LayoutGrid=[4,number_grid];
    mainPane.RowSpan=[1,1];
    mainPane.ColSpan=[1,1];
    mainPane.RowStretch=[zeros(1,3),1];


    visualizationPane=rfblkscreate_panel(this,'VisualizationPane',visItems,visLayout);



    mainTab.Name='Main';
    mainTab.Items={mainPane};
    mainTab.LayoutGrid=[1,1];
    mainTab.RowStretch=0;
    mainTab.ColStretch=0;


    visualizationTab.Name='Visualization';
    visualizationTab.Items={visualizationPane};
    visualizationTab.LayoutGrid=[1,1];
    visualizationTab.RowStretch=0;
    visualizationTab.ColStretch=0;


    tabbedPane=rfblksGetContainerWidgetBase('tab','','TabPane');
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];
    tabbedPane.Tabs={mainTab,visualizationTab};


    dlgStruct=this.getBaseSchemaStruct(tabbedPane);

