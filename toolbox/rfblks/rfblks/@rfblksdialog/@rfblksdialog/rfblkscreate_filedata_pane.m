function[items,layout]=rfblkscreate_filedata_pane(this,varargin)






    lprompt=1;
    rprompt=4;
    lwidget=rprompt+1;
    rwidget=18;
    number_grid=20;
    lbutton=19;
    rbutton=number_grid;



    datasource=rfblksGetLeafWidgetBase('combobox','','DataSource',...
    this,'DataSource');
    datasource.Entries=set(this,'DataSource')';
    datasource.RowSpan=[1,1];
    datasource.ColSpan=[lwidget,rwidget];
    datasource.DialogRefresh=1;

    datasourceprompt=rfblksGetLeafWidgetBase('text','Data source:',...
    'DataSourcePrompt',0);
    datasourceprompt.RowSpan=[1,1];
    datasourceprompt.ColSpan=[lprompt,rprompt];


    rfdataObj=rfblksGetLeafWidgetBase('edit','','RFDATA',...
    this,'RFDATA');
    rfdataObj.RowSpan=[3,3];
    rfdataObj.ColSpan=[lwidget+1,rwidget];

    rfdataObjprompt=rfblksGetLeafWidgetBase('text','RFDATA object:',...
    'RFDATAPrompt',0);
    rfdataObjprompt.RowSpan=[3,3];
    rfdataObjprompt.ColSpan=[lprompt+1,rprompt];


    file=rfblksGetLeafWidgetBase('edit','','File',...
    this,'File');
    file.RowSpan=[2,2];
    file.ColSpan=[lwidget+1,rwidget];

    fileprompt=rfblksGetLeafWidgetBase('text','Data file:','FilePrompt',...
    0);
    fileprompt.RowSpan=[2,2];
    fileprompt.ColSpan=[lprompt+1,rprompt];

    browse=rfblksGetLeafWidgetBase('pushbutton','Browse ...','Browse',this);
    browse.RowSpan=[2,2];
    browse.ColSpan=[lbutton,rbutton];
    browse.ObjectMethod='rfblksbrowsefile';
    browse.MethodArgs={'%dialog'};
    browse.ArgDataTypes={'handle'};


    interpMethod=rfblksGetLeafWidgetBase('combobox','',...
    'InterpMethod',this,'InterpMethod');
    interpMethod.Entries=set(this,'InterpMethod')';
    interpMethod.RowSpan=[4,4];
    interpMethod.ColSpan=[lwidget,rwidget];

    interpMethodprompt=rfblksGetLeafWidgetBase('text','Interpolation method:',...
    'InterpMethodPrompt',0);
    interpMethodprompt.RowSpan=[4,4];
    interpMethodprompt.ColSpan=[lprompt,rprompt];

    spacerMain=rfblksGetLeafWidgetBase('text','','',0);
    spacerMain.RowSpan=[5,5];
    spacerMain.ColSpan=[lprompt,rprompt];


    items={datasource,datasourceprompt,rfdataObj,rfdataObjprompt,...
    file,fileprompt,browse,interpMethod,interpMethodprompt,spacerMain};

    layout.LayoutGrid=[5,number_grid];
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];
    layout.RowStretch=[zeros(1,4),1];


