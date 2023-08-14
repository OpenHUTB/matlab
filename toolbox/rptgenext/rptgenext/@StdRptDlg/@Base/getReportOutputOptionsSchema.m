function schema=getReportOutputOptionsSchema(dlgsrc,name)%#ok<INUSD>






    tag_prefix=getTagPrefix();


    cbOutputFormat.Type='combobox';

    cbOutputFormat.Entries={
    dlgsrc.bxlate('BaseOutputFormatPDF'),...
    dlgsrc.bxlate('BaseOutputFormatHTML'),...
    dlgsrc.bxlate('BaseOutputFormatWord'),...
    dlgsrc.bxlate('BaseOutputFormatRTF'),...
    dlgsrc.bxlate('BaseOutputFormatDOM_DOCX'),...
    dlgsrc.bxlate('BaseOutputFormatDOM_HTMLFile'),...
    dlgsrc.bxlate('BaseOutputFormatDOM_HTMX'),...
    dlgsrc.bxlate('BaseOutputFormatDOM_PDF'),...
    dlgsrc.bxlate('BaseOutputFormatDOM_DirectPDF'),...
    };
    cbOutputFormat.Values=[1,2,3,4,5,6,7,8,9];
    pos_dom_htmx=7;

    cbOutputFormat.ObjectProperty='outputFormat';
    cbOutputFormat.Mode=true;
    cbOutputFormat.DialogRefresh=true;
    cbOutputFormat.RowSpan=[1,1];
    cbOutputFormat.ColSpan=[2,3];
    cbOutputFormat.Tag=[tag_prefix,'OutputFormat'];
    cbOutputFormat.ToolTip=dlgsrc.bxlate('BaseWidgetTipOutputFormat');


    cbOutputFormatLbl.Type='text';
    cbOutputFormatLbl.Name=dlgsrc.bxlate('BaseWidgetLblOutputFormat');
    cbOutputFormatLbl.RowSpan=[1,1];
    cbOutputFormatLbl.ColSpan=[1,1];
    cbOutputFormatLbl.Tag=[cbOutputFormat.Tag,'Label'];
    cbOutputFormatLbl.Buddy=cbOutputFormat.Tag;


    cbStylesheet.Type='combobox';
    cbStylesheet.ObjectProperty='stylesheetIndex';
    cbStylesheet.Mode=true;
    cbStylesheet.Tag=[tag_prefix,'Stylesheet'];
    cbStylesheet.ToolTip=dlgsrc.bxlate('BaseWidgetTipTemplate');
    [ids,names,values]=StdRpt.getStylesheetList(dlgsrc.outputFormat);
    cbStylesheet.Entries=names;
    cbStylesheet.Values=values;
    dlgsrc.StylesheetIDs=ids;
    cbStylesheet.RowSpan=[2,2];
    cbStylesheet.ColSpan=[2,3];


    if dlgsrc.stylesheetIndex>length(ids)
        dlgsrc.stylesheetIndex=1;
    end















    cbStylesheetLbl.Type='text';
    if dlgsrc.outputFormat<5
        cbStylesheetLbl.Name=dlgsrc.bxlate('BaseWidgetLblStylesheet');
    else
        cbStylesheetLbl.Name=dlgsrc.bxlate('BaseWidgetLblTemplate');
    end
    cbStylesheetLbl.RowSpan=[2,2];
    cbStylesheetLbl.ColSpan=[1,1];
    cbStylesheetLbl.Tag=[cbStylesheet.Tag,'Label'];
    cbStylesheetLbl.Buddy=cbStylesheet.Tag;











    editOutputName.Type='edit';
    editOutputName.RowSpan=[3,3];
    editOutputName.ColSpan=[2,3];
    editOutputName.ObjectProperty='outputName';
    editOutputName.Tag=[tag_prefix,'OutputName'];
    editOutputName.ToolTip=dlgsrc.bxlate('BaseWidgetTipOutputName');


    editOutputNameLbl.Type='text';
    editOutputNameLbl.Name=dlgsrc.bxlate('BaseWidgetLblOutputName');
    editOutputNameLbl.RowSpan=[3,3];
    editOutputNameLbl.ColSpan=[1,1];
    editOutputNameLbl.Tag=[editOutputName.Tag,'Label'];
    editOutputNameLbl.Buddy=editOutputName.Tag;


    editOutputDir.Type='edit';
    editOutputDir.RowSpan=[4,4];
    editOutputDir.ColSpan=[2,2];
    editOutputDir.ObjectProperty='outputDir';
    editOutputDir.Tag=[tag_prefix,'OutputDir'];
    editOutputDir.ToolTip=dlgsrc.bxlate('BaseWidgetTipOutputDir');


    editOutputDirLbl.Type='text';
    editOutputDirLbl.Name=dlgsrc.bxlate('BaseWidgetLblOutputDir');
    editOutputDirLbl.RowSpan=[4,4];
    editOutputDirLbl.ColSpan=[1,1];
    editOutputDirLbl.Tag=[editOutputDir.Tag,'Label'];
    editOutputDirLbl.Buddy=editOutputDir.Tag;


    btnBrowseOutputDir.Type='pushbutton';
    btnBrowseOutputDir.Name=dlgsrc.bxlate('BaseButtonLblBrowseOutputDir');
    btnBrowseOutputDir.RowSpan=[4,4];
    btnBrowseOutputDir.ColSpan=[3,3];
    btnBrowseOutputDir.ObjectMethod='browseOutputDir';
    btnBrowseOutputDir.MethodArgs={'%dialog',editOutputDir.Tag};
    btnBrowseOutputDir.ArgDataTypes={'handle','string'};
    btnBrowseOutputDir.Tag=[tag_prefix,'BrowseOutputDirButton'];
    btnBrowseOutputDir.ToolTip=dlgsrc.bxlate('BaseButtonTipBrowseOutputDir');


    chkIncrOutputName.Type='checkbox';
    chkIncrOutputName.Name=dlgsrc.bxlate('BaseWidgetLblIncrOutputName');
    chkIncrOutputName.RowSpan=[5,5];
    chkIncrOutputName.ColSpan=[1,3];
    chkIncrOutputName.ObjectProperty='incrOutputName';
    chkIncrOutputName.Tag=[tag_prefix,'IncrOutputName'];
    chkIncrOutputName.ToolTip=dlgsrc.bxlate('BaseWidgetTipIncrOutputName');


    grpOutputOptions.Type='group';
    grpOutputOptions.Tag=[tag_prefix,'OutputOptionsGroup'];
    grpOutputOptions.Name=dlgsrc.bxlate('BaseWidgetLblRptOutputOptions');
    grpOutputOptions.LayoutGrid=[5,3];

    grpOutputOptions.Items={...
    cbOutputFormatLbl,...
    cbOutputFormat,...
    cbStylesheetLbl,...
    cbStylesheet,...
    editOutputNameLbl,...
    editOutputName,...
    editOutputDirLbl,...
    editOutputDir,...
    btnBrowseOutputDir,...
chkIncrOutputName...
    };


    lastRow=grpOutputOptions.LayoutGrid(1)+1;
    grpPackageType=getPackageTypeSchema();
    grpPackageType.ColSpan=[1,3];
    grpPackageType.RowSpan=[lastRow,lastRow];
    grpPackageType.Enabled=dlgsrc.outputFormat==pos_dom_htmx;

    grpOutputOptions.Items=[grpOutputOptions.Items,{grpPackageType}];

    grpOutputOptions.LayoutGrid(1)=lastRow;

    pnlOutputOptions.Type='panel';
    pnlOutputOptions.Tag=[tag_prefix,'OutputOptionsPanel'];
    pnlOutputOptions.Items={grpOutputOptions};

    schema=pnlOutputOptions;


    function schema=getPackageTypeSchema()


        schema.Type='radiobutton';
        schema.ObjectProperty='packageType';
        schema.Name=tr('PackagingTypeGroupLabel');
        schema.Tag=prefixTag('PackagingTypeGroup');
        schema.ToolTip=tr('PackagingTypeGroupToolTip');
        schema.OrientHorizontal=true;
        schema.Mode=true;
        schema.DialogRefresh=true;
        schema.Entries={...
        tr('PackagingTypeZippedLabel'),...
        tr('PackagingTypeUnzippedLabel'),...
        tr('PackagingTypeBothLabel')...
        };
        schema.Values=[1,2,3];


        function msg=tr(msgid,varargin)
            msg=getString(message(['rptgen:rx_db_output:',msgid],varargin{:}));


            function prefix=getTagPrefix()
                prefix='sdd_';


                function prefixedTag=prefixTag(tag)
                    prefixedTag=[getTagPrefix(),tag];



