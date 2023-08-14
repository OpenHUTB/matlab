function schema=getSysSelectionSchema(dlgsrc,name)%#ok<INUSD>








    tag_prefix='rtw_';
    rootSystem=dlgsrc.rootSystem;
    if~ischar(rootSystem);
        rootSystem=Simulink.ID.getSID(rootSystem);
    end


    sys=find_system(rootSystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');






    sysSelection.Name=dlgsrc.bxlate('RTWSysSelectionName');
    sysSelection.Type='combobox';
    sysSelection.Entries=[rootSystem;sys];
    sysSelection.ObjectProperty='targetSystem';
    sysSelection.RowSpan=[1,1];
    sysSelection.ColSpan=[2,3];
    sysSelection.Tag=[tag_prefix,'SysSelection'];
    sysSelection.ToolTip=dlgsrc.bxlate('RTWSysSelectionTooltip');
    sysSelection.Mode=1;
    sysSelection.DialogRefresh=1;


    grpSysSelection.Type='group';
    grpSysSelection.Tag=[tag_prefix,'SysSelectionGroup'];
    grpSysSelection.Name=dlgsrc.bxlate('RTWSysSelectionGroupName');
    grpSysSelection.LayoutGrid=[1,3];
    grpSysSelection.Items={sysSelection};

    pnlSysSelection.Type='panel';
    pnlSysSelection.Tag=[tag_prefix,'SysSelectionPanel'];
    pnlSysSelection.Items={grpSysSelection};

    schema=pnlSysSelection;

end
