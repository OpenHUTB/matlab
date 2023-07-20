function dlgstruct=getDialogSchema(~,~)







    row=1;

    slFileFolderControl=i_FileGenFolderControl();
    slFileFolderControl.RowSpan=[row,row];
    slFileFolderControl.ColSpan=[1,2];
    row=row+1;

    printExportOptions=i_printExportClipboardOptions;
    printExportOptions.RowSpan=[row,row];
    printExportOptions.ColSpan=[1,2];
    row=row+1;

    blankSpace.Type='text';
    blankSpace.Name=' ';
    blankSpace.RowSpan=[row,row];
    blankSpace.ColSpan=[1,2];
    row=row+1;

    callbackTracing.Type='checkbox';
    callbackTracing.Name=DAStudio.message('Simulink:prefs:CallbackTracing');
    callbackTracing.ToolTip=...
    DAStudio.message('Simulink:prefs:CallbackTracingToolTip');
    callbackTracing.Tag='CallbackTracing';
    callbackTracing.Value=i_ison(get_param(0,'CallbackTracing'));
    callbackTracing.RowSpan=[row,row];
    callbackTracing.ColSpan=[1,2];
    row=row+1;

    openSampleTimeLegend.Type='checkbox';
    openSampleTimeLegend.Name=DAStudio.message('Simulink:prefs:OpenLegendWhenChangingSampleTimeDisplay');
    openSampleTimeLegend.ToolTip=...
    DAStudio.message('Simulink:prefs:OpenLegendWhenChangingSampleTimeDisplayToolTip');
    openSampleTimeLegend.Tag='OpenLegendWhenChangingSampleTimeDisplay';
    openSampleTimeLegend.Value=i_ison(get_param(0,'OpenLegendWhenChangingSampleTimeDisplay'));
    openSampleTimeLegend.RowSpan=[row,row];
    openSampleTimeLegend.ColSpan=[1,2];
    row=row+1;

    assert(row==6);

    dlgstruct.DialogTitle=DAStudio.message('Simulink:prefs:GeneralPrefsTitle');

    dlgstruct.LayoutGrid=[6,2];
    dlgstruct.RowStretch=[0,0,0,0,0,1];
    dlgstruct.Items={slFileFolderControl,...
    printExportOptions,...
    callbackTracing,...
    openSampleTimeLegend,...
    blankSpace};

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={'mapkey:Simulink.GeneralPrefs','help_button','CSHelpWindow'};

    dlgstruct.PostApplyMethod='dlgCallback';
    dlgstruct.PostApplyArgs={'%dialog'};
    dlgstruct.PostApplyArgsDT={'handle'};


    function slFileFolderControl=i_FileGenFolderControl

        cacheFolderName=DAStudio.message('Simulink:slbuild:CacheFolderLbl');
        cacheFolderTT=DAStudio.message('Simulink:slbuild:CacheFolderToolTip');
        codeGenFolderName=DAStudio.message('Simulink:slbuild:CodeGenFolderLbl');
        codeGenFolderTT=DAStudio.message('Simulink:slbuild:CodeGenFolderToolTip');
        codeGenFolderStructureName=DAStudio.message('Simulink:slbuild:CodeGenFolderStructureLbl');
        codeGenFolderStructureTT=DAStudio.message('Simulink:slbuild:CodeGenFolderStructureToolTip');
        fileGenFolderOpts=DAStudio.message('Simulink:slbuild:FileGenFolderOptions');
        cacheBrowseTxt=DAStudio.message('Simulink:slbuild:BrowseButtonText');

        ObjectProperty='CacheFolder';
        cacheFolderLbl.Name=cacheFolderName;
        cacheFolderLbl.Type='text';
        cacheFolderLbl.ToolTip=cacheFolderTT;
        cacheFolderLbl.RowSpan=[1,1];
        cacheFolderLbl.ColSpan=[1,1];
        cacheFolderLbl.Buddy=ObjectProperty;

        cacheFolder.Type='edit';
        cacheFolder.Value=get_param(0,'CacheFolder');
        cacheFolder.ToolTip=cacheFolderLbl.ToolTip;
        cacheFolder.Tag=ObjectProperty;
        cacheFolder.Visible=1;
        cacheFolder.Enabled=true;
        cacheFolder.DialogRefresh=0;
        cacheFolder.Mode=1;
        cacheFolder.RowSpan=[1,1];
        cacheFolder.ColSpan=[2,2];

        cacheBrowse.Name=cacheBrowseTxt;
        cacheBrowse.Type='pushbutton';
        cacheBrowse.Tag=[ObjectProperty,'Browse'];
        cacheBrowse.WidgetId=[ObjectProperty,'Browse'];
        cacheBrowse.ObjectMethod='fileGenControlCallback';
        cacheBrowse.MethodArgs={'%dialog',cacheBrowse.Tag};
        cacheBrowse.ArgDataTypes={'handle','string'};
        cacheBrowse.Enabled=true;
        cacheBrowse.Mode=1;
        cacheBrowse.DialogRefresh=0;
        cacheBrowse.RowSpan=[1,1];
        cacheBrowse.ColSpan=[3,3];


        ObjectProperty='CodeGenFolder';
        codeGenFolderLbl.Name=codeGenFolderName;
        codeGenFolderLbl.Type='text';
        codeGenFolderLbl.ToolTip=codeGenFolderTT;
        codeGenFolderLbl.RowSpan=[2,2];
        codeGenFolderLbl.ColSpan=[1,1];
        codeGenFolderLbl.Buddy=ObjectProperty;

        codeGenFolder.Type='edit';
        codeGenFolder.Value=get_param(0,'CodeGenFolder');
        codeGenFolder.ToolTip=codeGenFolderLbl.ToolTip;
        codeGenFolder.Tag=ObjectProperty;
        codeGenFolder.Visible=1;
        codeGenFolder.Enabled=true;
        codeGenFolder.DialogRefresh=0;
        codeGenFolder.Mode=1;
        codeGenFolder.RowSpan=[2,2];
        codeGenFolder.ColSpan=[2,2];

        codeGenBrowse.Name=cacheBrowseTxt;
        codeGenBrowse.Type='pushbutton';
        codeGenBrowse.Tag=[ObjectProperty,'Browse'];
        codeGenBrowse.WidgetId=[ObjectProperty,'Browse'];
        codeGenBrowse.ObjectMethod='fileGenControlCallback';
        codeGenBrowse.MethodArgs={'%dialog',codeGenBrowse.Tag};
        codeGenBrowse.ArgDataTypes={'handle','string'};
        codeGenBrowse.Enabled=true;
        codeGenBrowse.Mode=1;
        codeGenBrowse.DialogRefresh=0;
        codeGenBrowse.RowSpan=[2,2];
        codeGenBrowse.ColSpan=[3,3];

        ObjectProperty='CodeGenFolderStructure';
        codeGenFolderStructureLbl.Name=codeGenFolderStructureName;
        codeGenFolderStructureLbl.Type='text';
        codeGenFolderStructureLbl.ToolTip=codeGenFolderStructureTT;
        codeGenFolderStructureLbl.RowSpan=[3,3];
        codeGenFolderStructureLbl.ColSpan=[1,1];
        codeGenFolderStructureLbl.Buddy=ObjectProperty;

        folderStructure=Simulink.filegen.CodeGenFolderStructure.fromString(get_param(0,'CodeGenFolderStructure'));
        codeGenFolderStructure.Type='combobox';
        codeGenFolderStructure.Value=folderStructure.DisplayString;
        codeGenFolderStructure.Entries=Simulink.filegen.CodeGenFolderStructure.getEnumMemberDisplayList();
        codeGenFolderStructure.ToolTip=codeGenFolderStructureLbl.ToolTip;
        codeGenFolderStructure.Tag=ObjectProperty;
        codeGenFolderStructure.Visible=1;
        codeGenFolderStructure.Enabled=true;
        codeGenFolderStructure.DialogRefresh=0;
        codeGenFolderStructure.Mode=1;
        codeGenFolderStructure.RowSpan=[3,3];
        codeGenFolderStructure.ColSpan=[2,2];

        slFileFolderControl.Type='group';
        slFileFolderControl.Name=fileGenFolderOpts;
        slFileFolderControl.Visible=1;
        slFileFolderControl.Enabled=true;

        slFileFolderControl.LayoutGrid=[3,3];

        slFileFolderControl.ColStretch=[0,1,0];

        slFileFolderControl.Items={cacheFolderLbl,cacheFolder,cacheBrowse...
        ,codeGenFolderLbl,codeGenFolder,codeGenBrowse...
        ,codeGenFolderStructureLbl,codeGenFolderStructure};


        function printExportClipboardOptions=i_printExportClipboardOptions


            printBackgroundLabel.Type='text';
            printBackgroundLabel.Buddy='PrintBackgroundColorMode';
            printBackgroundLabel.Name=DAStudio.message('Simulink:prefs:PrintBackgroundColorModePrompt');
            printBackgroundLabel.ToolTip=DAStudio.message('Simulink:prefs:PrintBackgroundColorModeToolTip');
            printBackgroundLabel.RowSpan=[1,1];
            printBackgroundLabel.ColSpan=[1,1];

            printBackground.Type='combobox';
            printBackground.Entries={
            DAStudio.message('Simulink:prefs:PrintBackgroundColorMatchCanvas')
            DAStudio.message('Simulink:prefs:PrintBackgroundColorWhite')};
            printBackground.Tag='PrintBackgroundColorMode';
            printBackground.Value=DAStudio.message(['Simulink:prefs:PrintBackgroundColor'...
            ,get_param(0,'PrintBackgroundColorMode')]);
            printBackground.RowSpan=[1,1];
            printBackground.ColSpan=[2,2];


            exportBackgroundLabel.Type='text';
            exportBackgroundLabel.Buddy='ExportBackgroundColorMode';
            exportBackgroundLabel.Name=DAStudio.message('Simulink:prefs:ExportBackgroundColorModePrompt');
            exportBackgroundLabel.ToolTip=DAStudio.message('Simulink:prefs:ExportBackgroundColorModeToolTip');
            exportBackgroundLabel.RowSpan=[2,2];
            exportBackgroundLabel.ColSpan=[1,1];

            exportBackground.Type='combobox';
            exportBackground.Entries={
            DAStudio.message('Simulink:prefs:ExportBackgroundColorMatchCanvas')
            DAStudio.message('Simulink:prefs:ExportBackgroundColorWhite')
            DAStudio.message('Simulink:prefs:ExportBackgroundColorTransparent')};
            exportBackground.Tag='ExportBackgroundColorMode';
            exportBackground.Value=DAStudio.message(['Simulink:prefs:ExportBackgroundColor'...
            ,get_param(0,'ExportBackgroundColorMode')]);
            exportBackground.RowSpan=[2,2];
            exportBackground.ColSpan=[2,2];


            clipboardBackgroundLabel.Type='text';
            clipboardBackgroundLabel.Buddy='ClipboardBackgroundColorMode';
            clipboardBackgroundLabel.Name=DAStudio.message('Simulink:prefs:ClipboardBackgroundColorModePrompt');
            clipboardBackgroundLabel.ToolTip=DAStudio.message('Simulink:prefs:ClipboardBackgroundColorModeToolTip');
            clipboardBackgroundLabel.RowSpan=[3,3];
            clipboardBackgroundLabel.ColSpan=[1,1];

            clipboardBackground.Type='combobox';
            clipboardBackground.Entries={
            DAStudio.message('Simulink:prefs:ClipboardBackgroundColorMatchCanvas')
            DAStudio.message('Simulink:prefs:ClipboardBackgroundColorWhite')
            DAStudio.message('Simulink:prefs:ClipboardBackgroundColorTransparent')};
            clipboardBackground.Tag='ClipboardBackgroundColorMode';
            clipboardBackground.Value=DAStudio.message(['Simulink:prefs:ClipboardBackgroundColor'...
            ,get_param(0,'ClipboardBackgroundColorMode')]);
            clipboardBackground.RowSpan=[3,3];
            clipboardBackground.ColSpan=[2,2];

            printExportClipboardOptions.Type='group';
            printExportClipboardOptions.LayoutGrid=[3,2];
            printExportClipboardOptions.ColStretch=[0,1];
            printExportClipboardOptions.Name=DAStudio.message('Simulink:prefs:PrintExportClipboardOptions');
            printExportClipboardOptions.Items={
            printBackgroundLabel,printBackground,...
            exportBackgroundLabel,exportBackground,...
            clipboardBackgroundLabel,clipboardBackground};


            function b=i_ison(s)

                b=strcmp(s,'on');
                assert(b||strcmp(s,'off'));


