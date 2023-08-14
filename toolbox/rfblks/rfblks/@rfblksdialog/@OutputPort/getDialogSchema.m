function dlgStruct=getDialogSchema(this,dummy)










    create_new_dialog=rfblksis_dialog_open(this);


    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;
    middle=9;



    zl=rfblksGetLeafWidgetBase('edit','','Zl',this,'Zl');
    zl.RowSpan=[1,1];
    zl.ColSpan=[lwidget,rwidget];

    zlprompt=rfblksGetLeafWidgetBase('text','Load impedance (ohms):',...
    'ZlPrompt',0);
    zlprompt.RowSpan=[1,1];
    zlprompt.ColSpan=[lprompt,rprompt];

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[2,2];
    spacerMain.ColSpan=[lprompt,rprompt];



    Udata=this.Block.UserData;
    if isfield(Udata,'Plot')&&Udata.Plot&&...
        isfield(Udata,'System')&&isa(Udata.System,'rfbbequiv.system')&&...
        isa(Udata.System.OriginalCkt,'rfckt.cascade')&&...
        numel(Udata.System.OriginalCkt.Ckts)>=1
        VisEnabled=true;
    else
        VisEnabled=false;
    end

    if VisEnabled

        Udata=this.Block.UserData;
        if strcmpi(get_param(bdroot,'BlockDiagramType'),'library')
            mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
        else
            try
                myckt=analyze(Udata.System.OriginalCkt,100e9,...
                Udata.System.OriginalCkt.AnalyzedResult.ZL,...
                Udata.System.OriginalCkt.AnalyzedResult.ZS,...
                Udata.System.OriginalCkt.AnalyzedResult.Z0);
                mydata=myckt.AnalyzedResult;
            catch
                mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
            end
        end

        [visItems,visLayout]=rfblkscreate_vis_pane(this,mydata,...
        create_new_dialog,{},'rfblksplotparam');

    else

        if isfield(Udata,'System')&&isa(Udata.System,'rfbbequiv.system')&&...
            isa(Udata.System.OriginalCkt,'rfckt.cascade')&&...
            numel(Udata.System.OriginalCkt.Ckts)<1
            temptxt=['Visualization is only available when there is at least one block',...
            sprintf('\n'),'between the Input Port block and the Output Port block.'];
        elseif isfield(Udata,'Plot')&&~Udata.Plot
            temptxt=sprintf(['The blocks between this block and the corresponding Input Port block have been modified',...
            '\nsince last model update. Run a simulation or click Update Diagram to enable visualization.']);
        else
            temptxt=['Visualization is only available after you run a simulation or',...
            sprintf('\n'),'click Update Diagram to initialize the model.'];
        end

        visTitle=rfblksGetLeafWidgetBase('text',temptxt,'VisTitle',0);
        visTitle.RowSpan=[1,1];
        visTitle.ColSpan=[1,middle];

        spacerVisualization=rfblksGetLeafWidgetBase('text','','',0);
        spacerVisualization.RowSpan=[2,2];
        spacerVisualization.ColSpan=[lprompt,rprompt];

    end




    mainPane=rfblksGetContainerWidgetBase('panel','','MainPane');
    mainPane.Items={zl,zlprompt,spacerMain};
    mainPane.LayoutGrid=[2,number_grid];
    mainPane.RowSpan=[1,1];
    mainPane.ColSpan=[1,1];
    mainPane.RowStretch=[0,1];


    if VisEnabled
        visualizationPane=rfblkscreate_panel(this,'VisualizationPane',visItems,visLayout);
    else
        visualizationPane=rfblksGetContainerWidgetBase('panel','','VisualizationPane');
        visualizationPane.Items={visTitle,spacerVisualization};
        visualizationPane.LayoutGrid=[2,number_grid];
        visualizationPane.RowStretch=[0,1];
        visualizationPane.RowSpan=[1,1];
        visualizationPane.ColSpan=[1,1];
    end



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


