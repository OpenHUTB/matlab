function hDlg=getDialogSchema(hObj,~)





    tag='Tag_Objective_';

    ertTarget=get_param(hObj.ParentSrc,'IsERTTarget')=="on";


    if ertTarget
        descr.Name=DAStudio.message('RTW:configSet:configSetObjectivesDescrName');
    else
        descr.Name=DAStudio.message('RTW:configSet:configSetObjectivesDescrName2');
    end

    descr.Type='text';
    descr.ColSpan=[1,2];
    descr.RowSpan=[1,1];


    objectiveSchema=getObjectiveDialogSchema(hObj);

    objectiveGrp.Type='group';
    objectiveGrp.LayoutGrid=[9,3];
    objectiveGrp.Items=objectiveSchema.Items;
    objectiveGrp.RowSpan=[2,2];
    objectiveGrp.ColSpan=[1,1];
    objectiveGrp.Enabled=ertTarget;

    descrGrp.Type='group';
    descrGrp.Name=DAStudio.message('RTW:configSet:configSetObjectivesGroupName');
    descrGrp.Items={descr};
    descrGrp.RowSpan=[1,1];
    descrGrp.ColSpan=[1,1];


    OK.Name=DAStudio.message('RTW:configSet:configSetObjectivesFinishButtonName');
    OK.Type='pushbutton';
    OK.Tag=[tag,'OKButton'];
    OK.ObjectMethod='dialogCallback';
    OK.MethodArgs={'%dialog',OK.Tag};
    OK.ArgDataTypes={'handle','string'};
    OK.DialogRefresh=1;
    OK.Source=hObj;
    OK.RowSpan=[1,1];
    OK.ColSpan=[2,2];


    cancel.Name=DAStudio.message('RTW:configSet:configSetObjectivesCancelButtonName');
    cancel.Type='pushbutton';
    cancel.Tag=[tag,'CancelButton'];
    cancel.ObjectMethod='dialogCallback';
    cancel.MethodArgs={'%dialog',cancel.Tag};
    cancel.ArgDataTypes={'handle','string'};
    cancel.DialogRefresh=1;
    cancel.Source=hObj;
    cancel.RowSpan=[1,1];
    cancel.ColSpan=[3,3];


    help.Name=DAStudio.message('RTW:configSet:configSetObjectivesHelpButtonName');
    help.Type='pushbutton';
    help.Tag=[tag,'Help'];
    help.ObjectMethod='dialogCallback';
    help.MethodArgs={'%dialog',help.Tag};
    help.ArgDataTypes={'handle','string'};
    help.DialogRefresh=1;
    help.Source=hObj;
    help.RowSpan=[1,1];
    help.ColSpan=[4,4];

    buttonGrp.Type='panel';
    buttonGrp.LayoutGrid=[1,4];
    buttonGrp.ColStretch=[1,0,0,0];
    buttonGrp.Items={OK,cancel,help};
    buttonGrp.RowSpan=[3,3];
    buttonGrp.ColSpan=[1,1];

    objectivesLGrp.LayoutGrid=[4,1];
    objectivesLGrp.RowStretch=[0,1,0,0];
    objectivesLGrp.Type='panel';
    objectivesLGrp.Items={descrGrp,objectiveGrp,buttonGrp};


    hDlg.DialogTitle=DAStudio.message('RTW:configSet:configSetObjectivesDialogTitle');
    hDlg.CloseMethod='dialogCallback';
    hDlg.CloseMethodArgs={'%dialog',cancel.Tag};
    hDlg.CloseMethodArgsDT={'handle','string'};
    hDlg.LayoutGrid=[3,1];
    hDlg.Items={objectivesLGrp};
    hDlg.StandaloneButtonSet={''};
end


