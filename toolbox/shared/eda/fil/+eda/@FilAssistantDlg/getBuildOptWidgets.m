function WidgetGroup=getBuildOptWidgets(this)




    OutputFolder.Type='edit';
    OutputFolder.Tag='edaOutputFolder';
    OutputFolder.Name=this.getCatalogMsgStr('OutputFolder_Edit');
    OutputFolder.RowSpan=[1,1];
    OutputFolder.ColSpan=[1,9];
    OutputFolder.ObjectProperty='OutputFolder';
    OutputFolder.ObjectMethod='onChangeOutputFolder';
    OutputFolder.MethodArgs={'%dialog'};
    OutputFolder.ArgDataTypes={'handle'};
    OutputFolder.Mode=1;



    if(~this.HasChangedOutputFolder)
        this.OutputFolder=this.BuildInfo.OutputFolder;
    end

    BrowseBtn.Type='pushbutton';
    BrowseBtn.Tag='edaBrowseOutputFolderBtn';
    BrowseBtn.Name=this.getCatalogMsgStr('Browse_Button');
    BrowseBtn.ObjectMethod='onBrowseOutputFolder';
    BrowseBtn.MethodArgs={'%dialog'};
    BrowseBtn.ArgDataTypes={'handle'};
    BrowseBtn.RowSpan=[1,1];
    BrowseBtn.ColSpan=[10,10];

    TopLevelSourceFileTxt.Type='text';
    TopLevelSourceFileTxt.Tag='edaTopLevelSourceFileTxt';
    TopLevelSourceFileTxt.Name=this.getCatalogMsgStr('TopLevelSourceFile_Text');
    TopLevelSourceFileTxt.RowSpan=[1,1];
    TopLevelSourceFileTxt.ColSpan=[1,20];

    TopLevelSourceFileInfo.Type='text';
    TopLevelSourceFileInfo.Tag='edaTopLevelSourceFileInfo';
    TopLevelSourceFileInfo.Name=this.BuildInfo.TopLevelSourceFile;
    TopLevelSourceFileInfo.RowSpan=[2,2];
    TopLevelSourceFileInfo.ColSpan=[2,20];

    GeneratedFileTxt.Type='text';
    GeneratedFileTxt.Tag='edaGeneratedFileInfo';
    GeneratedFileTxt.Name=this.getCatalogMsgStr('GeneratedFile_Text');
    GeneratedFileTxt.RowSpan=[3,3];
    GeneratedFileTxt.ColSpan=[1,20];

    FpgaProjectFileTxt.Type='text';
    FpgaProjectFileTxt.Tag='edaFpgaProjectFileTxt';
    FpgaProjectFileTxt.Name=this.getCatalogMsgStr('FpgaProjectFile_Text');
    FpgaProjectFileTxt.RowSpan=[4,4];
    FpgaProjectFileTxt.ColSpan=[2,2];

    FileProjectFileInfo.Type='text';
    FileProjectFileInfo.Tag='edaFileProjectFileInfo';
    FileProjectFileInfo.Name=this.BuildInfo.FPGAProjectFile;
    FileProjectFileInfo.RowSpan=[4,4];
    FileProjectFileInfo.ColSpan=[3,20];

    FpgaProgramFileTxt.Type='text';
    FpgaProgramFileTxt.Tag='edaFpgaProgramFileTxt';
    FpgaProgramFileTxt.Name=this.getCatalogMsgStr('FpgaProgramFile_Text');
    FpgaProgramFileTxt.RowSpan=[5,5];
    FpgaProgramFileTxt.ColSpan=[2,2];

    FpgaProgramFileInfo.Type='text';
    FpgaProgramFileInfo.Tag='edaFpgaProgramFileInfo';
    FpgaProgramFileInfo.Name=this.BuildInfo.FPGAProgrammingFile;
    FpgaProgramFileInfo.RowSpan=[5,5];
    FpgaProgramFileInfo.ColSpan=[3,20];

    SysObjGenTxt.Type='text';
    SysObjGenTxt.Tag='edaSysObjGenTxt';
    SysObjGenTxt.Name=this.getCatalogMsgStr('SysObjGenTxt_Text');
    SysObjGenTxt.RowSpan=[6,6];
    SysObjGenTxt.ColSpan=[2,2];
    SysObjGenTxt.Visible=false;


    ClassName=[this.BuildInfo.DUTName,'_fil'];
    FileName=[ClassName,'.m'];
    FilePath=fullfile('.',FileName);
    SysObjGenInfo.Type='text';
    SysObjGenInfo.Tag='edaSysObjGenInfo';
    SysObjGenInfo.Name=FilePath;
    SysObjGenInfo.RowSpan=[6,6];
    SysObjGenInfo.ColSpan=[3,20];
    SysObjGenInfo.Visible=false;

    BlockGenInfo.Type='text';
    BlockGenInfo.Tag='edaBlockGenInfo';
    BlockGenInfo.Name=this.getCatalogMsgStr('BlockGenTxt_Text');
    BlockGenInfo.RowSpan=[6,6];
    BlockGenInfo.ColSpan=[1,20];
    BlockGenInfo.Visible=false;

    if this.Tool==0
        SysObjGenInfo.Visible=true;
        SysObjGenTxt.Visible=true;
    else
        BlockGenInfo.Visible=true;
    end

    FileSummaryGroup.Type='group';
    FileSummaryGroup.Tag='edaFileSummaryGroup';
    FileSummaryGroup.Name=this.getCatalogMsgStr('FileSummary_Group');
    FileSummaryGroup.RowSpan=[2,6];
    FileSummaryGroup.ColSpan=[1,10];
    FileSummaryGroup.LayoutGrid=[6,20];
    FileSummaryGroup.Items={TopLevelSourceFileTxt,TopLevelSourceFileInfo,...
    GeneratedFileTxt,...
    FpgaProjectFileTxt,FileProjectFileInfo,...
    FpgaProgramFileTxt,FpgaProgramFileInfo,...
    SysObjGenTxt,SysObjGenInfo,BlockGenInfo};










    WidgetGroup=this.getWidgetGroup;
    WidgetGroup.Tag='edaWidgetGroupBuildOpt';
    WidgetGroup.LayoutGrid=[10,10];
    WidgetGroup.RowStretch=ones(1,10);
    WidgetGroup.ColStretch=[ones(1,9),0];
    WidgetGroup.Items={OutputFolder,BrowseBtn,FileSummaryGroup};

