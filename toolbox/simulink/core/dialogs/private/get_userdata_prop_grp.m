function[grpUserData,tabUserData]=get_userdata_prop_grp(h)















    grpUserData.Name='TargetUserData:';
    grpUserData.Type='panel';
    grpUserData.Items={};
    grpUserData.RowSpan=[1,1];
    grpUserData.ColSpan=[1,2];
    grpUserData.Tag='GrpTargetUserData';

    if slfeature('SLDataDictionarySetUserData')>0
        propList=Simulink.data.getPropList(h,'GetAccess','public');
        propNameList={propList.Name};
        if ismember('TargetUserData',propNameList)&&~isempty(h.TargetUserData)
            try
                dlgstruct=h.TargetUserData.getDialogSchema('TargetUserData');
            catch

                dlgstruct=get_object_default_ddg(h,'TargetUserData',h.TargetUserData);
            end

            grpUserData.Items=dlgstruct.Items;

            if isfield(dlgstruct,'LayoutGrid')
                grpUserData.LayoutGrid=dlgstruct.LayoutGrid;
            end
            if isfield(dlgstruct,'RowStretch')
                grpUserData.RowStretch=dlgstruct.RowStretch;
            end
            if isfield(dlgstruct,'ColStretch')
                grpUserData.ColStretch=dlgstruct.ColStretch;
            end
        end
    end

    spacer.Type='panel';
    spacer.RowSpan=[2,2];
    spacer.ColSpan=[1,1];
    spacer.Tag='Spacer';

    tabUserData.Name=DAStudio.message('Simulink:dialog:TargetUserDataPrompt');
    tabUserData.Items={grpUserData,spacer};
    tabUserData.LayoutGrid=[2,1];
    tabUserData.RowStretch=[0,1];
    tabUserData.Tag='TabThree';

end
