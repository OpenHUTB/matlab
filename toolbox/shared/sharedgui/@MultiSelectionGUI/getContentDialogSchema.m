function dlgstruct=getContentDialogSchema(hObj)




    tag='tag_';

    iconpath=fullfile(matlabroot,'toolbox','shared','dastudio','resources');



    if(isempty(hObj.availableObjs))
        lhsListBoxEntries={};
    else
        lhsListBoxEntries={hObj.availableObjs.Name};
    end
    lhsListBox.Name=DAStudio.message(hObj.itemNamesAndDescription.ListboxLeft);
    lhsListBox.Type='listbox';
    lhsListBox.Tag=[tag,'Available'];
    lhsListBox.Entries=lhsListBoxEntries;
    lhsListBox.Mode=1;
    lhsListBox.Graphical=true;
    lhsListBox.DialogRefresh=false;
    lhsListBox.ListDoubleClickCallback=@doubleClick;
    lhsListBox.ObjectMethod='dialogCallback';
    lhsListBox.MethodArgs={'%dialog',[lhsListBox.Tag,'2']};
    lhsListBox.ArgDataTypes={'handle','string'};
    lhsListBox.ToolTip=DAStudio.message(hObj.itemNamesAndDescription.ListBoxLeftToolTip);
    lhsListBox.Source=hObj;
    lhsListBox.ColSpan=[1,1];
    lhsListBox.RowSpan=[1,6];



    if(isempty(hObj.selectedObjs))
        rhsListBoxEntries={};
    else
        rhsListBoxEntries={hObj.selectedObjs.Name};
    end
    rhsListBox.Name=DAStudio.message(hObj.itemNamesAndDescription.ListboxRight);
    rhsListBox.Type='listbox';
    rhsListBox.Tag=[tag,'Selected'];
    rhsListBox.Entries=rhsListBoxEntries;
    rhsListBox.Mode=1;
    rhsListBox.Graphical=true;
    rhsListBox.DialogRefresh=false;
    rhsListBox.ListDoubleClickCallback=@doubleClick;
    rhsListBox.ListKeyPressCallback=@singleClick;
    rhsListBox.ObjectMethod='dialogCallback';
    rhsListBox.MethodArgs={'%dialog',[rhsListBox.Tag,'2']};
    rhsListBox.ArgDataTypes={'handle','string'};
    rhsListBox.ToolTip=DAStudio.message(hObj.itemNamesAndDescription.ListBoxRightToolTip);
    rhsListBox.Source=hObj;
    rhsListBox.ColSpan=[3,3];
    rhsListBox.RowSpan=[1,6];

    if hObj.rhsChosenItem>=0
        rhsListBox.Value=hObj.rhsChosenItem;
        hObj.rhsChosenItem=-1;
    end


    rightArrow=[];
    rightArrow.FilePath=fullfile(iconpath,'move_right.gif');
    rightArrow.Type='pushbutton';
    rightArrow.Tag=[tag,'rightbutton'];
    rightArrow.ObjectMethod='dialogCallback';
    rightArrow.MethodArgs={'%dialog',rightArrow.Tag};
    rightArrow.ArgDataTypes={'handle','string'};
    rightArrow.Mode=1;
    rightArrow.DialogRefresh=1;
    rightArrow.ToolTip=DAStudio.message(hObj.itemNamesAndDescription.RightButtonToolTip);
    rightArrow.Source=hObj;
    rightArrow.MaximumSize=[60,30];
    rightArrow.MinimumSize=[60,30];
    rightArrow.ColSpan=[2,2];
    rightArrow.RowSpan=[3,3];
    rightArrow.Enabled=(~isempty(hObj.availableObjs));


    leftArrow.FilePath=fullfile(iconpath,'move_left.gif');
    leftArrow.Type='pushbutton';
    leftArrow.Tag=[tag,'leftbutton'];
    leftArrow.ObjectMethod='dialogCallback';
    leftArrow.MethodArgs={'%dialog',leftArrow.Tag};
    leftArrow.ArgDataTypes={'handle','string'};
    leftArrow.Mode=1;
    leftArrow.DialogRefresh=1;
    leftArrow.ToolTip=DAStudio.message(hObj.itemNamesAndDescription.LeftButtonToolTip);
    leftArrow.Source=hObj;
    leftArrow.MaximumSize=[60,30];
    leftArrow.MinimumSize=[60,30];
    leftArrow.ColSpan=[2,2];
    leftArrow.RowSpan=[4,4];
    leftArrow.Enabled=(~isempty(hObj.selectedObjs));


    upArrow.FilePath=fullfile(iconpath,'move_up.gif');
    upArrow.Type='pushbutton';
    upArrow.Tag=[tag,'upbutton'];
    upArrow.ObjectMethod='dialogCallback';
    upArrow.MethodArgs={'%dialog',upArrow.Tag};
    upArrow.ArgDataTypes={'handle','string'};
    upArrow.DialogRefresh=1;
    upArrow.ToolTip=DAStudio.message(hObj.itemNamesAndDescription.UpButtonToolTip);
    upArrow.Source=hObj;
    upArrow.MaximumSize=[20,20];
    upArrow.ColSpan=[4,4];
    upArrow.RowSpan=[3,3];


    downArrow.FilePath=fullfile(iconpath,'move_down.gif');
    downArrow.Type='pushbutton';
    downArrow.Tag=[tag,'downbutton'];
    downArrow.ObjectMethod='dialogCallback';
    downArrow.MethodArgs={'%dialog',downArrow.Tag};
    downArrow.ArgDataTypes={'handle','string'};
    downArrow.DialogRefresh=1;
    downArrow.ToolTip=DAStudio.message(hObj.itemNamesAndDescription.DownButtonToolTip);
    downArrow.Source=hObj;
    downArrow.MaximumSize=[20,20];
    downArrow.ColSpan=[4,4];
    downArrow.RowSpan=[4,4];

    dlgstruct.LayoutGrid=[7,5];
    dlgstruct.Items={lhsListBox,rhsListBox,rightArrow,leftArrow,downArrow,upArrow};
    dlgstruct.DialogRefresh=1;
    dlgstruct.Source=hObj;

    function doubleClick(hDlg,tag,listItemIdx)%#ok
        dialogCallback(hObj,hDlg,tag);
        hDlg.refresh();
    end

    function singleClick(hDlg,tag,listItemIdx)%#ok
        dialogCallback(hObj,hDlg,[tag,'2']);
        hDlg.refresh();
    end

end








