function dlg=getDialogSchema(hSrc,schemaName)%#ok





    dlg=[];

    tag='Tag_CodeCoverage_';

    InstallationFolderName=...
    DAStudio.message('RTW:codeCoverage:dlgInstallationFolder');
    BrowseInstallationFolderTitle=...
    DAStudio.message('RTW:codeCoverage:dlgBrowseInstallationFolderTitle');

    selectedToolVerLabel=...
    DAStudio.message('RTW:codeCoverage:dlgSelectedCoverageToolVersion');


    widget=[];
    widget.Name=DAStudio.message('RTW:codeCoverage:dlgDescription');
    widget.Type='text';
    widget.Tag=[tag,'Description'];
    widget.WordWrap=true;
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    DescriptionText=widget;

    widget=[];
    widget.Name=DAStudio.message('RTW:codeCoverage:dlgDescriptionTitle');
    widget.Type='group';
    widget.Tag=[tag,'DescriptionTitle'];
    widget.Items={DescriptionText};
    widget.LayoutGrid=[1,1];
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    DescriptionGroup=widget;


    widget=[];
    widget.Name=DAStudio.message('RTW:codeCoverage:dlgToolSetup',...
    hSrc.ToolName,hSrc.ToolCompany);
    widget.Type='text';
    widget.Tag=[tag,'ToolSetup'];
    widget.WordWrap=true;
    ToolSetupText=widget;



    widget=[];
    widget.Name=InstallationFolderName;
    widget.Type='text';
    widget.Tag=[tag,'InstallationFolderLabel'];
    InstallFolderLbl=widget;


    [toolPath,detectedVersion]=loc_get_coverage_tool_path(hSrc.ToolClass);

    widget=[];
    widget.Type='edit';
    widget.Source=hSrc;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'InstallationFolderEdit'];
    widget.Value=toolPath;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.ToolTip=DAStudio.message...
    ('RTW:codeCoverage:dlgInstallationFolderEditToolTip',hSrc.ToolName);
    widget.Enabled=true;
    widget.Mode=1;
    widget.DialogRefresh=0;
    InstallFolderEdit=widget;


    widget=[];
    widget.Name=DAStudio.message...
    ('RTW:codeCoverage:dlgInstallationFolderBrowse');
    widget.Type='pushbutton';
    widget.Source=hSrc;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'InstallationFolderBrowse'];
    widget.MethodArgs={'%dialog',widget.Tag,BrowseInstallationFolderTitle};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=true;
    widget.Mode=1;
    widget.DialogRefresh=0;
    InstallFolderBrowse=widget;


    widget=[];
    widget.Name=selectedToolVerLabel;
    widget.Type='text';
    widget.Tag=[tag,selectedToolVerLabel];
    selectedToolVerLbl=widget;


    widget=[];
    widget.Name=detectedVersion;
    widget.Type='text';
    widget.Tag=[tag,'SelectedToolVersion'];
    selectedToolVer=widget;


    ToolSetupText.RowSpan=[1,1];
    ToolSetupText.ColSpan=[1,3];
    InstallFolderLbl.RowSpan=[2,2];
    InstallFolderLbl.ColSpan=[1,1];
    InstallFolderEdit.RowSpan=[2,2];
    InstallFolderEdit.ColSpan=[2,2];
    InstallFolderBrowse.RowSpan=[2,2];
    InstallFolderBrowse.ColSpan=[3,3];
    selectedToolVerLbl.RowSpan=[3,3];
    selectedToolVerLbl.ColSpan=[1,1];
    selectedToolVer.RowSpan=[3,3];
    selectedToolVer.ColSpan=[2,3];
    InstallFolderBrowse.MaximumSize=[70,50];

    widget=[];
    widget.Name=DAStudio.message('RTW:codeCoverage:dlgToolSetupTitle');
    widget.Type='group';
    widget.Tag=[tag,'DescriptionTitle'];
    widget.Items={ToolSetupText,...
    InstallFolderLbl,InstallFolderEdit,InstallFolderBrowse,...
    selectedToolVerLbl,selectedToolVer};
    widget.LayoutGrid=[3,3];
    widget.RowSpan=[2,2];
    widget.ColSpan=[1,1];
    ToolSetupGroup=widget;

    mdlName=getfullname(hSrc.ParentHSrc.getModel);


    widget=[];
    widget.Name=DAStudio.message('RTW:codeCoverage:thisModel',mdlName);
    widget.Type='checkbox';
    widget.ObjectProperty='IncludeTopModel';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.Source=hSrc;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=0;
    widget.ToolTip=DAStudio.message('RTW:codeCoverage:thisModelToolTip',mdlName);
    ThisModel_Widget=widget;
    ThisModel_Widget.RowSpan=[1,1];
    ThisModel_Widget.ColSpan=[1,1];



    widget=[];
    widget.Name=DAStudio.message('RTW:codeCoverage:refModels');
    widget.Type='checkbox';
    widget.ObjectProperty='IncludeReferencedModels';
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ObjectMethod='dialogCallback';
    widget.Source=hSrc;
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Mode=1;
    widget.DialogRefresh=0;
    widget.ToolTip=DAStudio.message('RTW:codeCoverage:refModelsToolTip',mdlName);
    ReferencedModels_Widget=widget;
    widget=[];

    ReferencedModels_Widget.RowSpan=[2,2];
    ReferencedModels_Widget.ColSpan=[1,1];



    widget.Name=DAStudio.message('RTW:codeCoverage:selectComponents');
    widget.Type='group';
    widget.LayoutGrid=[2,1];

    widget.Items={ThisModel_Widget,ReferencedModels_Widget};
    selectModels_Group=widget;

    dlg.DialogTitle=DAStudio.message('RTW:codeCoverage:coverageSettingsTitle',mdlName);
    dlg.LayoutGrid=[3,1];

    selectModels_Group.RowSpan=[3,3];

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/toolbox/ecoder/helptargets.map'],'ecoder_coverage'};
    dlg.Items={DescriptionGroup,ToolSetupGroup,selectModels_Group};
    dlg.PostApplyCallback='postApplyCallback';
    dlg.PostApplyArgs={hSrc,'%dialog'};
    dlg.PostApplyArgsDT={'MATLAB array','string'};


    dlg.CloseMethod='CloseCallback';
    dlg.CloseMethodArgs={'%dialog'};
    dlg.CloseMethodArgsDT={'handle'};


    dlg.Sticky=true;

    function[toolPath,detectedVersion]=loc_get_coverage_tool_path(toolClass)

        coverageToolObj=feval(toolClass);
        toolPath=coder.coverage.getCoverageToolPath(toolClass,'SkipValidate',true);
        try
            toolPath=coder.coverage.getCoverageToolPath(toolClass);
            detectedVersion=coverageToolObj.getActualVersion;
        catch exc
            if any(strfind(exc.identifier,'toolPathNotSet'))
                detectedVersion=DAStudio.message('CoderCoverage:AllTools:toolPathNotSetGui');
            elseif any(strfind(exc.identifier,'toolPathGetInvalid'))
                detectedVersion=DAStudio.message('CoderCoverage:AllTools:toolPathInvalidGui');
            else
                rethrow(exc)
            end
        end

