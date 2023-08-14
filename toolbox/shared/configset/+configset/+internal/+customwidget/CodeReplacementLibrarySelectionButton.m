function updateDeps=CodeReplacementLibrarySelectionButton(cs,~)


    updateDeps=false;
    availableStruct=configset.internal.custom.CodeReplacementLibrary_entries(cs,'CodeReplacementLibrary',false);
    availableArray={availableStruct.str};
    selected=get_param(cs,'CodeReplacementLibrary');
    selectedArray=coder.internal.getCrlLibraries(selected);
    tr=RTW.TargetRegistry.get;
    [lhs,rhs]=coder.internal.CodeReplacementLibrary_gui(tr,availableArray,selectedArray);

    callBack=@setCodeReplacementLibrary;

    itemNamesInUI.Description='RTW:configSet:configSetCrlDescrName';
    itemNamesInUI.GroupName='RTW:configSet:configSetCrlGroupName';
    itemNamesInUI.FinishButtonName='RTW:configSet:configSetCrlFinishButtonName';
    itemNamesInUI.CancelButtonName='RTW:configSet:configSetCrlCancelButtonName';
    itemNamesInUI.HelpButtonName='RTW:configSet:configSetCrlHelpButtonName';
    itemNamesInUI.DialogTitle='RTW:configSet:configSetCrlDialogTitle';
    itemNamesInUI.ListboxLeft='RTW:configSet:configSetCrlListboxName1';
    itemNamesInUI.ListBoxLeftToolTip='RTW:configSet:configSetCrlListBoxLeftToolTip';
    itemNamesInUI.ListboxRight='RTW:configSet:configSetCrlListboxName2';
    itemNamesInUI.ListBoxRightToolTip='RTW:configSet:configSetCrlListBoxRightToolTip';
    itemNamesInUI.RightButtonToolTip='RTW:configSet:configSetCrlRightButtonToolTip';
    itemNamesInUI.LeftButtonToolTip='RTW:configSet:configSetCrlLeftButtonToolTip';
    itemNamesInUI.UpButtonToolTip='RTW:configSet:configSetCrlUpButtonToolTip';
    itemNamesInUI.DownButtonToolTip='RTW:configSet:configSetCrlDownButtonToolTip';

    docInfo.docMapLocation=[docroot,'/toolbox/ecoder/helptargets.map'];
    docInfo.configsetTag='Tag_ConfigSet_ERT_Target_CodeReplacementLibrary';

    UI=MultiSelectionGUI(lhs,rhs,callBack,docInfo,itemNamesInUI,cs);
    DAStudio.Dialog(UI);

end

function[success,errorMsg]=setCodeReplacementLibrary(selectedObjs,cs)


    success=true;
    errorMsg='';
    try
        delimiter=coder.internal.getCrlLibraryDelimiter();
        len=length(selectedObjs);
        selectedLibNames='';
        if len>0
            for i=1:len
                if i==1
                    selectedLibNames=selectedObjs(i).Name;
                else
                    selectedLibNames=[selectedLibNames,delimiter,selectedObjs(i).Name];%#ok<AGROW>
                end
            end
        else
            selectedLibNames='None';
        end
        set_param(cs,'CodeReplacementLibrary',selectedLibNames);
    catch E
        success=false;
        errorMsg='Error occurred when trying to setup CodeReplacementLibrary';
    end
    dlg=cs.getDialogHandle;
    if~isempty(dlg)
        dlg.getDialogSource.enableApplyButton(true);
        dirtyWidget(ConfigSet.DDGWrapper(dlg),'CodeReplacementLibrary',true);
    end
end

