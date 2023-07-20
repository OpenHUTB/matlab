function dlg=getDialogSchema(hSrc,schemaName)%#ok




    dlg=[];

    tag='Tag_TraceInfo_';

    BuildDir_Name=DAStudio.message('RTW:traceInfo:buildDirectory');
    BuildDir_ToolTip=DAStudio.message('RTW:traceInfo:buildDirectoryToolTip');

    BuildDirBrowse_Name=DAStudio.message('RTW:traceInfo:buildDirBrowseButton');
    BuildDirBrowse_ToolTip=DAStudio.message('RTW:traceInfo:buildDirBrowseToolTip');


    widget=[];
    widget.Name=DAStudio.message('RTW:traceInfo:dlgDescription');
    widget.Type='text';
    widget.Tag=[tag,'Description'];
    widget.WordWrap=true;
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    DescriptionText=widget;

    widget=[];
    widget.Name=DAStudio.message('RTW:traceInfo:dlgDescriptionTitle');
    widget.Type='group';
    widget.Tag=[tag,'DescriptionTitle'];
    widget.Items={DescriptionText};
    widget.LayoutGrid=[1,1];
    widget.RowSpan=[1,1];
    widget.ColSpan=[1,1];
    DescriptionGroup=widget;


    ObjectProperty='BuildDir';
    widget=[];
    widget.Name=[BuildDir_Name,':'];
    widget.Type='edit';
    widget.Tag=[tag,ObjectProperty];
    if~isempty(hSrc.BuildDir)
        widget.Value=hSrc.BuildDir;
    else
        widget.Value=hSrc.getDefaultBuildDir();
    end
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag};
    widget.ArgDataTypes={'handle','string'};
    widget.ToolTip=BuildDir_ToolTip;
    BuildDir_Widget=widget;


    widget=[];
    widget.Name=BuildDirBrowse_Name;
    widget.Type='pushbutton';
    widget.Tag=[tag,'BuildDirBrowse'];

    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',widget.Tag};
    widget.ArgDataTypes={'handle','string'};
    widget.ToolTip=BuildDirBrowse_ToolTip;
    widget.Graphical=1;
    buildDirBrowse_Widget=widget;

    BuildDir_Widget.ColSpan=[1,1];
    buildDirBrowse_Widget.ColSpan=[2,2];

    widget=[];
    widget.Name=DAStudio.message('RTW:traceInfo:generatedCode');
    widget.Type='group';
    widget.LayoutGrid=[1,2];
    widget.ColStretch=[1,0];
    widget.Items={BuildDir_Widget,buildDirBrowse_Widget};
    genCode_Group=widget;

    dlg.DialogTitle=DAStudio.message('RTW:traceInfo:blockToCodeHighlighting');
    dlg.LayoutGrid=[2,1];

    genCode_Group.RowSpan=[2,2];

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/toolbox/ecoder/helptargets.map'],'ecoder_blocktocode'};
    dlg.Items={DescriptionGroup,genCode_Group};
    dlg.PostApplyCallback='postApplyCallback';
    dlg.PostApplyArgs={hSrc,'%dialog'};
    dlg.PostApplyArgsDT={'MATLAB array','string'};


