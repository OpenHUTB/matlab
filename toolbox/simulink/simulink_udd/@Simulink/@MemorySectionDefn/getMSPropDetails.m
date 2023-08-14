function msSubTabs=getMSPropDetails(hThis,hUI)






    ToolTip_MS=DAStudio.message('Simulink:dialog:MemorySectionDefnToolTipMS');


    ToolTip_Identifier=DAStudio.message('Simulink:dialog:MemorySectionDefnToolTipMSIdent');






    currMSDefn=hThis;

    isMSEditableGeneral=(~isempty(currMSDefn))&&...
    (hUI.Index(2)~=0);



    msName.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabName');
    msName.Type='edit';
    msName.Tag='tmsNameEdit';
    if~isempty(currMSDefn)
        msName.Value=assignOrSetEmpty(hUI,currMSDefn.Name);
        msName.Source=hUI;
        msName.ObjectMethod='nameDefn';
        msName.MethodArgs={'%value'};
        msName.ArgDataTypes={'mxArray'};
    end
    msName.Mode=1;
    msName.DialogRefresh=1;
    msName.Enabled=isMSEditableGeneral;
    msName.ToolTip=ToolTip_MS;

    showDataUsage=(slfeature('SeparateMemorySectionsForParamsAndSignals')>1);


    msUsagePrm.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabForParameters');
    msUsagePrm.Type='checkbox';
    msUsagePrm.Tag='tmsParamCheck';
    if~isempty(currMSDefn)
        hDataUsage=currMSDefn.getProp('DataUsage');
        msUsagePrm.Value=hDataUsage.IsParameter;
        msUsagePrm.Source=hUI;
        msUsagePrm.ObjectMethod='setPropAndDirty';
        msUsagePrm.MethodArgs=...
        {currMSDefn.getProp('DataUsage'),'IsParameter','%value',{}};
        msUsagePrm.ArgDataTypes=...
        {'mxArray','mxArray','mxArray','mxArray'};
    end
    msUsagePrm.Mode=1;
    msUsagePrm.DialogRefresh=1;
    msUsagePrm.Enabled=isMSEditableGeneral;
    msUsagePrm.Visible=showDataUsage;


    msUsageSig.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabForSignals');
    msUsageSig.Type='checkbox';
    msUsageSig.Tag='tmsSigCheck';
    if~isempty(currMSDefn)
        hDataUsage=currMSDefn.getProp('DataUsage');
        msUsageSig.Value=hDataUsage.IsSignal;
        msUsageSig.Source=hUI;
        msUsageSig.ObjectMethod='setPropAndDirty';
        msUsageSig.MethodArgs={hDataUsage,'IsSignal','%value',{}};
        msUsageSig.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    msUsageSig.Mode=1;
    msUsageSig.DialogRefresh=1;
    msUsageSig.Enabled=isMSEditableGeneral;
    msUsageSig.Visible=showDataUsage;




    msIsConst.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabIsConst');
    msIsConst.Type='checkbox';
    msIsConst.Tag='tmsConstCheck';
    if~isempty(currMSDefn)
        msIsConst.Value=currMSDefn.getProp('IsConst');
        msIsConst.Source=hUI;
        msIsConst.ObjectMethod='setPropAndDirty';
        msIsConst.MethodArgs={currMSDefn,'IsConst','%value',{}};
        msIsConst.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    msIsConst.Mode=1;
    msIsConst.DialogRefresh=1;
    msIsConst.Enabled=isMSEditableGeneral&&~(showDataUsage&&hDataUsage.IsSignal);

    msIsVolatile.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabIsVolatile');
    msIsVolatile.Type='checkbox';
    msIsVolatile.Tag='tmsVolatileCheck';
    if~isempty(currMSDefn)
        msIsVolatile.Value=currMSDefn.getProp('IsVolatile');
        msIsVolatile.Source=hUI;
        msIsVolatile.ObjectMethod='setPropAndDirty';
        msIsVolatile.MethodArgs={currMSDefn,'IsVolatile','%value',{}};
        msIsVolatile.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    msIsVolatile.Mode=1;
    msIsVolatile.DialogRefresh=1;
    msIsVolatile.Enabled=isMSEditableGeneral;

    msQualifier.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabQualifer');
    msQualifier.Type='edit';
    msQualifier.Tag='tmsQualifierEdit';
    if~isempty(currMSDefn)
        msQualifier.Value=assignOrSetEmpty(hUI,currMSDefn.getProp('Qualifier'));
        msQualifier.Source=hUI;
        msQualifier.ObjectMethod='setPropAndDirty';
        msQualifier.MethodArgs={currMSDefn,'Qualifier','%value',{}};
        msQualifier.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    msQualifier.Mode=1;
    msQualifier.DialogRefresh=1;
    msQualifier.Enabled=isMSEditableGeneral;

    msComment.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabComment');
    msComment.Type='editarea';

    msComment.MaximumSize=[9999,50];
    msComment.Tag='tmsCommentEdit';
    if~isempty(currMSDefn)
        msComment.Value=assignOrSetEmpty(hUI,currMSDefn.getProp('CommentForUI'));
        msComment.Source=hUI;
        msComment.ObjectMethod='setPropAndDirty';
        msComment.MethodArgs={currMSDefn,'CommentForUI','%value',{}};
        msComment.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    msComment.Mode=1;
    msComment.DialogRefresh=1;
    msComment.Enabled=isMSEditableGeneral;


    msIdInstruction.Name='';
    msIdInstruction.Type='text';
    msIdInstruction.Tag='tmsIdInstructionText';


    msPragmaAppliesTo.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabPragmaSurrounds');
    msPragmaAppliesTo.Type='combobox';
    msPragmaAppliesTo.Tag='tmsPragmaAppliesTo';
    msPragmaAppliesTo.Entries=...
    {'Group of variables','Each variable'};
    msPragmaAppliesTo.Mode=1;
    msPragmaAppliesTo.MultiSelect=false;
    msPragmaAppliesTo.DialogRefresh=1;
    msPragmaAppliesTo.Enabled=isMSEditableGeneral;


    if~isempty(currMSDefn)
        if(currMSDefn.getProp('PragmaPerVar'))
            msPragmaAppliesTo.Value=1;
            msIdInstruction.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabPragmaSurroundsPerVarTip');
        else
            msPragmaAppliesTo.Value=0;
        end
        msPragmaAppliesTo.Source=hUI;
        msPragmaAppliesTo.ObjectMethod='setPropAndDirty';
        msPragmaAppliesTo.MethodArgs=...
        {currMSDefn,'PragmaPerVar','%value',{}};
        msPragmaAppliesTo.ArgDataTypes=...
        {'mxArray','mxArray','mxArray','mxArray'};
    end



    msPrePragma.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabPreMemorySectionPragma');
    msPrePragma.Type='editarea';

    msPrePragma.MaximumSize=[9999,50];
    msPrePragma.Tag='tmsPrePragmaEdit';
    if~isempty(currMSDefn)
        msPrePragma.Value=assignOrSetEmpty(hUI,currMSDefn.getProp('PrePragmaForUI'));
        msPrePragma.Source=hUI;
        msPrePragma.ObjectMethod='setPropAndDirty';
        msPrePragma.MethodArgs={currMSDefn,'PrePragmaForUI','%value',{}};
        msPrePragma.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    msPrePragma.Mode=1;
    msPrePragma.DialogRefresh=1;
    msPrePragma.Enabled=isMSEditableGeneral;
    msPrePragma.ToolTip=ToolTip_Identifier;

    msPostPragma.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTabPostMemorySectionPragma');
    msPostPragma.Type='editarea';
    msPostPragma.Tag='tmsPostPragmaEdit';

    msPostPragma.MaximumSize=[9999,50];
    if~isempty(currMSDefn)
        msPostPragma.Value=assignOrSetEmpty(hUI,currMSDefn.getProp('PostPragmaForUI'));
        msPostPragma.Source=hUI;
        msPostPragma.ObjectMethod='setPropAndDirty';
        msPostPragma.MethodArgs={currMSDefn,'PostPragmaForUI','%value',{}};
        msPostPragma.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    msPostPragma.Mode=1;
    msPostPragma.DialogRefresh=1;
    msPostPragma.Enabled=isMSEditableGeneral;
    msPostPragma.ToolTip=ToolTip_Identifier;

    msConfGroup.Type='group';
    msConfGroup.Tag='tmsConfGroup';
    msConfGroup.LayoutGrid=[8,3];
    msConfGroup.RowStretch=[0,0,0,0,0,0,0,1];

    msName.RowSpan=[1,1];
    msName.ColSpan=[1,2];
    msUsagePrm.RowSpan=[2,2];
    msUsagePrm.ColSpan=[1,1];
    msUsageSig.RowSpan=[2,2];
    msUsageSig.ColSpan=[2,2];
    msIsConst.RowSpan=[3,3];
    msIsConst.ColSpan=[1,1];
    msIsVolatile.RowSpan=[3,3];
    msIsVolatile.ColSpan=[2,2];
    msQualifier.RowSpan=[3,3];
    msQualifier.ColSpan=[3,3];
    msComment.RowSpan=[4,4];
    msComment.ColSpan=[1,3];
    msPragmaAppliesTo.RowSpan=[5,5];
    msPragmaAppliesTo.ColSpan=[1,2];
    msIdInstruction.RowSpan=[5,5];
    msIdInstruction.ColSpan=[3,3];
    msPrePragma.RowSpan=[6,6];
    msPrePragma.ColSpan=[1,3];
    msPostPragma.RowSpan=[7,7];
    msPostPragma.ColSpan=[1,3];

    msConfGroup.Items={...
    msName,...
    msIsConst,...
    msIsVolatile,...
    msQualifier,...
    msUsagePrm,...
    msUsageSig,...
    msComment,...
    msPragmaAppliesTo,...
    msIdInstruction,...
    msPrePragma,...
    msPostPragma,...
    };


    dummyTab=[];
    dummyTab.Name=DAStudio.message('Simulink:dialog:MemorySectionDefnTab');
    dummyTab.Items={msConfGroup};

    msSubTabs.Name='MSEditSubTabs';
    msSubTabs.Type='tab';
    msSubTabs.Tag='tmsEditSubTabs';
    msSubTabs.Tabs={dummyTab};





