function cscSubTabs=getCSCPropDetails(currCSCDefn,hUI)









    isDefaultCSC=(hUI.Index(1)==0);


    isCSCDisabledBecauseNotAdvancedMode=((~isempty(currCSCDefn))&&...
    (strcmp(currCSCDefn.CSCType,'Other'))&&...
    (~hUI.IsAdvanceMode));




    isCSCEditable=((~isempty(currCSCDefn))&&...
    (~isDefaultCSC)&&...
    (~isCSCDisabledBecauseNotAdvancedMode));







    msList.Entries={};
    for i=1:length(hUI.AllDefns{2})
        memSecDefn=hUI.AllDefns{2}(i);


        if(currCSCDefn.getProp('DataUsage').IsParameter&&...
            ~memSecDefn.getProp('DataUsage').IsParameter)
            continue;
        end

        if(currCSCDefn.getProp('DataUsage').IsSignal&&...
            ~memSecDefn.getProp('DataUsage').IsSignal)
            continue;
        end

        msList.Entries=[msList.Entries,{memSecDefn.Name}];
    end
    clear memSecDefn






    cscNeedAdv.Name=DAStudio.message('Simulink:dialog:CSCDefnToolTipAdvMode');
    cscNeedAdv.Type='text';
    cscNeedAdv.Tag='tcscNeedAdvText';
    cscNeedAdv.Visible=isCSCDisabledBecauseNotAdvancedMode;
    cscNeedAdv.ForegroundColor=[0,0,255];
    cscNeedAdv.RowSpan=[1,1];
    cscNeedAdv.ColSpan=[1,1];
    cscNeedAdv.WordWrap=true;

    cscNeedAdvGroup.Items={cscNeedAdv};
    cscNeedAdvGroup.Type='group';
    cscNeedAdvGroup.Tag='tcscNeedAdvGroup';
    cscNeedAdvGroup.Visible=isCSCDisabledBecauseNotAdvancedMode;
    cscNeedAdvGroup.LayoutGrid=[1,1];
    cscNeedAdvGroup.Flat=true;






    cscName.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabName');
    cscName.Type='edit';
    cscName.Tag='tcscNameEdit';
    if~isempty(currCSCDefn)
        cscName.Value=hUI.assignOrSetEmpty(currCSCDefn.Name);
        cscName.Source=hUI;
        cscName.ObjectMethod='nameDefn';
        cscName.MethodArgs={'%value'};
        cscName.ArgDataTypes={'mxArray'};
    end
    cscName.Mode=1;
    cscName.DialogRefresh=1;
    cscName.Enabled=isCSCEditable;


    cscUsageParam.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabForParameters');
    cscUsageParam.Type='checkbox';
    cscUsageParam.Tag='tcscParamCheck';
    if~isempty(currCSCDefn)
        hDataUsage=currCSCDefn.getProp('DataUsage');
        cscUsageParam.Value=hDataUsage.IsParameter;
        cscUsageParam.Source=hUI;
        cscUsageParam.ObjectMethod='setPropAndDirty';
        cscUsageParam.MethodArgs=...
        {currCSCDefn.getProp('DataUsage'),'IsParameter','%value',{}};
        cscUsageParam.ArgDataTypes=...
        {'mxArray','mxArray','mxArray','mxArray'};
    end
    cscUsageParam.Mode=1;
    cscUsageParam.DialogRefresh=1;
    cscUsageParam.Enabled=isCSCEditable;


    cscUsageSig.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabForSignals');
    cscUsageSig.Type='checkbox';
    cscUsageSig.Tag='tcscSigCheck';
    if~isempty(currCSCDefn)
        hDataUsage=currCSCDefn.getProp('DataUsage');
        cscUsageSig.Value=hDataUsage.IsSignal;
        cscUsageSig.Source=hUI;
        cscUsageSig.ObjectMethod='setPropAndDirty';
        cscUsageSig.MethodArgs={hDataUsage,'IsSignal','%value',{}};
        cscUsageSig.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscUsageSig.Mode=1;
    cscUsageSig.DialogRefresh=1;
    cscUsageSig.Enabled=isCSCEditable;


    cscType.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabType');
    cscType.Type='combobox';
    cscType.Tag='tcscTypeCombo';
    if~isempty(currCSCDefn)
        tmpEntries=findtype('CSC_Enum_CSCType');
        cscType.Entries=tmpEntries.Strings';
        if~hUI.IsAdvanceMode
            if strcmp(currCSCDefn.getProp('CSCType'),'Other')

                cscType.ToolTip=DAStudio.message('Simulink:dialog:CSCDefnToolTipAdvMode');
            else
                cscType.Entries=setdiff(cscType.Entries,'Other','stable');
            end
        end
        cscType.Value=currCSCDefn.getProp('CSCType');

        cscType.Source=hUI;
        cscType.ObjectMethod='setPropAndDirty';
        cscType.MethodArgs={currCSCDefn,'CSCType','%value',cscType.Entries};
        cscType.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscType.Mode=1;
    cscType.DialogRefresh=1;
    cscType.Enabled=isCSCEditable;


    cscMS.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabMemorySection');
    cscMS.Type='combobox';
    cscMS.Tag='tcscMsCombo';
    if~isempty(currCSCDefn)
        cscMS.Entries=msList.Entries;
        if~currCSCDefn.getProp('IsGrouped')
            cscMS.Entries=[cscMS.Entries,{'Instance specific'}];
        end

        if isempty(currCSCDefn.getProp('MemorySection'))

            currCSCDefn.MemorySection='(empty)';
        end

        if currCSCDefn.getProp('IsMemorySectionInstanceSpecific')
            cscMS.Value='Instance specific';
        else
            cscMS.Value=currCSCDefn.getProp('MemorySection');
        end


        if~ismember(cscMS.Value,cscMS.Entries)
            cscMS.Entries=[{cscMS.Value},cscMS.Entries];
        end

        cscMS.Source=hUI;
        cscMS.ObjectMethod='instanceComboFcn';
        cscMS.MethodArgs={currCSCDefn,'tcscMsCombo','%value',cscMS.Entries};

        cscMS.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscMS.Mode=1;
    cscMS.DialogRefresh=1;
    cscMS.Enabled=isCSCEditable;
    if isCSCEditable

        if(isAccessMethod(currCSCDefn)||...
            strcmp(currCSCDefn.getProp('DataInit'),'Macro'))
            cscMS.Enabled=false;


            if~strcmp(cscMS.Value,'Default')
                cscMS.Enabled=true;
            end
        end
    end


    cscScope.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabDataScope');
    cscScope.Type='combobox';
    cscScope.Tag='tcscScopeCombo';
    if~isempty(currCSCDefn)
        if isAccessMethod(currCSCDefn)
            cscScope.Entries={'Imported'};
        else
            tmpEntries=findtype('CSC_Enum_DataScope');
            cscScope.Entries=tmpEntries.Strings';
            if~currCSCDefn.getProp('IsGrouped')
                cscScope.Entries=[cscScope.Entries,{'Instance specific'}];
            end
        end

        if currCSCDefn.getProp('IsDataScopeInstanceSpecific')
            cscScope.Value='Instance specific';
        else
            cscScope.Value=currCSCDefn.getProp('DataScope');
        end


        if~ismember(cscScope.Value,cscScope.Entries)
            cscScope.Entries=[{cscScope.Value},cscScope.Entries];
        end

        cscScope.Source=hUI;
        cscScope.ObjectMethod='instanceComboFcn';
        cscScope.MethodArgs={currCSCDefn,'tcscScopeCombo','%value',cscScope.Entries};
        cscScope.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscScope.Mode=1;
    cscScope.DialogRefresh=1;
    cscScope.Enabled=isCSCEditable&&(length(cscScope.Entries)>1);


    cscInit.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabInitialization');
    cscInit.Type='combobox';
    cscInit.Tag='tcscInitCombo';
    if~isempty(currCSCDefn)
        tmpEntries=findtype('CSC_Enum_DataInit');
        cscInit.Entries=tmpEntries.Strings';
        if strcmp(currCSCDefn.getProp('CSCType'),'FlatStructure')

            cscInit.Entries=setdiff(cscInit.Entries,'Macro','stable');
        elseif strcmp(currCSCDefn.getProp('CSCType'),'AccessFunction')

            cscInit.Entries=setdiff(cscInit.Entries,'Macro','stable');
            cscInit.Entries=setdiff(cscInit.Entries,'Static','stable');
        elseif strcmp(cscScope.Value,'Imported')

            cscInit.Entries=setdiff(cscInit.Entries,'Static','stable');
        end

        if~currCSCDefn.getProp('IsGrouped')
            cscInit.Entries=[cscInit.Entries,{'Instance specific'}];
        end

        if currCSCDefn.getProp('IsDataInitInstanceSpecific')
            cscInit.Value='Instance specific';
        else
            cscInit.Value=currCSCDefn.getProp('DataInit');
        end


        if~ismember(cscInit.Value,cscInit.Entries)
            cscInit.Entries=[{cscInit.Value},cscInit.Entries];
        end

        cscInit.Source=hUI;
        cscInit.ObjectMethod='instanceComboFcn';
        cscInit.MethodArgs={currCSCDefn,'tcscInitCombo','%value',cscInit.Entries};
        cscInit.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscInit.Mode=1;
    cscInit.DialogRefresh=1;
    cscInit.Enabled=isCSCEditable;


    cscAccess.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabDataAccess');
    cscAccess.Type='combobox';
    cscAccess.Tag='tcscAccessCombo';
    if~isempty(currCSCDefn)
        if(strcmp(cscInit.Value,'Macro')||...
            strcmp(cscScope.Value,'Exported')||...
            strcmp(cscScope.Value,'File'))

            cscAccess.Entries={'Direct'};
        else
            tmpEntries=findtype('CSC_Enum_DataAccess');
            cscAccess.Entries=tmpEntries.Strings';

            if~currCSCDefn.getProp('IsGrouped')
                cscAccess.Entries=[cscAccess.Entries,{'Instance specific'}];
            end
        end

        if currCSCDefn.getProp('IsDataAccessInstanceSpecific')
            cscAccess.Value='Instance specific';
        else
            cscAccess.Value=currCSCDefn.getProp('DataAccess');
        end


        if~ismember(cscAccess.Value,cscAccess.Entries)
            cscAccess.Entries=[{cscAccess.Value},cscAccess.Entries];
        end

        cscAccess.Source=hUI;
        cscAccess.ObjectMethod='instanceComboFcn';
        cscAccess.MethodArgs={currCSCDefn,'tcscAccessCombo','%value',cscAccess.Entries};
        cscAccess.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscAccess.Mode=1;
    cscAccess.DialogRefresh=1;
    cscAccess.Enabled=isCSCEditable&&(length(cscAccess.Entries)>1);


    cscHdrCombo.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabHeaderFile');
    cscHdrCombo.Type='combobox';
    cscHdrCombo.Tag='tcscHeaderCombo';
    if~isempty(currCSCDefn)
        cscHdrCombo.Entries={'Specify'};

        if~currCSCDefn.getProp('IsGrouped')
            cscHdrCombo.Entries=[cscHdrCombo.Entries,{'Instance specific'}];
        end

        if currCSCDefn.getProp('IsHeaderFileInstanceSpecific')
            cscHdrCombo.Value='Instance specific';
        else
            cscHdrCombo.Value='Specify';
        end


        if~ismember(cscHdrCombo.Value,cscHdrCombo.Entries)
            cscHdrCombo.Entries=[{cscHdrCombo.Value},cscHdrCombo.Entries];
        end

        cscHdrCombo.Source=hUI;
        cscHdrCombo.ObjectMethod='instanceComboFcn';
        cscHdrCombo.MethodArgs={currCSCDefn,'tcscHeaderCombo','%value',cscHdrCombo.Entries};
        cscHdrCombo.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscHdrCombo.Mode=1;
    cscHdrCombo.DialogRefresh=1;
    cscHdrCombo.Enabled=isCSCEditable&&...
    ~strcmp(cscScope.Value,'File');

    cscHeader.Name=' ';
    cscHeader.Type='edit';
    cscHeader.Tag='tcscHeaderEdit';
    if~isempty(currCSCDefn)
        cscHeader.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('HeaderFile'));
        cscHeader.Source=hUI;
        cscHeader.ObjectMethod='setPropAndDirty';
        cscHeader.MethodArgs={currCSCDefn,'HeaderFile','%value',{}};
        cscHeader.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscHeader.Mode=1;
    cscHeader.DialogRefresh=1;
    cscHeader.Visible=strcmp(cscHdrCombo.Value,'Specify');
    cscHeader.Enabled=cscHeader.Visible&&cscHdrCombo.Enabled;


    cscDefnFileCombo.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabDefinitionFile');
    cscDefnFileCombo.Type='combobox';
    cscDefnFileCombo.Tag='tcscDefnFileCombo';
    if~isempty(currCSCDefn)
        cscDefnFileCombo.Entries={'Specify'};

        if~currCSCDefn.getProp('IsGrouped')
            cscDefnFileCombo.Entries=[cscDefnFileCombo.Entries,{'Instance specific'}];
        end

        if currCSCDefn.getProp('IsDefinitionFileInstanceSpecific')
            cscDefnFileCombo.Value='Instance specific';
        else
            cscDefnFileCombo.Value='Specify';
        end


        if~ismember(cscDefnFileCombo.Value,cscDefnFileCombo.Entries)
            cscDefnFileCombo.Entries=[{cscDefnFileCombo.Value},cscDefnFileCombo.Entries];
        end

        cscDefnFileCombo.Source=hUI;
        cscDefnFileCombo.ObjectMethod='instanceComboFcn';
        cscDefnFileCombo.MethodArgs={currCSCDefn,'tcscDefnFileCombo','%value',cscDefnFileCombo.Entries};
        cscDefnFileCombo.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscDefnFileCombo.Mode=1;
    cscDefnFileCombo.DialogRefresh=1;
    cscDefnFileCombo.Enabled=isCSCEditable&&...
    strcmp(cscScope.Value,'Exported')&&...
    ~strcmp(cscInit.Value,'Macro')&&...
    ~hasUserDefinedCustomAttribute(currCSCDefn,'DefinitionFile');

    cscDefnFile.Name=' ';
    cscDefnFile.Type='edit';
    cscDefnFile.Tag='tcscDefnFileEdit';
    if~isempty(currCSCDefn)
        cscDefnFile.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('DefinitionFile'));
        cscDefnFile.Source=hUI;
        cscDefnFile.ObjectMethod='setPropAndDirty';
        cscDefnFile.MethodArgs={currCSCDefn,'DefinitionFile','%value',{}};
        cscDefnFile.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscDefnFile.Mode=1;
    cscDefnFile.DialogRefresh=1;
    cscDefnFile.Visible=strcmp(cscDefnFileCombo.Value,'Specify');
    cscDefnFile.Enabled=cscDefnFile.Visible&&cscDefnFileCombo.Enabled;


    cscOwnerCombo.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabOwner');
    cscOwnerCombo.Type='combobox';
    cscOwnerCombo.Tag='tcscOwnerCombo';
    if~isempty(currCSCDefn)
        cscOwnerCombo.Entries={'Specify'};

        if~currCSCDefn.getProp('IsGrouped')
            cscOwnerCombo.Entries=[cscOwnerCombo.Entries,{'Instance specific'}];
        end

        if currCSCDefn.getProp('IsOwnerInstanceSpecific')
            cscOwnerCombo.Value='Instance specific';
        else
            cscOwnerCombo.Value='Specify';
        end


        if~ismember(cscOwnerCombo.Value,cscOwnerCombo.Entries)
            cscOwnerCombo.Entries=[{cscOwnerCombo.Value},cscOwnerCombo.Entries];
        end

        cscOwnerCombo.Source=hUI;
        cscOwnerCombo.ObjectMethod='instanceComboFcn';
        cscOwnerCombo.MethodArgs={currCSCDefn,'tcscOwnerCombo','%value',cscOwnerCombo.Entries};
        cscOwnerCombo.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscOwnerCombo.Mode=1;
    cscOwnerCombo.DialogRefresh=1;
    cscOwnerCombo.Enabled=isCSCEditable&&...
    strcmp(cscScope.Value,'Exported')&&...
    ~currCSCDefn.getProp('IsGrouped')&&...
    ~strcmp(cscInit.Value,'Macro')&&...
    ~hasUserDefinedCustomAttribute(currCSCDefn,'Owner');

    cscOwner.Name=' ';
    cscOwner.Type='edit';
    cscOwner.Tag='tcscOwnerEdit';
    if~isempty(currCSCDefn)
        cscOwner.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('Owner'));
        cscOwner.Source=hUI;
        cscOwner.ObjectMethod='setPropAndDirty';
        cscOwner.MethodArgs={currCSCDefn,'Owner','%value',{}};
        cscOwner.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscOwner.Mode=1;
    cscOwner.DialogRefresh=1;
    cscOwner.Visible=strcmp(cscOwnerCombo.Value,'Specify');
    cscOwner.Enabled=cscOwner.Visible&&cscOwnerCombo.Enabled;


    cscLatching.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabLatching');
    cscLatching.Type='combobox';
    cscLatching.Tag='tcscLatching';
    if~isempty(currCSCDefn)
        hDataUsage=currCSCDefn.getProp('DataUsage');
        if(hDataUsage.IsParameter&&(slfeature('LatchingForDataObjects')<2))

            tmpEntries=struct('Strings',{'None'});
        elseif slfeature('LatchingViaCSCs')<3
            tmpEntries=findtype('CSC_Enum_Latching1');
        else
            tmpEntries=findtype('CSC_Enum_Latching');
        end
        cscLatching.Entries=[tmpEntries.Strings',{'Instance specific'}];

        if currCSCDefn.getProp('IsLatchingInstanceSpecific')
            cscLatching.Value='Instance specific';
        else
            cscLatching.Value=currCSCDefn.getProp('Latching');
        end

        cscLatching.Source=hUI;
        cscLatching.ObjectMethod='instanceComboFcn';
        cscLatching.MethodArgs={currCSCDefn,'tcscLatchingCombo','%value',cscLatching.Entries};
        cscLatching.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscLatching.Mode=1;
    cscLatching.DialogRefresh=1;

    cscLatching.Visible=((strcmp(currCSCDefn.getProp('DataAccess'),'Direct'))&&...
    (~currCSCDefn.IsDataAccessInstanceSpecific)&&...
    (slfeature('LatchingViaCSCs')>0)&&...
    (isAccessMethod(currCSCDefn)||(slfeature('LatchingViaCSCs')>1))&&...
    (hDataUsage.IsSignal||(slfeature('LatchingForDataObjects')>1)));
    cscLatching.Enabled=isCSCEditable;


    cscCriticalSection.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabCriticalSection');
    cscCriticalSection.Type='edit';
    cscCriticalSection.Tag='tcscCriticalSection';
    if~isempty(currCSCDefn)
        cscCriticalSection.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('CriticalSection'));
        cscCriticalSection.Source=hUI;
        cscCriticalSection.Source=hUI;
        cscCriticalSection.ObjectMethod='setPropAndDirty';
        cscCriticalSection.MethodArgs={currCSCDefn,'CriticalSection','%value',{}};
        cscCriticalSection.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end

    cscCriticalSection.Visible=(cscLatching.Visible&&...
    strcmp(currCSCDefn.Latching,'Task edge')&&...
    (slfeature('LatchingViaCSCs')>3));
    cscCriticalSection.Enabled=isCSCEditable;


    cscIsReusable.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabIsReusable');
    cscIsReusable.Type='combobox';
    cscIsReusable.Tag='tcscIsReusableCombo';
    if~isempty(currCSCDefn)

        cscIsReusable.Entries={'No','Yes','Instance specific'};

        if currCSCDefn.getProp('IsReusableInstanceSpecific')
            cscIsReusable.Value='Instance specific';
        else
            if(currCSCDefn.getProp('IsReusable'))
                cscIsReusable.Value='Yes';
            else
                cscIsReusable.Value='No';
            end
        end

        cscIsReusable.Source=hUI;
        cscIsReusable.ObjectMethod='instanceComboFcn';
        cscIsReusable.MethodArgs={currCSCDefn,'tcscIsReusableCombo','%value',cscIsReusable.Entries};
        cscIsReusable.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscIsReusable.Mode=1;
    cscIsReusable.DialogRefresh=1;
    cscIsReusable.Enabled=isCSCEditable;

    hDataUsage=currCSCDefn.getProp('DataUsage');
    cscIsReusable.Visible=hDataUsage.IsSignal&&~hDataUsage.IsParameter;


    cscPreserveDimensions.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTabPreserveDimensions');
    cscPreserveDimensions.Type='combobox';
    cscPreserveDimensions.Tag='tcscPreserveDimensionsCombo';
    if~isempty(currCSCDefn)

        cscPreserveDimensions.Entries={'No','Yes','Instance specific'};

        if currCSCDefn.getProp('PreserveDimensionsInstanceSpecific')
            cscPreserveDimensions.Value='Instance specific';
        else
            if(currCSCDefn.getProp('PreserveDimensions'))
                cscPreserveDimensions.Value='Yes';
            else
                cscPreserveDimensions.Value='No';
            end
        end

        cscPreserveDimensions.Source=hUI;
        cscPreserveDimensions.ObjectMethod='instanceComboFcn';
        cscPreserveDimensions.MethodArgs={currCSCDefn,...
        'tcscPreserveDimensionsCombo','%value',cscPreserveDimensions.Entries};
        cscPreserveDimensions.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscPreserveDimensions.Mode=1;
    cscPreserveDimensions.DialogRefresh=1;
    cscPreserveDimensions.Enabled=isCSCEditable;
    cscPreserveDimensions.Visible=...
    strcmp(currCSCDefn.getProp('DataAccess'),'Direct')&&...
    ~currCSCDefn.getProp('IsDataAccessInstanceSpecific')&&...
    ~strcmp(currCSCDefn.getProp('CSCType'),'AccessFunction');

    cscSubTab1.Name=DAStudio.message('Simulink:dialog:CSCDefnGeneralTab');
    cscSubTab1.Tag='tcscSubTab1';

    cscNeedAdvGroup.RowSpan=[1,1];
    cscNeedAdvGroup.ColSpan=[1,4];
    cscName.RowSpan=[2,2];
    cscName.ColSpan=[1,2];
    cscType.RowSpan=[3,3];
    cscType.ColSpan=[1,2];
    cscUsageParam.RowSpan=[3,3];
    cscUsageParam.ColSpan=[3,3];
    cscUsageSig.RowSpan=[3,3];
    cscUsageSig.ColSpan=[4,4];
    cscMS.RowSpan=[4,4];
    cscMS.ColSpan=[1,2];
    cscScope.RowSpan=[4,4];
    cscScope.ColSpan=[3,4];
    cscInit.RowSpan=[5,5];
    cscInit.ColSpan=[1,2];
    cscAccess.RowSpan=[5,5];
    cscAccess.ColSpan=[3,4];
    cscHdrCombo.RowSpan=[6,6];
    cscHdrCombo.ColSpan=[1,2];
    cscHeader.RowSpan=[6,6];
    cscHeader.ColSpan=[3,4];
    cscDefnFileCombo.RowSpan=[7,7];
    cscDefnFileCombo.ColSpan=[1,2];
    cscDefnFile.RowSpan=[7,7];
    cscDefnFile.ColSpan=[3,4];
    cscOwnerCombo.RowSpan=[8,8];
    cscOwnerCombo.ColSpan=[1,2];
    cscOwner.RowSpan=[8,8];
    cscOwner.ColSpan=[3,4];
    cscLatching.RowSpan=[9,9];
    cscLatching.ColSpan=[1,2];
    cscCriticalSection.RowSpan=[9,9];
    cscCriticalSection.ColSpan=[3,4];
    cscPreserveDimensions.RowSpan=[10,10];
    cscPreserveDimensions.ColSpan=[1,2];
    cscIsReusable.RowSpan=[11,11];
    cscIsReusable.ColSpan=[1,2];

    cscSubTab1.Items={...
    cscNeedAdvGroup,...
    cscName,...
    cscType,...
    cscUsageParam,...
    cscUsageSig,...
    cscMS,...
    cscScope,...
    cscInit,...
    cscAccess,...
    cscHdrCombo,...
    cscHeader,...
    cscDefnFileCombo,...
    cscDefnFile,...
    cscOwnerCombo,...
    cscOwner,...
    cscPreserveDimensions,...
    cscLatching,...
    cscCriticalSection,...
cscIsReusable
    };

    numWidgets=length(cscSubTab1.Items);
    cscSubTab1.LayoutGrid=[numWidgets+1,4];
    cscSubTab1.RowStretch=[zeros(1,numWidgets),1];





    cscCmtSrc.Name=DAStudio.message('Simulink:dialog:CSCDefnCommentsTabRules');
    cscCmtSrc.Type='combobox';
    cscCmtSrc.Tag='tcscCommentCombo';
    if~isempty(currCSCDefn)
        tmpEntries=findtype('CSC_Enum_CommentSource');
        cscCmtSrc.Entries=tmpEntries.Strings';
        cscCmtSrc.Values=tmpEntries.Values;
        cscCmtSrc.Value=currCSCDefn.getProp('CommentSource');

        cscCmtSrc.Source=hUI;
        cscCmtSrc.ObjectMethod='setPropAndDirty';
        cscCmtSrc.MethodArgs=...
        {currCSCDefn,'CommentSource','%value',cscCmtSrc.Entries};
        cscCmtSrc.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscCmtSrc.Mode=1;
    cscCmtSrc.DialogRefresh=1;
    cscCmtSrc.Enabled=isCSCEditable;

    cscTypeCmt.Name=DAStudio.message('Simulink:dialog:CSCDefnCommentsTabTypeComment');
    cscTypeCmt.Type='editarea';

    cscTypeCmt.MaximumSize=[9999,50];
    cscTypeCmt.Tag='tcscTypeCommentEdit';
    if~isempty(currCSCDefn)
        cscTypeCmt.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('TypeCommentForUI'));
        cscTypeCmt.Source=hUI;
        cscTypeCmt.ObjectMethod='setPropAndDirty';
        cscTypeCmt.MethodArgs={currCSCDefn,'TypeCommentForUI','%value',{}};
        cscTypeCmt.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscTypeCmt.Mode=1;
    cscTypeCmt.DialogRefresh=1;
    cscTypeCmt.Visible=strcmp(cscCmtSrc.Value,'Specify')&&...
    ~strcmp(currCSCDefn.getProp('CSCType'),'Unstructured');
    cscTypeCmt.Enabled=...
    cscTypeCmt.Visible&&isCSCEditable;

    cscDeclCmt.Name=DAStudio.message('Simulink:dialog:CSCDefnCommentsTabDeclarationComment');
    cscDeclCmt.Type='editarea';

    cscDeclCmt.MaximumSize=[9999,50];
    cscDeclCmt.Tag='tcscDeclCommentEdit';
    if~isempty(currCSCDefn)
        cscDeclCmt.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('DeclareCommentForUI'));
        cscDeclCmt.Source=hUI;
        cscDeclCmt.ObjectMethod='setPropAndDirty';
        cscDeclCmt.MethodArgs={currCSCDefn,'DeclareCommentForUI','%value',{}};
        cscDeclCmt.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscDeclCmt.Mode=1;
    cscDeclCmt.DialogRefresh=1;
    cscDeclCmt.Visible=strcmp(cscCmtSrc.Value,'Specify');
    cscDeclCmt.Enabled=...
    cscDeclCmt.Visible&&isCSCEditable;

    cscDefnCmt.Name=DAStudio.message('Simulink:dialog:CSCDefnCommentsTabDefinitionComment');
    cscDefnCmt.Type='editarea';

    cscDefnCmt.MaximumSize=[9999,50];
    cscDefnCmt.Tag='tcscDefnCommentEdit';
    if~isempty(currCSCDefn)
        cscDefnCmt.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('DefineCommentForUI'));
        cscDefnCmt.Source=hUI;
        cscDefnCmt.ObjectMethod='setPropAndDirty';
        cscDefnCmt.MethodArgs={currCSCDefn,'DefineCommentForUI','%value',{}};
        cscDefnCmt.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscDefnCmt.Mode=1;
    cscDefnCmt.DialogRefresh=1;
    cscDefnCmt.Visible=strcmp(cscCmtSrc.Value,'Specify');
    cscDefnCmt.Enabled=...
    cscDefnCmt.Visible&&isCSCEditable;

    cscSubTab2.Name=DAStudio.message('Simulink:dialog:CSCDefnCommentsTab');
    cscSubTab2.Tag='tcscSubTab2';
    cscNeedAdvGroup.RowSpan=[1,1];
    cscNeedAdvGroup.ColSpan=[1,3];
    cscCmtSrc.RowSpan=[2,2];
    cscCmtSrc.ColSpan=[1,2];
    cscTypeCmt.RowSpan=[3,3];
    cscTypeCmt.ColSpan=[1,3];
    cscDeclCmt.RowSpan=[4,4];
    cscDeclCmt.ColSpan=[1,3];
    cscDefnCmt.RowSpan=[5,5];
    cscDefnCmt.ColSpan=[1,3];
    cscSubTab2.Items={...
    cscNeedAdvGroup,...
    cscCmtSrc,...
    cscTypeCmt,...
    cscDeclCmt,...
    cscDefnCmt,...
    };
    numWidgets=length(cscSubTab2.Items);
    cscSubTab2.LayoutGrid=[numWidgets+1,4];
    cscSubTab2.RowStretch=[zeros(1,numWidgets),1];
    cscSubTab2.ColStretch=[0,0,1];


    cscSubTab3.Visible=(~isempty(currCSCDefn)&&...
    strcmp(currCSCDefn.getProp('CSCType'),'FlatStructure'));
    cscSubTab3.Name=DAStudio.message('Simulink:dialog:CSCDefnStructAttribTabName');
    cscSubTab3.Tag='tcscSubTab3';
    structPanel=getFlatStructureTab(hUI,currCSCDefn,cscSubTab3.Visible);
    structPanel.RowSpan=[1,1];
    structPanel.ColSpan=[1,1];
    cscSubTab3.Items={structPanel};
    numWidgets=length(cscSubTab3.Items);
    cscSubTab3.LayoutGrid=[numWidgets+1,4];
    cscSubTab3.RowStretch=[zeros(1,numWidgets),1];


    cscSubTab4.Visible=(~isempty(currCSCDefn)&&...
    strcmp(currCSCDefn.getProp('CSCType'),'AccessFunction'));
    cscSubTab4.Name=DAStudio.message('Simulink:dialog:CSCDefnAccessFunctionTabName');
    cscSubTab4.Tag='tcscSubTab4';
    accessFcnPanel=getAccessFunctionTab(hUI,currCSCDefn,cscSubTab4.Visible);
    accessFcnPanel.RowSpan=[1,1];
    accessFcnPanel.ColSpan=[1,1];
    cscSubTab4.Items={accessFcnPanel};
    numWidgets=length(cscSubTab4.Items);
    cscSubTab4.LayoutGrid=[numWidgets+1,4];
    cscSubTab4.RowStretch=[zeros(1,numWidgets),1];


    cscIsGrouped.Name=DAStudio.message('Simulink:dialog:CSCDefnOthersTabIsGrouped');
    cscIsGrouped.Type='checkbox';
    cscIsGrouped.Tag='tcscGroupedCheck';
    if~isempty(currCSCDefn)
        cscIsGrouped.Value=currCSCDefn.getProp('IsGrouped');
        cscIsGrouped.Source=hUI;
        cscIsGrouped.ObjectMethod='setPropAndDirty';
        cscIsGrouped.MethodArgs={currCSCDefn,'IsGrouped','%value',{}};
        cscIsGrouped.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscIsGrouped.Mode=1;
    cscIsGrouped.DialogRefresh=1;
    cscIsGrouped.Enabled=isCSCEditable;

    cscAttrClass.Name=DAStudio.message('Simulink:dialog:CSCDefnOthersTabCSCAttribClassName');
    cscAttrClass.Type='edit';
    cscAttrClass.Tag='tcscAttrClassEdit';
    if~isempty(currCSCDefn)
        cscAttrClass.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('CSCTypeAttributesClassName'));
        cscAttrClass.Source=hUI;
        cscAttrClass.ObjectMethod='setPropAndDirty';
        cscAttrClass.MethodArgs=...
        {currCSCDefn,'CSCTypeAttributesClassName','%value',{}};
        cscAttrClass.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscAttrClass.Mode=1;
    cscAttrClass.DialogRefresh=1;
    cscAttrClass.Enabled=isCSCEditable;

    cscTLCFile.Name=DAStudio.message('Simulink:dialog:CSCDefnOthersTabTLCFileName');
    cscTLCFile.Type='edit';
    cscTLCFile.Tag='tcscTlcFileEdit';
    if~isempty(currCSCDefn)
        cscTLCFile.Value=hUI.assignOrSetEmpty(currCSCDefn.getProp('TLCFileName'));
        cscTLCFile.Source=hUI;
        cscTLCFile.ObjectMethod='setPropAndDirty';
        cscTLCFile.MethodArgs={currCSCDefn,'TLCFileName','%value',{}};
        cscTLCFile.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    cscTLCFile.Mode=1;
    cscTLCFile.DialogRefresh=1;
    cscTLCFile.Enabled=isCSCEditable;

    cscSubTab5.Visible=(~isempty(currCSCDefn)&&...
    strcmp(currCSCDefn.getProp('CSCType'),'Other'));
    cscSubTab5.Name=DAStudio.message('Simulink:dialog:CSCDefnOthersTabName');
    cscSubTab5.Tag='tcscSubTab5';

    if cscSubTab5.Visible
        cscNeedAdvGroup.RowSpan=[1,1];
        cscNeedAdvGroup.ColSpan=[1,2];
        cscIsGrouped.RowSpan=[2,2];
        cscIsGrouped.ColSpan=[1,1];
        cscTLCFile.RowSpan=[3,3];
        cscTLCFile.ColSpan=[1,2];
        cscAttrClass.RowSpan=[4,4];
        cscAttrClass.ColSpan=[1,2];

        cscSubTab5.Items={...
        cscNeedAdvGroup,...
        cscIsGrouped,...
        cscTLCFile,...
        cscAttrClass,...
        };

        if~isempty(currCSCDefn.getProp('CSCTypeAttributes'))
            hCSCTypeAttributes=currCSCDefn.getProp('CSCTypeAttributes');
            if isobject(hCSCTypeAttributes)

                otherPanel=...
                hCSCTypeAttributes.getDialogContainer(cscSubTab5.Name,isCSCEditable,hUI,currCSCDefn);
            else
                otherPanel=...
                hCSCTypeAttributes.getDialogContainer(cscSubTab5.Name,isCSCEditable,hUI);
            end
            otherPanel.RowSpan=[5,5];
            otherPanel.ColSpan=[1,2];
            cscSubTab5.Items=[cscSubTab5.Items,{otherPanel}];
        end

        numWidgets=length(cscSubTab5.Items);
        cscSubTab5.LayoutGrid=[numWidgets+1,4];
        cscSubTab5.RowStretch=[zeros(1,numWidgets),1];
    end





    cscSubTabs.Name='CSCSubTabs';
    cscSubTabs.Type='tab';
    cscSubTabs.Tag='tcscSubTabs';
    cscSubTabs.Tabs={cscSubTab1,cscSubTab2,cscSubTab3,cscSubTab4,cscSubTab5};





    if~(cscSubTab3.Visible||cscSubTab4.Visible||cscSubTab5.Visible)
        if(hUI.CSCActiveSubTab>1)
            hUI.CSCActiveSubTab=1;
        end
    end

    cscSubTabs.ActiveTab=hUI.CSCActiveSubTab;
    cscSubTabs.TabChangedCallback='cscuicallback';

end




function panel=getFlatStructureTab(hUI,hCSCDefn,isFlatStructure)





    if isFlatStructure
        hObj=hCSCDefn.getProp('CSCTypeAttributes');
    end

    panel=[];
    panel.Type='panel';
    panel.Items={};

    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnStructAttribTabStructName');
    tmpItem.Type='combobox';
    tmpItem.Tag='tcscStructNameCombo';
    tmpItem.Entries={'Specify','Instance specific'};
    if isFlatStructure
        if hObj.IsStructNameInstanceSpecific
            tmpItem.Value='Instance specific';
        else
            tmpItem.Value='Specify';
        end
        tmpItem.Source=hUI;
        tmpItem.ObjectMethod='instanceComboFcn';
        tmpItem.MethodArgs={hCSCDefn,tmpItem.Tag,'%value',tmpItem.Entries};
        tmpItem.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[1,1];
    tmpItem.ColSpan=[1,2];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=' ';
    tmpItem.Type='edit';
    tmpItem.Tag='tcscStructNameEdit';
    if isFlatStructure

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'StructName',tmpItem);
        tmpItem.Visible=~hObj.IsStructNameInstanceSpecific;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[1,1];
    tmpItem.ColSpan=[3,4];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnStructAttribTabIsTypedef');
    tmpItem.Type='checkbox';
    tmpItem.Tag='isTypedefCheckbox';
    if isFlatStructure

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'IsTypeDef',tmpItem);
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[2,2];
    tmpItem.ColSpan=[1,1];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnStructAttribTabBitPackBool');
    tmpItem.Type='checkbox';
    tmpItem.Tag='bitPackBoolCheckbox';
    if isFlatStructure

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'BitPackBoolean',tmpItem);
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[2,2];
    tmpItem.ColSpan=[3,3];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnStructAttribTabTypeTag');
    tmpItem.Type='edit';
    tmpItem.Tag='typeTagEdit';
    if isFlatStructure

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'TypeTag',tmpItem);
        tmpItem.Visible=~hObj.IsStructNameInstanceSpecific;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[3,3];
    tmpItem.ColSpan=[1,2];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnStructAttribTabTypeName');
    tmpItem.Type='edit';
    tmpItem.Tag='typeNameEdit';
    if isFlatStructure

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'TypeName',tmpItem);
        tmpItem.Visible=hObj.IsTypeDef&&~hObj.IsStructNameInstanceSpecific;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[3,3];
    tmpItem.ColSpan=[3,4];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnStructAttribTabTypeToken');
    tmpItem.Type='edit';
    tmpItem.Tag='typeTokenEdit';
    if isFlatStructure

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'TypeToken',tmpItem);
        tmpItem.Visible=~hObj.IsStructNameInstanceSpecific;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[4,4];
    tmpItem.ColSpan=[1,2];
    panel.Items=[panel.Items,{tmpItem}];

    panel.LayoutGrid=[4,4];

end


function panel=getAccessFunctionTab(hUI,hCSCDefn,isAccessFunction)





    if isAccessFunction
        hObj=hCSCDefn.getProp('CSCTypeAttributes');
    end

    panel=[];
    panel.Type='panel';
    panel.Items={};


    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnAccessFunctionGetFunction');
    tmpItem.Type='combobox';
    tmpItem.Tag='tcscGetFunctionCombo';
    tmpItem.Entries={'Specify','Instance specific'};
    if isAccessFunction
        if hObj.IsGetFunctionInstanceSpecific
            tmpItem.Value='Instance specific';
        else
            tmpItem.Value='Specify';
        end
        tmpItem.Source=hUI;
        tmpItem.ObjectMethod='instanceComboFcn';
        tmpItem.MethodArgs={hCSCDefn,tmpItem.Tag,'%value',tmpItem.Entries};
        tmpItem.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[1,1];
    tmpItem.ColSpan=[1,2];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=' ';
    tmpItem.Type='edit';
    tmpItem.Tag='tcscGetFunctionEdit';
    if isAccessFunction

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'GetFunction',tmpItem);
        tmpItem.Visible=~hObj.IsGetFunctionInstanceSpecific;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[1,1];
    tmpItem.ColSpan=[3,4];
    panel.Items=[panel.Items,{tmpItem}];


    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnAccessFunctionSetFunction');
    tmpItem.Type='combobox';
    tmpItem.Tag='tcscSetFunctionCombo';
    tmpItem.Entries={'Specify','Instance specific'};
    if isAccessFunction
        if hObj.IsSetFunctionInstanceSpecific
            tmpItem.Value='Instance specific';
        else
            tmpItem.Value='Specify';
        end
        tmpItem.Source=hUI;
        tmpItem.ObjectMethod='instanceComboFcn';
        tmpItem.MethodArgs={hCSCDefn,tmpItem.Tag,'%value',tmpItem.Entries};
        tmpItem.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[2,2];
    tmpItem.ColSpan=[1,2];
    panel.Items=[panel.Items,{tmpItem}];

    tmpItem=[];
    tmpItem.Name=' ';
    tmpItem.Type='edit';
    tmpItem.Tag='tcscSetFunctionEdit';
    if isAccessFunction

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'SetFunction',tmpItem);
        tmpItem.Visible=~hObj.IsSetFunctionInstanceSpecific;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[2,2];
    tmpItem.ColSpan=[3,4];
    panel.Items=[panel.Items,{tmpItem}];


    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnAccessDataThroughMacro');
    tmpItem.Type='checkbox';
    tmpItem.Tag='tcscAccessDataThroughMacro';
    if isAccessFunction

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'AccessDataThroughMacro',tmpItem);
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[3,3];
    tmpItem.ColSpan=[1,4];
    panel.Items=[panel.Items,{tmpItem}];

    panel.LayoutGrid=[3,4];


    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnAccessFunctionSupportsArrayAccess');
    tmpItem.Type='checkbox';
    tmpItem.Tag='tcscSupportsArrayAccessCheckbox';
    if isAccessFunction

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'SupportsArrayAccess',tmpItem);
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[4,4];
    tmpItem.ColSpan=[1,4];
    panel.Items=[panel.Items,{tmpItem}];


    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnAccessFunctionGetElementFunction');
    tmpItem.Type='edit';
    tmpItem.Tag='tcscGetElementFunctionEdit';
    if isAccessFunction

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'GetElementFunction',tmpItem);
        tmpItem.Visible=hObj.SupportsArrayAccess;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[5,5];
    tmpItem.ColSpan=[1,2];
    panel.Items=[panel.Items,{tmpItem}];


    tmpItem=[];
    tmpItem.Name=DAStudio.message('Simulink:dialog:CSCDefnAccessFunctionSetElementFunction');
    tmpItem.Type='edit';
    tmpItem.Tag='tcscSetElementFunctionEdit';
    if isAccessFunction

        tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,'SetElementFunction',tmpItem);
        tmpItem.Visible=hObj.SupportsArrayAccess;
        tmpItem.Enabled=tmpItem.Visible;
    end
    tmpItem.Mode=1;
    tmpItem.DialogRefresh=1;
    tmpItem.RowSpan=[5,5];
    tmpItem.ColSpan=[3,4];
    panel.Items=[panel.Items,{tmpItem}];

    panel.LayoutGrid=[5,4];

end


function tmpItem=setWidgetSrcToCSCUI(hUI,hObj,propName,tmpItem)



    tmpItem.Value=get(hObj,propName);

    tmpItem.Source=hUI;
    tmpItem.ObjectMethod='setPropAndDirty';
    tmpItem.MethodArgs={hObj,propName,'%value',{}};
    tmpItem.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};

end


function tmpItem=setCSCTypeAttributesWidgetSrcToCSCUI(hUI,hCSCDefn,propName,tmpItem)


    hObj=hCSCDefn.getProp('CSCTypeAttributes');


    tmpItem.Value=get(hObj,propName);


    tmpItem.Source=hUI;
    tmpItem.ObjectMethod='setCSCTypeAttributesPropAndDirty';
    tmpItem.MethodArgs={hCSCDefn,propName,'%value',{}};
    tmpItem.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};

end


function r=hasUserDefinedCustomAttribute(cscdefn,propname)



    r=false;
    obj=cscdefn.getProp('CSCTypeAttributes');
    if isempty(obj)||isa(obj,'mpt.CSCTypeAttributes_Unstructed')
        return;
    end


    props=Simulink.data.getPropList(obj);
    propnames={};
    for k=1:length(props)
        propnames{end+1}=props(k).Name;%#ok
    end

    if ismember(propname,propnames)
        r=true;
    end

end




