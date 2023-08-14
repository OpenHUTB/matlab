function dlg=getTemplateDialog(hObj,schemaName)




    dlg=[];











    cCodeTemplate_Name='Source file (*.c) template:';
    cCodeTemplate_ToolTip=['Specify template that organizes the generated code .c source files. '];

    Browse_Name='Browse...';

    Edit_Name='Edit...';

    hCodeTemplate_Name='Header file (*.h) template:';
    hCodeTemplate_ToolTip=['Specify template that organizes the generated code .h header files. '];

    cDataTemplate_Name='Source file (*.c) template:';
    cDataTemplate_ToolTip=['Specify template that organizes the generated data .c source files. '];

    hDataTemplate_Name='Header file (*.h) template:';
    hDataTemplate_ToolTip=['Specify template that organizes the generated data .h header files. '];

    genSMain_Name='Generate an example main program';
    genSMain_ToolTip=sprintf(...
    ['Generate an example main program demonstrating\n',...
    'how to deploy the generated code.  The program is\n',...
    'generated into ert_main.c.']);

    targetOS_Name='Target operating system:';
    targetOS_ToolTip=sprintf(...
    ['Specify the target operating system for the example main ert_main.c.\n',...
    'BareBoardExample is a generic example that assumes no operating system.\n',...
    'VxWorksExample is tailored to the VxWorks real-time operating system.']);

    fileProcessTemplate_Name='File customization template:';
    fileProcessTemplate_ToolTip='TLC callback script for customizing the generated code.';

    codeTemplateGroup.Name='Code templates';
    customTemplateGroup.Name='Custom templates';
    dataTemplateGroup.Name='Data templates';

    pageName='Templates';




    tag='Tag_ConfigSet_RTW_Templates_';

    hSrc=hObj;





    ObjectProperty='ERTSrcFileBannerTemplate';
    widgetLbl=[];
    widgetLbl.Name=cCodeTemplate_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.Buddy=[tag,ObjectProperty];
    cCodeTemplateLbl=widgetLbl;

    widget=[];
    widget.Type='edit';
    widget.ToolTip=cCodeTemplate_ToolTip;
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.UserData.Name=widgetLbl.Name;
    widget.Mode=1;
    widget.DialogRefresh=1;
    cCodeTemplate=widget;


    widget=[];
    widget.Name=Browse_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTSrcFileBannerTemplate_Browse'];
    widget.MethodArgs={'%dialog',widget.Tag,cCodeTemplate_Name};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=cCodeTemplate.Enabled;
    widget.Mode=1;
    widget.DialogRefresh=1;
    cCodeTemplateBrowse=widget;


    widget=[];
    widget.Name=Edit_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTSrcFileBannerTemplate_Edit'];
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=cCodeTemplate.Enabled&~isempty(hSrc.ERTSrcFileBannerTemplate);
    widget.Mode=1;
    cCodeTemplateEdit=widget;


    ObjectProperty='ERTHdrFileBannerTemplate';
    widgetLbl=[];
    widgetLbl.Name=hCodeTemplate_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.Buddy=[tag,ObjectProperty];
    hCodeTemplateLbl=widgetLbl;

    widget=[];
    widget.Type='edit';
    widget.ToolTip=hCodeTemplate_ToolTip;
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.UserData.Name=widgetLbl.Name;
    widget.Mode=1;
    widget.DialogRefresh=1;
    hCodeTemplate=widget;


    widget=[];
    widget.Name=Browse_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTHdrFileBannerTemplate_Browse'];
    widget.MethodArgs={'%dialog',widget.Tag,hCodeTemplate_Name};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=hCodeTemplate.Enabled;
    widget.Mode=1;
    widget.DialogRefresh=1;
    hCodeTemplateBrowse=widget;


    widget=[];
    widget.Name=Edit_Name;
    widget.Type='pushbutton';
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTHdrFileBannerTemplate_Edit'];
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=hCodeTemplate.Enabled&~isempty(hSrc.ERTHdrFileBannerTemplate);
    widget.Mode=1;
    hCodeTemplateEdit=widget;


    ObjectProperty='ERTDataSrcFileTemplate';
    widgetLbl=[];
    widgetLbl.Name=cDataTemplate_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.Buddy=[tag,ObjectProperty];
    cDataTemplateLbl=widgetLbl;

    widget=[];
    widget.Type='edit';
    widget.ToolTip=cDataTemplate_ToolTip;
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.UserData.Name=widgetLbl.Name;
    widget.Mode=1;
    widget.DialogRefresh=1;
    cDataTemplate=widget;


    widget=[];
    widget.Name=Browse_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTDataSrcFileTemplate_Browse'];
    widget.MethodArgs={'%dialog',widget.Tag,cDataTemplate_Name};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=cDataTemplate.Enabled;
    widget.DialogRefresh=1;
    cDataTemplateBrowse=widget;


    widget=[];
    widget.Name=Edit_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTDataSrcFileTemplate_Edit'];
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=cDataTemplate.Enabled&~isempty(hSrc.ERTDataSrcFileTemplate);
    cDataTemplateEdit=widget;


    ObjectProperty='ERTDataHdrFileTemplate';
    widgetLbl=[];
    widgetLbl.Name=hDataTemplate_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.Buddy=[tag,ObjectProperty];
    hDataTemplateLbl=widgetLbl;

    widget=[];
    widget.Type='edit';
    widget.ToolTip=hDataTemplate_ToolTip;
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.UserData.Name=widgetLbl.Name;
    hDataTemplate=widget;


    widget=[];
    widget.Name=Browse_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTDataHdrFileTemplate_Browse'];
    widget.MethodArgs={'%dialog',widget.Tag,hDataTemplate_Name};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=hDataTemplate.Enabled;
    widget.DialogRefresh=1;
    hDataTemplateBrowse=widget;


    widget=[];
    widget.Name=Edit_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTDataHdrFileTemplate_Edit'];
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=hDataTemplate.Enabled&~isempty(hSrc.ERTDataHdrFileTemplate);
    hDataTemplateEdit=widget;


    widget=[];
    widget.Name=genSMain_Name;
    widget.Type='checkbox';
    widget.ObjectProperty='GenerateSampleERTMain';
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.ToolTip=genSMain_ToolTip;
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Tag=[tag,widget.ObjectProperty];
    genSMain=widget;


    ObjectProperty='TargetOS';
    widgetLbl=[];
    widgetLbl.Name=targetOS_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.Buddy=[tag,ObjectProperty];
    widgetLbl.Visible=isequal(hSrc.GenerateSampleERTMain,'on');
    targetOSLbl=widgetLbl;

    widget=[];
    widget.Type='combobox';
    widget.ObjectProperty=ObjectProperty;
    type=findtype(get(findprop(hSrc,widget.ObjectProperty),'DataType'));
    widget.Entries=type.Strings';
    widget.Values=type.Values;
    widget.Enabled=double(~hSrc.isReadonlyProperty(widget.ObjectProperty));
    widget.ToolTip=targetOS_ToolTip;
    widget.Visible=widgetLbl.Visible;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.UserData.Name=widgetLbl.Name;
    targetOS=widget;


    ObjectProperty='ERTCustomFileTemplate';
    widgetLbl=[];
    widgetLbl.Name=fileProcessTemplate_Name;
    widgetLbl.Type='text';

    widgetLbl.Tag=[tag,ObjectProperty,'Lbl'];
    widgetLbl.Buddy=[tag,ObjectProperty];
    fileProcessTemplateLbl=widgetLbl;

    widget=[];
    widget.Type='edit';
    widget.ObjectProperty=ObjectProperty;
    widget.Enabled=~hSrc.isReadonlyProperty(widget.ObjectProperty);
    widget.ToolTip=fileProcessTemplate_ToolTip;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.UserData.Name=widgetLbl.Name;
    widget.Mode=1;
    widget.DialogRefresh=1;
    fileProcessTemplate=widget;



    widget=[];
    widget.Name=Browse_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTCustomFileTemplate_Browse'];
    widget.MethodArgs={'%dialog',widget.Tag,fileProcessTemplate_Name};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=fileProcessTemplate.Enabled;
    widget.Mode=1;
    widget.DialogRefresh=1;
    fileProcessTemplateBrowse=widget;


    widget=[];
    widget.Name=Edit_Name;
    widget.Type='pushbutton';
    widget.Source=hObj;
    widget.ObjectMethod='dialogCallback';
    widget.Tag=[tag,'ERTCustomFileTemplate_Edit'];
    widget.MethodArgs={'%dialog',widget.Tag,''};
    widget.ArgDataTypes={'handle','string','string'};
    widget.Enabled=fileProcessTemplate.Enabled&~isempty(hSrc.ERTCustomFileTemplate);
    fileProcessTemplateEdit=widget;






    cCodeTemplateLbl.RowSpan=[1,1];
    cCodeTemplateLbl.ColSpan=[1,1];
    cCodeTemplate.RowSpan=[1,1];
    cCodeTemplate.ColSpan=[2,2];
    cCodeTemplateBrowse.RowSpan=[1,1];
    cCodeTemplateBrowse.ColSpan=[3,3];
    cCodeTemplateBrowse.MaximumSize=[70,50];
    cCodeTemplateEdit.RowSpan=[1,1];
    cCodeTemplateEdit.ColSpan=[4,4];
    cCodeTemplateEdit.MaximumSize=[70,50];
    hCodeTemplateLbl.RowSpan=[2,2];
    hCodeTemplateLbl.ColSpan=[1,1];
    hCodeTemplate.RowSpan=[2,2];
    hCodeTemplate.ColSpan=[2,2];
    hCodeTemplateBrowse.RowSpan=[2,2];
    hCodeTemplateBrowse.ColSpan=[3,3];
    hCodeTemplateBrowse.MaximumSize=[70,50];
    hCodeTemplateEdit.RowSpan=[2,2];
    hCodeTemplateEdit.ColSpan=[4,4];
    hCodeTemplateEdit.MaximumSize=[70,50];
    codeTemplateGroup.Type='group';
    codeTemplateGroup.Items={cCodeTemplateLbl,cCodeTemplate,cCodeTemplateBrowse,cCodeTemplateEdit,...
    hCodeTemplateLbl,hCodeTemplate,hCodeTemplateBrowse,hCodeTemplateEdit};
    codeTemplateGroup.LayoutGrid=[2,4];
    codeTemplateGroup.ColStretch=[0,1,0,0];


    cDataTemplateLbl.RowSpan=[1,1];
    cDataTemplateLbl.ColSpan=[1,1];
    cDataTemplate.RowSpan=[1,1];
    cDataTemplate.ColSpan=[2,2];
    cDataTemplateBrowse.RowSpan=[1,1];
    cDataTemplateBrowse.ColSpan=[3,3];
    cDataTemplateBrowse.MaximumSize=[70,50];
    cDataTemplateEdit.RowSpan=[1,1];
    cDataTemplateEdit.ColSpan=[4,4];
    cDataTemplateEdit.MaximumSize=[70,50];
    hDataTemplateLbl.RowSpan=[2,2];
    hDataTemplateLbl.ColSpan=[1,1];
    hDataTemplate.RowSpan=[2,2];
    hDataTemplate.ColSpan=[2,2];
    hDataTemplateBrowse.RowSpan=[2,2];
    hDataTemplateBrowse.ColSpan=[3,3];
    hDataTemplateBrowse.MaximumSize=[70,50];
    hDataTemplateEdit.RowSpan=[2,2];
    hDataTemplateEdit.ColSpan=[4,4];
    hDataTemplateEdit.MaximumSize=[70,50];
    dataTemplateGroup.Type='group';
    dataTemplateGroup.Items={cDataTemplateLbl,cDataTemplate,cDataTemplateBrowse,cDataTemplateEdit,...
    hDataTemplateLbl,hDataTemplate,hDataTemplateBrowse,hDataTemplateEdit};
    dataTemplateGroup.LayoutGrid=[2,4];
    dataTemplateGroup.ColStretch=[0,1,0,0];


    fileProcessTemplateLbl.RowSpan=[1,1];
    fileProcessTemplateLbl.ColSpan=[1,1];
    fileProcessTemplate.RowSpan=[1,1];
    fileProcessTemplate.ColSpan=[2,2];
    fileProcessTemplateBrowse.RowSpan=[1,1];
    fileProcessTemplateBrowse.ColSpan=[3,3];
    fileProcessTemplateBrowse.MaximumSize=[70,50];
    fileProcessTemplateEdit.RowSpan=[1,1];
    fileProcessTemplateEdit.ColSpan=[4,4];
    fileProcessTemplateEdit.MaximumSize=[70,50];
    genSMain.RowSpan=[2,2];
    genSMain.ColSpan=[1,4];
    targetOSLbl.RowSpan=[3,3];
    targetOSLbl.ColSpan=[1,1];
    targetOS.RowSpan=[3,3];
    targetOS.ColSpan=[2,4];
    customTemplateGroup.Type='group';
    customTemplateGroup.Items={genSMain,targetOSLbl,targetOS,...
    fileProcessTemplateLbl,fileProcessTemplate,...
    fileProcessTemplateBrowse,fileProcessTemplateEdit};
    customTemplateGroup.LayoutGrid=[3,4];
    customTemplateGroup.ColStretch=[0,1,0,0];





    codeTemplateGroup.RowSpan=[1,1];
    dataTemplateGroup.RowSpan=[2,2];
    customTemplateGroup.RowSpan=[3,3];
    dlg.Name=pageName;
    dlg.Items={codeTemplateGroup,dataTemplateGroup,customTemplateGroup};
    dlg.LayoutGrid=[4,1];
    dlg.RowStretch=[0,0,0,1];