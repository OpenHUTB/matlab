function schema=getReportOutputOptionsSchema(dlgsrc,name)%#ok<INUSD>






    tag_prefix='rtw_';

    cbOutputFormat.Type='combobox';

    if coder.report.internal.slcoderPublishCode.hasWordApp
        cbOutputFormat.Entries={dlgsrc.bxlate('BaseOutputFormatWord'),...
        dlgsrc.bxlate('BaseOutputFormatPDF')
        };
        cbOutputFormat.Values=[1,2];
    else
        cbOutputFormat.Entries={dlgsrc.bxlate('BaseOutputFormatWord')};
        cbOutputFormat.Values=1;
    end
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


    templateFile.Type='edit';
    templateFile.RowSpan=[2,2];
    templateFile.ColSpan=[2,2];
    templateFile.ObjectProperty='templateFile';
    templateFile.Tag=[tag_prefix,'TemplateFile'];
    templateFile.ToolTip=dlgsrc.bxlate('RTWTemplateFileTip');

    templateFileLbl.Type='text';
    templateFileLbl.Name=dlgsrc.bxlate('RTWTemplateFileLbl');
    templateFileLbl.RowSpan=[2,2];
    templateFileLbl.ColSpan=[1,1];
    templateFileLbl.Tag=[templateFile.Tag,'Label'];
    templateFileLbl.Buddy=templateFile.Tag;


    btnBrowseTemplateFile.Type='pushbutton';
    btnBrowseTemplateFile.Name=dlgsrc.bxlate('RTWButtonLblBrowseFile');
    btnBrowseTemplateFile.RowSpan=[2,2];
    btnBrowseTemplateFile.ColSpan=[3,3];
    btnBrowseTemplateFile.ObjectMethod='browseTemplateFile';
    btnBrowseTemplateFile.MethodArgs={'%dialog',templateFile.Tag};
    btnBrowseTemplateFile.ArgDataTypes={'handle','string'};
    btnBrowseTemplateFile.Tag=[tag_prefix,'BrowseTemplateFileButton'];
    btnBrowseTemplateFile.ToolTip=dlgsrc.bxlate('RTWTemplateFileTip');



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
    btnBrowseOutputDir.Name=dlgsrc.bxlate('RTWButtonLblBrowseFile');
    btnBrowseOutputDir.RowSpan=[4,4];
    btnBrowseOutputDir.ColSpan=[3,3];
    btnBrowseOutputDir.ObjectMethod='browseOutputDir';
    btnBrowseOutputDir.MethodArgs={'%dialog',editOutputDir.Tag};
    btnBrowseOutputDir.ArgDataTypes={'handle','string'};
    btnBrowseOutputDir.Tag=[tag_prefix,'BrowseOutputDirButton'];
    btnBrowseOutputDir.ToolTip=dlgsrc.bxlate('BaseButtonTipBrowseOutputDir');
    btnBrowseTemplateFile.ToolTip=dlgsrc.bxlate('RTWTemplateFileTip');


    grpOutputOptions.Type='group';
    grpOutputOptions.Tag=[tag_prefix,'OutputOptionsGroup'];
    grpOutputOptions.Name=dlgsrc.bxlate('RTWWidgetLblRptOutputOptions');
    grpOutputOptions.LayoutGrid=[1,4];
    grpOutputOptions.Items={cbOutputFormatLbl,cbOutputFormat,templateFileLbl,...
    templateFile,btnBrowseTemplateFile,...
    editOutputNameLbl,editOutputName,editOutputDirLbl,editOutputDir,...
    btnBrowseOutputDir};

    pnlOutputOptions.Type='panel';
    pnlOutputOptions.Tag=[tag_prefix,'OutputOptionsPanel'];
    pnlOutputOptions.Items={grpOutputOptions};

    schema=pnlOutputOptions;

end


