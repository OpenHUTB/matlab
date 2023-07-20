function dlgstruct=sigpropddg(h)










    mlock;
    persistent sigObjCache;

    if~exist('h','var')



        dlgstruct=sigObjCache;
        return;
    end

    portObj=[];
    lineObj=[];
    if(isa(h,'Simulink.Line'))
        lineObj=h;
        portObj=h.getSourcePort;

        if isempty(portObj)
            dlgstruct=loc_EmptyDialog;
            return
        end

    elseif isa(h,'Simulink.Port')
        portObj=h;


        if h.Line~=-1
            lineObj=get_param(h.Line,'Object');
        end
    end
    assert(~isempty(portObj));






















    if isempty(sigObjCache)
        sigObjCache=Simulink.SigpropDDGCache;
    end

    sourceBlock=get_param(portObj.Handle,'Parent');
    sourceModel=bdroot(sourceBlock);




    showTaskTrans=getShowTaskTrans(sourceModel);
    enabTaskTrans=getEnabTaskTrans(sourceModel);

    chkTaskTransSpec.Name=DAStudio.message('Simulink:mds:DataTransferDlgSpec');
    chkTaskTransSpec.Tag='chkTaskTransSpec';
    chkTaskTransSpec.Type='checkbox';
    chkTaskTransSpec.ObjectProperty='TaskTransitionSpecified';
    chkTaskTransSpec.Enabled=enabTaskTrans;
    chkTaskTransSpec.Source=portObj;
    chkTaskTransSpec.MatlabMethod='feval';
    chkTaskTransSpec.MatlabArgs={@taskTrans_dialog_cb,'%dialog','%source','%value'};
    taskTransSpec=strcmpi(portObj.TaskTransitionSpecified,'on');

    txtTaskTransType.Name=DAStudio.message('Simulink:mds:DataTransferDlgType');
    txtTaskTransType.Type='text';
    txtTaskTransType.Tag='cmbTaskTransType_Text';

    cmbTaskTransType.Tag='cmbTaskTransType';
    cmbTaskTransType.Type='combobox';
    cmbTaskTransType.ObjectProperty='TaskTransitionType';
    cmbTaskTransType.Enabled=enabTaskTrans&&taskTransSpec;
    cmbTaskTransType.Source=portObj;

    txtTaskTransIC.Name=DAStudio.message('Simulink:mds:DataTransferDlgIC');
    txtTaskTransIC.Type='text';
    txtTaskTransIC.Tag='editTaskTransIC_Text';

    editTaskTransIC.Tag='editTaskTransIC';
    editTaskTransIC.Type='edit';
    editTaskTransIC.ObjectProperty='TaskTransitionIC';
    editTaskTransIC.Enabled=enabTaskTrans&&taskTransSpec;
    editTaskTransIC.Source=portObj;

    txtExtrapolationMethod.Name=DAStudio.message('Simulink:mds:DataTransferDlgExtrp');
    txtExtrapolationMethod.Type='text';
    txtExtrapolationMethod.Tag='cmbExtrapolationMethod_Text';

    cmbExtrapolationMethod.Tag='cmbExtrapolationMethod';
    cmbExtrapolationMethod.Type='combobox';
    cmbExtrapolationMethod.ObjectProperty='ExtrapolationMethod';
    cmbExtrapolationMethod.Enabled=enabTaskTrans&&taskTransSpec;
    cmbExtrapolationMethod.Source=portObj;

    spacer0.Tag='spacer0';
    spacer0.Type='panel';

    tab0.Tag='tab0';
    tab0.Name=DAStudio.message('Simulink:mds:DataTransferDlgTab');
    tab0=addGroupIndexedItems(tab0,2,{...
    chkTaskTransSpec,'stretch',...
    txtTaskTransType,cmbTaskTransType,...
    txtExtrapolationMethod,cmbExtrapolationMethod,...
    txtTaskTransIC,editTaskTransIC,...
    spacer0,'stretch'});
    tab0.ColStretch=[0,1];





    tab1=createSignalLoggingTab(portObj);






    editSigObj=portObj.SignalObject;

    rowSpan=1;
    tabItems={};
    tab2Pnl.Items=tabItems;
    tab2Pnl.LayoutGrid=[rowSpan,3];
    tab2Pnl.ColSpan=[1,2];
    tab2Pnl.RowSpan=[1,1];
    tab2Pnl.ColStretch=[0,1,0];
    tab2Pnl.RowStretch=[zeros(1,rowSpan-1),1];

    tab2.Tag='tab2';
    tab2.Name=DAStudio.message('Simulink:dialog:SigpropTabTwoName');
    tab2.Items={tab2Pnl};

    tab2.LayoutGrid=[1,1];





    lblDescription.Tag='lblDescription';
    lblDescription.Type='text';
    lblDescription.Name=DAStudio.message('Simulink:dialog:SigpropLblDescriptionName');
    lblDescription.RowSpan=[1,1];

    txtDescription.Name=lblDescription.Name;
    txtDescription.HideName=true;
    txtDescription.Tag='txtDescription';
    txtDescription.Type='editarea';
    txtDescription.RowSpan=[2,2];
    txtDescription.ObjectProperty='Description';

    hypLink.Tag='hypLink';
    hypLink.Type='hyperlink';
    hypLink.Name=DAStudio.message('Simulink:dialog:SigpropHyplinkName');

    hypLink.MatlabMethod='eval';
    hypLink.MatlabArgs={portObj.documentLink};
    hypLink.RowSpan=[3,3];

    txtLink.Tag='txtLink';
    txtLink.Type='edit';
    txtLink.Name=hypLink.Name;
    txtLink.HideName=true;
    txtLink.ObjectProperty='documentLink';
    txtLink.RowSpan=[4,4];

    tab3.Tag='tab3';
    tab3.Name=DAStudio.message('Simulink:dialog:SigpropTabThreeName');
    tab3.LayoutGrid=[4,1];
    tab3.Items={lblDescription...
    ,txtDescription...
    ,hypLink...
    ,txtLink};




    lblSignalName.Tag='lblSignalName';
    lblSignalName.Name=DAStudio.message('Simulink:dialog:SigpropLblSignalNameName');
    lblSignalName.Type='text';
    lblSignalName.RowSpan=[1,1];
    lblSignalName.ColSpan=[1,1];

    txtSignalName.Tag='txtSignalName';
    txtSignalName.Type='edit';
    txtSignalName.Name=lblSignalName.Name;
    txtSignalName.HideName=true;
    txtSignalName.ObjectProperty='SignalNameFromLabel';
    txtSignalName.Mode=1;
    txtSignalName.DialogRefresh=true;
    txtSignalName.RowSpan=[1,1];
    txtSignalName.ColSpan=[2,2];

    lblShowSigProp.Tag='lblShowSigProp';
    lblShowSigProp.Name=DAStudio.message('Simulink:dialog:SigpropLblShowSigPropName');
    lblShowSigProp.Type='text';
    lblShowSigProp.RowSpan=[1,1];
    lblShowSigProp.ColSpan=[3,3];
    lblShowSigProp.Visible=portObj.supportsSignalPropagation;

    cmbShowSigProp.Tag='cmbShowSigProp';
    cmbShowSigProp.Type='combobox';
    cmbShowSigProp.Name=lblShowSigProp.Name;
    cmbShowSigProp.HideName=true;
    cmbShowSigProp.ObjectProperty='ShowPropagatedSignals';



    sourceBlock=get_param(portObj.Handle,'Parent');
    sourceBlockType=get_param(sourceBlock,'BlockType');
    if strcmp(sourceBlockType,'BusSelector')
        txtSignalName.Enabled=false;
    end
    if strcmp(sourceBlockType,'ModelReference')
        cmbShowSigProp.Values=[0,1];
        cmbShowSigProp.Entries={'off',...
        'on'};
    else
        cmbShowSigProp.Values=[0,1,2];
        cmbShowSigProp.Entries={'off',...
        'on',...
        'all'};
    end
    cmbShowSigProp.RowSpan=[1,1];
    cmbShowSigProp.ColSpan=[4,4];
    cmbShowSigProp.Visible=portObj.supportsSignalPropagation;

    chkShowSigProp.Tag='DisplayPropagatedSignalLabels';
    chkShowSigProp.Type='checkbox';
    chkShowSigProp.Name=DAStudio.message('Simulink:dialog:SigpropLblShowSigPropName');
    chkShowSigProp.Enabled=portObj.supportsSignalPropagation;
    chkShowSigProp.Value=~strcmpi(portObj.ShowPropagatedSignals,'off');
    chkShowSigProp.RowSpan=[3,3];
    chkShowSigProp.ColSpan=[1,4];

    disableMustResolveToSignalObject=isempty(portObj.Name)||...
    strcmp(sourceBlockType,'BusSelector')||...
    (strcmp(sourceBlockType,'Inport')&&...
    strcmp(get_param(sourceBlock,'IsBusElementPort'),'on'));
    chkResSigObj.Tag='MustResolveToSignalObject';
    chkResSigObj.Type='checkbox';
    chkResSigObj.Name=DAStudio.message('Simulink:dialog:SigpropChkResSigObjName');
    chkResSigObj.ObjectProperty='MustResolveToSignalObject';
    chkResSigObj.Mode=1;
    chkResSigObj.DialogRefresh=true;
    chkResSigObj.Enabled=~disableMustResolveToSignalObject;
    chkResSigObj.RowSpan=[2,2];
    chkResSigObj.ColSpan=[1,4];

    signalResolutionControl=get_param(sourceModel,'SignalResolutionControl');
    chkResSigObj.Visible=~isequal(signalResolutionControl,'None');

    tabContainer.Tag='tabContainer';
    tabContainer.Name=DAStudio.message('Simulink:dialog:SigpropTabContainerName');
    tabContainer.Type='tab';
    tabContainer.Tabs={tab1};
    if showTaskTrans
        tabContainer.Tabs=cat(2,tabContainer.Tabs,tab0);
    end
    tabContainer.Tabs=cat(2,tabContainer.Tabs,tab3);
    tabContainer.RowSpan=[4,4];
    tabContainer.ColSpan=[1,4];

    tabContainer.ActiveTab=sigObjCache.ActiveTab;
    tabContainer.TabChangedCallback='cscuicallback';

    activeTabHelper.Tag=[tabContainer.Tag,'_ActiveTabHelper'];
    activeTabHelper.Name='';
    activeTabHelper.Type='text';
    activeTabHelper.Visible=false;
    activeTabHelper.UserData=sigObjCache;
    activeTabHelper.RowSpan=[5,5];
    activeTabHelper.ColSpan=[4,4];






    listener.Type='edit';
    listener.Visible=0;
    listener.RowSpan=[5,5];
    listener.ColSpan=[1,4];

    if~isempty(lineObj)
        cls=metaclass(lineObj);
        props={cls.PropertyList.Name}';

        listener.Source=lineObj;
        listener.ListenToProperties=props';
    end







    dlgstruct.DialogTag=strcat('Port Properties: ',num2str(portObj.handle,16));

    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:SigpropPortObjDlgStructDialogTitle',portObj.Name);

    sourceBusMode=get_param(sourceModel,'StrictBusMsg');
    if(~strcmpi(sourceBusMode,'None')&&~strcmpi(sourceBusMode,'Warning'))
        dlgstruct.Items={lblSignalName,txtSignalName,...
        chkResSigObj,...
        chkShowSigProp,...
        tabContainer,...
        listener};
    else
        dlgstruct.Items={lblSignalName,txtSignalName,...
        chkResSigObj,...
        lblShowSigProp,cmbShowSigProp,...
        tabContainer,...
        listener};
    end

    dlgstruct.Items=[dlgstruct.Items,{activeTabHelper}];
    dlgstruct.LayoutGrid=[5,4];
    dlgstruct.RowStretch=[0,1,0,1,0];
    dlgstruct.ColStretch=[0,1,0,0];

    if isa(portObj,'handle')
        dlgstruct.Source=portObj;
    end

    dlgstruct.PreApplyCallback='sigprop_ddg_cb';
    dlgstruct.PreApplyArgs={'preapply_cb',portObj,sigObjCache,'%dialog'};

    dlgstruct.PostApplyCallback='sigprop_ddg_cb';
    dlgstruct.PostApplyArgs={'postapply_cb',portObj,lineObj};

    dlgstruct.CloseCallback='sigprop_ddg_cb';
    dlgstruct.CloseArgs={'close_cb',portObj,'%closeaction',sigObjCache,'%dialog'};



    dlgstruct.PostRevertCallback='sigprop_ddg_cb';
    dlgstruct.PostRevertArgs={'postrevert_cb',portObj,lineObj,sigObjCache};

    dlgstruct.DisableDialog=~isa(portObj,'handle')||...
    h.isHierarchySimulating;
    dlgstruct.HelpMethod='slprophelp';
    dlgstruct.HelpArgs={'signal'};

    dlgstruct.DialogRefresh=true;

    dlgstruct.OpenCallback=@(dlg)dlgOpenCallback(dlg,sourceModel,sourceBlock,portObj);
end



function dlgOpenCallback(dlg,sourceModel,sourceBlock,portObj)
    [~,enableMappingProperties]=Simulink.CodeMapping.isCompatible(sourceModel,sourceBlock);
    if enableMappingProperties
        Simulink.CodeMapping.add_mapping_listener(sourceModel,sourceBlock,dlg,portObj);
    end


    if~isempty(portObj)&&isReadonlyProperty(portObj,'Name')
        dlg.setEnabled('txtSignalName',false);
    end

end


function ret=convertToBool(x)
    if(isa(x,'logical'))
        ret=x;
    else

        ret=strcmp(x,'on');
    end
end





function sigprop_add_listener(lineObj,sigObjCache)
    openHandleIdx=length(sigObjCache.Editing{3})+1;
    assert(~isempty(sigObjCache.Editing{1}(openHandleIdx)));

    if isempty(lineObj)
        propertyChangedEventListener=[];
    else
        propertyChangedEventListener=event.listener(lineObj,...
        'LinePropertyChangedEvent',...
        @(s,e)handle_property_changed_event(openHandleIdx,sigObjCache));
    end

    sigObjCache.Editing{3}=[sigObjCache.Editing{3},{propertyChangedEventListener}];
end










function handle_property_changed_event(~,eventData,openHandleIdx,sigObjCache)
    lineObj=eventData.Source;

    assert(~isempty(lineObj)&&(lineObj.isa('Simulink.Line')));
    portObj=lineObj.getSourcePort;
    if(portObj==sigObjCache.Editing{1}(openHandleIdx))
        sigprop_backup_RTWInfo(sigObjCache,openHandleIdx,portObj);
    end
end




function w=addGroupIndexedItems(w,N,items)

    [items,layout]=slprivate('getIndexedGroupItems',N,items);
    w.Items=items;
    w.LayoutGrid=layout;
    w.ColStretch=ones(1,N);

end




function show=getShowTaskTrans(bd)
    show=DeploymentDiagram.isConcurrentTasks(bd);
end




function enab=getEnabTaskTrans(bd)
    enab=(getShowTaskTrans(bd)&&...
    strcmp(get_param(bd,'ExplicitPartitioning'),'on'));
end




function taskTrans_dialog_cb(dialog,source,value)
    if logical(value)
        source.TaskTransitionSpecified=true;

        val=loc_comboboxIndexOfProp(source,'TaskTransitionType');
        if val~=dialog.getWidgetValue('cmbTaskTransType')
            dialog.setWidgetValue('cmbTaskTransType',val);
        end
        val=loc_comboboxIndexOfProp(source,'ExtrapolationMethod');
        if val~=dialog.getWidgetValue('cmbExtrapolationMethod')
            dialog.setWidgetValue('cmbExtrapolationMethod',val);
        end
        val=source.TaskTransitionIC;
        if~strcmp(val,dialog.getWidgetValue('editTaskTransIC'))
            dialog.setWidgetValue('editTaskTransIC',val);
        end

        dialog.setEnabled('cmbTaskTransType',true);
        dialog.setEnabled('cmbExtrapolationMethod',true);
        dialog.setEnabled('editTaskTransIC',true);
    else
        if dialog.getWidgetValue('cmbTaskTransType')~=0
            dialog.setWidgetValue('cmbTaskTransType',0);
        end
        if dialog.getWidgetValue('cmbExtrapolationMethod')~=0
            dialog.setWidgetValue('cmbExtrapolationMethod',0);
        end
        if~strcmp(dialog.getWidgetValue('editTaskTransIC'),'0')
            dialog.setWidgetValue('editTaskTransIC','0');
        end

        dialog.setEnabled('cmbTaskTransType',false);
        dialog.setEnabled('cmbExtrapolationMethod',false);
        dialog.setEnabled('editTaskTransIC',false);
    end
end


function cscList_cmbbox_cb(dialog,cmbTag,portObj,cmbEntries)
    selectedItem=cmbEntries{dialog.getWidgetValue(cmbTag)+1};
    oldVal=loc_comboboxIndexOfProp(portObj,'StorageClass');
    if strcmp(selectedItem,DAStudio.message('Simulink:Data:ChangeCSCPackageNameMenuItem'))
        dialog.setWidgetValue(cmbTag,oldVal);
    end
    if~strcmp(portObj.getPropValue('StorageClass'),selectedItem)
        portObj.setPropValue('StorageClass',selectedItem);
    end

end

function fullClassname_cmbbox_cb(dialog,cmbTag,portObj,cmbEntries)
    selectedItem=cmbEntries{dialog.getWidgetValue(cmbTag)+1};
    oldVal=loc_comboboxIndexOfProp(portObj,'SignalObjectClass');
    if strcmp(selectedItem,DAStudio.message('Simulink:Signals:SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM'))
        dialog.setWidgetValue(cmbTag,oldVal);
    end
    if~strcmp(portObj.getPropValue('SignalObjectClass'),selectedItem)
        portObj.setPropValue('SignalObjectClass',selectedItem);
    end
end




function idx=loc_comboboxIndexOfProp(obj,prop)

    idx=0;
    cnt=0;
    if strcmp(prop,'SignalObjectClass')
        values=configset.ert.getSigAttribFullClassList(obj.SignalObjectClass,true);
    else
        values=getPropAllowedValues(obj,prop);
    end
    value=get(obj,prop);
    for i=1:length(values)
        if strcmp(values{i},value)
            idx=cnt;
            return;
        end
        cnt=cnt+1;
    end
end


function dlgstruct=loc_EmptyDialog

    txt.Name=DAStudio.message('Simulink:dialog:SigpropEmptyPortObjTxtName');
    txt.Type='text';
    txt.RowSpan=[1,1];
    txt.WordWrap=true;
    txt.Tag='Txt';
    spacer.Type='panel';
    spacer.RowSpan=[2,2];
    spacer.Tag='Spacer';
    dlgstruct.Items={txt,spacer};
    dlgstruct.LayoutGrid=[2,1];
    dlgstruct.RowStretch=[0,1];
    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:SigpropEmptyPortObjDialogTitle');
end





