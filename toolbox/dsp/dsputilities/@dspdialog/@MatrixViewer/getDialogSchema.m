function dlgStruct=getDialogSchema(this,name)






















    MaxWidgetInTab=9;


    CMapStr=dspGetLeafWidgetBase('edit','Colormap matrix:','CMapStr',this,'CMapStr');
    CMapStr.Entries=set(this,'CMapStr')';
    CMapStr.RowSpan=[1,1];CMapStr.ColSpan=[1,1];
    CMapStr.Visible=1;
    CMapStr.Tunable=1;


    YMin=dspGetLeafWidgetBase('edit','Minimum input value:','YMin',this,'YMin');
    YMin.Entries=set(this,'YMin')';
    YMin.RowSpan=[2,2];YMin.ColSpan=[1,1];
    YMin.Visible=1;
    YMin.Tunable=1;


    YMax=dspGetLeafWidgetBase('edit','Maximum input value:','YMax',this,'YMax');
    YMax.Entries=set(this,'YMax')';
    YMax.RowSpan=[3,3];YMax.ColSpan=[1,1];
    YMax.Visible=1;
    YMax.Tunable=1;


    AxisColorbar=dspGetLeafWidgetBase('checkbox','Display colorbar','AxisColorbar',this,'AxisColorbar');
    AxisColorbar.RowSpan=[4,4];AxisColorbar.ColSpan=[1,1];
    AxisColorbar.Visible=1;
    AxisColorbar.Tunable=1;


    ImPropParameterPane=dspGetContainerWidgetBase('group','Parameters','ImPropParameterPane');
    ImPropParameterPane.Items={CMapStr,YMin,YMax,AxisColorbar};
    ImPropParameterPane.Tag='ImPropParameterPane';
    ImPropParameterPane.LayoutGrid=[MaxWidgetInTab,1];
    ImPropParameterPane.RowStretch=[zeros(1,MaxWidgetInTab-1),1];


    ImagPropTab.Name='Image Properties';
    ImagPropTab.Items={ImPropParameterPane};



    AxisOrigin=dspGetLeafWidgetBase('combobox','Axis origin:','AxisOrigin',this,'AxisOrigin');
    AxisOrigin.Entries={'Upper left corner','Lower left corner'};
    AxisOrigin.RowSpan=[1,1];AxisOrigin.ColSpan=[1,1];
    AxisOrigin.Visible=1;
    AxisOrigin.Tunable=1;


    AxisTickMode=dspGetLeafWidgetBase('combobox','Axis tick mode:','AxisTickMode',this,'AxisTickMode');
    AxisTickMode.Entries={'Auto','User-defined'};
    AxisTickMode.RowSpan=[2,2];AxisTickMode.ColSpan=[1,1];
    AxisTickMode.Visible=1;
    AxisTickMode.Tunable=1;
    AxisTickMode.DialogRefresh=1;


    XTickRange=dspGetLeafWidgetBase('edit','X-tick range:','XTickRange',this,'XTickRange');
    XTickRange.Entries=set(this,'XTickRange')';
    XTickRange.RowSpan=[3,3];XTickRange.ColSpan=[1,1];
    XTickRange.Visible=1;
    XTickRange.Tunable=1;


    YTickRange=dspGetLeafWidgetBase('edit','Y-tick range:','YTickRange',this,'YTickRange');
    YTickRange.Entries=set(this,'YTickRange')';
    YTickRange.RowSpan=[4,4];YTickRange.ColSpan=[1,1];
    YTickRange.Visible=1;
    YTickRange.Tunable=1;


    XLabel=dspGetLeafWidgetBase('edit','X-axis title:','XLabel',this,'XLabel');
    XLabel.Entries=set(this,'XLabel')';
    XLabel.RowSpan=[5,5];XLabel.ColSpan=[1,1];
    XLabel.Visible=1;
    XLabel.Tunable=1;


    YLabel=dspGetLeafWidgetBase('edit','Y-axis title:','YLabel',this,'YLabel');
    YLabel.Entries=set(this,'YLabel')';
    YLabel.RowSpan=[6,6];YLabel.ColSpan=[1,1];
    YLabel.Visible=1;
    YLabel.Tunable=1;


    ZLabel=dspGetLeafWidgetBase('edit','Colorbar title:','ZLabel',this,'ZLabel');
    ZLabel.Entries=set(this,'ZLabel')';
    ZLabel.RowSpan=[7,7];ZLabel.ColSpan=[1,1];
    ZLabel.Visible=1;
    ZLabel.Tunable=1;


    FigPos=dspGetLeafWidgetBase('edit','Figure position, [x y width height]:','FigPos',this,'FigPos');
    FigPos.Entries=set(this,'FigPos')';
    FigPos.RowSpan=[8,8];FigPos.ColSpan=[1,1];
    FigPos.Visible=1;
    FigPos.Tunable=1;


    AxisZoom=dspGetLeafWidgetBase('checkbox','Axis zoom','AxisZoom',this,'AxisZoom');
    AxisZoom.RowSpan=[9,9];AxisZoom.ColSpan=[1,1];
    AxisZoom.Visible=1;
    AxisZoom.Tunable=1;


    if~strcmp(this.AxisTickMode,'User-defined')
        XTickRange.Visible=0;XTickRange.Tunable=0;
        YTickRange.Visible=0;YTickRange.Tunable=0;
    else
        XTickRange.Visible=1;XTickRange.Tunable=1;
        YTickRange.Visible=1;YTickRange.Tunable=1;
    end


    AxPropParameterPane=dspGetContainerWidgetBase('group','Parameters','AxPropParameterPane');
    AxPropParameterPane.Items={AxisOrigin,AxisTickMode,XTickRange,YTickRange,XLabel,YLabel,ZLabel,FigPos,AxisZoom};
    AxPropParameterPane.Tag='AxPropParameterPane';
    AxPropParameterPane.LayoutGrid=[MaxWidgetInTab,1];
    AxPropParameterPane.RowStretch=[zeros(1,MaxWidgetInTab-1),1];


    AxisPropTab.Name='Axis Properties';
    AxisPropTab.Items={AxPropParameterPane};


    tabbedPane=dspGetContainerWidgetBase('tab','','tabPane');
    tabbedPane.Tabs={ImagPropTab,AxisPropTab};
    tabbedPane.RowSpan=[2,2];
    tabbedPane.ColSpan=[1,1];

    dlgStruct=this.getBaseSchemaStruct(tabbedPane);
    idx=findstr(this.Block.Name,sprintf('\n'));
    blkName=this.Block.Name;
    blkName(idx)=' ';
    dlgStruct.DialogTitle=['Sink Block Parameters: ',blkName];


