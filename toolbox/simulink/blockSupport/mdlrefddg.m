function dlgStruct=mdlrefddg(source,h,varargin)






    if nargin>2
        isSlimDialog=varargin{1};
    else
        isSlimDialog=false;
    end

    disableWholeDialog=source.isHierarchyReadonly;

    if~disableWholeDialog

        disableWholeDialog=strcmp(h.LinkStatus,'resolved');
    end

    if~disableWholeDialog
        [~,isLocked]=source.isLibraryBlock(h);
        disableWholeDialog=isLocked;
    end


    paramGrp=i_GetParamGroup(source,h,disableWholeDialog,...
    isSlimDialog);




    dlgStruct.DialogTag='ModelReference';
    if isSlimDialog
        dlgStruct.Items=paramGrp.Items;
        dlgStruct.LayoutGrid=[1,1];
        dlgStruct.DialogMode='Slim';
    else

        descGrp=i_GetDescGroup(source);

        dlgStruct.Items={descGrp,paramGrp};
        dlgStruct.LayoutGrid=[2,1];
        dlgStruct.RowStretch=[0,1];
    end


    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    if~isSlimDialog

        dlgStruct.PreApplyCallback='mdlrefddg_cb';
        dlgStruct.PreApplyArgs={'doPreApply','%dialog'};
        dlgStruct.CloseCallback='mdlrefddg_cb';
        dlgStruct.CloseArgs={'doClose','%dialog'};
    end


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    dlgStruct.DisableDialog=disableWholeDialog;
    dlgStruct.DefaultOk=false;


    blockPath=gcbp;
    if(blockPath.getLength()==0)
        lastBlock='';
    else
        lastBlock=blockPath.getBlock(blockPath.getLength());
    end
    block=h.getFullName();





    if(strcmp(lastBlock,block))
        source.UserData.gcbp=blockPath;
    else
        source.UserData.gcbp=Simulink.BlockPath({block});
    end
end


function i_CacheUserData(source,h,disableWholeDialog)


    blkHandle=h.Handle;
    parentHandle=get_param(get_param(blkHandle,'Parent'),'Handle');
    isVSSChoiceBlock=slInternal('isVariantSubsystem',parentHandle);
    myData=source.UserData;
    myData.DisableWholeDialog=disableWholeDialog;
    myData.IsVSSChoiceBlock=isVSSChoiceBlock;


    source.UserData=myData;
end



function mainPanel=i_GetMainPanel(source,h,isSlimDialog)

    showVariantsItems=~source.UserData.IsVSSChoiceBlock;

    parent=get_param(h.Handle,'Parent');
    isComposition=strcmp(get_param(parent,'SimulinkSubDomain'),'Architecture')||...
    strcmp(get_param(parent,'SimulinkSubDomain'),'SoftwareArchitecture');


    pModelName=i_GetProperty(source,h,'ModelNameDialog',isSlimDialog);
    pModelName.NameLocation=2;
    pModelName.RowSpan=[1,1];
    pModelName.ColSpan=[1,1];
    pModelName.Enabled=mdlrefddg_cb('EnableModelName',source,h);

    pModelBrowse.Name=DAStudio.message('Simulink:dialog:ModelRefBrowse');
    pModelBrowse.Alignment=10;
    pModelBrowse.Type='pushbutton';
    pModelBrowse.RowSpan=[1,1];
    pModelBrowse.ColSpan=[2,2];
    pModelBrowse.Enabled=mdlrefddg_cb('EnableBrowse',h);
    pModelBrowse.Tag='ModelBrowse';
    pModelBrowse.MatlabMethod='mdlrefddg_cb';
    pModelBrowse.MatlabArgs={'doBrowse','%dialog','ModelNameDialog',isSlimDialog};

    pModelOpen.Name=DAStudio.message('Simulink:dialog:ModelRefOpen');
    pModelOpen.Alignment=10;
    pModelOpen.Type='pushbutton';
    pModelOpen.RowSpan=[1,1];
    pModelOpen.ColSpan=[3,3];
    pModelOpen.Enabled=mdlrefddg_cb('EnableOpen',h,'');
    pModelOpen.Tag='ModelOpen';
    pModelOpen.MatlabMethod='mdlrefddg_cb';
    pModelOpen.MatlabArgs={'doOpen','%dialog'};


    if isSlimDialog
        rowIdx=1;


        pMainPanel.Type='togglepanel';
        pMainPanel.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefMainToggle');
        pMainPanel.RowSpan=[1,1];
        pMainPanel.ColSpan=[1,2];
        pMainPanel.Expand=1;
        pMainPanel.Tag='Main_togglepanel';

        [pModelNameLabel,pModelName]=convertWidgetToSlim(pModelName);


        rowIdx=rowIdx+1;
        pButtonPanel.Name='';
        pButtonPanel.Type='panel';
        pButtonPanel.LayoutGrid=[1,3];
        pButtonPanel.RowSpan=[rowIdx,rowIdx];
        pButtonPanel.ColSpan=[1,2];
        pButtonPanel.ColStretch=[1,0,0];


        buttonspacer.Name='';
        buttonspacer.Type='text';
        buttonspacer.RowSpan=[1,1];
        buttonspacer.ColSpan=[1,1];

        pModelBrowse.ColSpan=[2,2];
        pModelOpen.ColSpan=[3,3];
        pButtonPanel.Items={buttonspacer,pModelOpen,pModelBrowse};

        tmpItems={pModelNameLabel,pModelName,pButtonPanel};
    else
        rowIdx=1;
        pModelNamePanel.Name='';
        pModelNamePanel.Type='panel';
        pModelNamePanel.LayoutGrid=[1,3];
        pModelNamePanel.RowSpan=[rowIdx,rowIdx];
        pModelNamePanel.ColStretch=[1,0,0];
        pModelNamePanel.Items={pModelName,pModelBrowse,pModelOpen};

        tmpItems={pModelNamePanel};
    end


    rowIdx=rowIdx+1;
    pSimMode=i_GetProperty(source,h,'SimulationMode',isSlimDialog);
    pSimMode.RowSpan=[rowIdx,rowIdx];
    pSimMode.Enabled=mdlrefddg_cb('EnableSimulationMode',source,h.ModelNameDialog);

    pSimMode.MatlabMethod='mdlrefddg_cb';
    pSimMode.MatlabArgs={'doSimulationMode','%dialog',isSlimDialog};

    pSimMode.DialogRefresh=true;


    if isfield(source.UserData,'CodeInterfaceActive')


        codeInterfaceActive=source.UserData.CodeInterfaceActive;
    else


        if any(strcmp(source.get_param('SimulationMode'),{'Software-in-the-loop (SIL)',...
            'Processor-in-the-loop (PIL)'}))
            codeInterfaceActive=true;
        else
            codeInterfaceActive=false;
        end
    end
    if codeInterfaceActive
        rowIdx=rowIdx+1;
    end
    pCodeInterface=i_GetProperty(source,h,'CodeInterface',isSlimDialog);
    pCodeInterface.RowSpan=[rowIdx,rowIdx];
    pCodeInterface.Visible=codeInterfaceActive;
    pCodeInterface.Enabled=~source.isHierarchySimulating;




    if pCodeInterface.Visible
        isProtected=slInternal('getReferencedModelFileInformation',h.ModelNameDialog);
        if isProtected
            opts=Simulink.ModelReference.ProtectedModel.getOptions(h.ModelNameDialog,'runNoConsistencyChecks');
            if~isempty(opts)
                h.setPropValue('CodeInterface',opts.codeInterface);
                pCodeInterface.Enabled=false;
            end
        end
    end

    rowIdx=rowIdx+1;
    pVariantControl=i_GetProperty(source,h,'VariantControl',isSlimDialog);
    pVariantControl.NameLocation=2;
    pVariantControl.RowSpan=[rowIdx,rowIdx];
    pVariantControl.Enabled=~source.isHierarchySimulating&&~slInternal('IsChildOfVAS',source.getBlock.Handle);
    pVariantControl.Visible=~showVariantsItems;

    if isSlimDialog
        [pVarControlName,pVariantControl]=convertWidgetToSlim(pVariantControl);
        pVariantControl={pVarControlName,pVariantControl};
    end


    if isSlimDialog
        numItemsInMainPanel=rowIdx;
        rowIdx=0;
    end

    isExportFcn=...
    strcmp(get_param(h.Handle,'IsModelRefExportFunction'),'on');
    isAutosarComposition=strcmp(get_param(bdroot(h.Path),'SimulinkSubDomain'),...
    'AUTOSARArchitecture');
    supportIRTPorts=false;
    supportPeriodicEventPorts=false;
    usingScheduleEditor=false;
    modelPartitions=(mdlrefddg_cb('SupportExportedPartitions',h.Handle)||...
    strcmp(get_param(h.Handle,'ScheduleRatesWith'),'Schedule Editor'))&&~isComposition;
    showSchedulingOptions=~Simulink.harness.internal.isHarnessCUT(h.handle);

    supportPeriodicEventPorts=...
    mdlrefddg_cb('SupportPeriodicEventPorts',h.Handle)&&~isComposition;
    usingScheduleEditor=modelPartitions&&...
    strcmp(get_param(h.Handle,'ScheduleRates'),'on')&&...
    ~strcmp(get_param(h.Handle,'ScheduleRatesWith'),'Ports');

    supportIRTPorts=mdlrefddg_cb('SupportIRTPorts',h.Handle)&&~isComposition&&~isAutosarComposition;
    if~isSlimDialog
        rowIdx=rowIdx+1;
        mdlEventsHeader.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefModelEventsSimulation');
        mdlEventsHeader.Type='text';
        mdlEventsHeader.RowSpan=[rowIdx,rowIdx];
        mdlEventsHeader.ColSpan=[1,1];
    end

    rowIdx=rowIdx+1;
    pShowMdlInitPortCheckbox=i_GetProperty(source,h,'ShowModelInitializePort',isSlimDialog);
    pShowMdlInitPortCheckbox.RowSpan=[rowIdx,rowIdx];
    pShowMdlInitPortCheckbox.Visible=supportIRTPorts;
    pShowMdlInitPortCheckbox.Enabled=supportIRTPorts&&~usingScheduleEditor;
    pShowMdlInitPortCheckbox.DialogRefresh=true;

    hasMdlReinitEvent=false;
    if slfeature('SupportResetWithInit')
        rowIdx=rowIdx+1;
        containsReinitEvents=i_HasReinitEvent(h);
        pShowMdlReinitPortsCheckbox=i_GetProperty(source,h,'ShowModelReinitializePorts',isSlimDialog);
        pShowMdlReinitPortsCheckbox.RowSpan=[rowIdx,rowIdx];
        pShowMdlReinitPortsCheckbox.Visible=supportIRTPorts&&containsReinitEvents;
        pShowMdlReinitPortsCheckbox.Enabled=...
        supportIRTPorts&&containsReinitEvents&&~usingScheduleEditor;
        pShowMdlReinitPortsCheckbox.DialogRefresh=true;
        hasMdlReinitEvent=strcmp(get_param(h.Handle,'ShowModelReinitializePorts'),'on')&&containsReinitEvents;
    end

    rowIdx=rowIdx+1;
    containsResetEvents=i_HasGenericEvent(h);
    pShowMdlResetPortsCheckbox=i_GetProperty(source,h,'ShowModelResetPorts',isSlimDialog);
    pShowMdlResetPortsCheckbox.RowSpan=[rowIdx,rowIdx];
    pShowMdlResetPortsCheckbox.Visible=supportIRTPorts&&containsResetEvents;
    pShowMdlResetPortsCheckbox.Enabled=...
    supportIRTPorts&&containsResetEvents&&~usingScheduleEditor;
    pShowMdlResetPortsCheckbox.DialogRefresh=true;
    hasMdlResetEvent=strcmp(get_param(h.Handle,'ShowModelResetPorts'),'on')&&containsResetEvents;

    rowIdx=rowIdx+1;
    pShowMdlTermPortCheckbox=i_GetProperty(source,h,'ShowModelTerminatePort',isSlimDialog);
    pShowMdlTermPortCheckbox.RowSpan=[rowIdx,rowIdx];
    hasMdlInitPort=strcmp(get_param(h.Handle,'ShowModelInitializePort'),'on');
    pShowMdlTermPortCheckbox.Visible=supportIRTPorts;
    pShowMdlTermPortCheckbox.Enabled=...
    supportIRTPorts&&hasMdlInitPort&&~usingScheduleEditor;
    pShowMdlTermPortCheckbox.DialogRefresh=true;

    showingScheduleDisabledExplanation=false;
    rowIdx=rowIdx+1;
    pScheduleRatesCheckbox=i_GetProperty(...
    source,h,'ScheduleRates',isSlimDialog);
    pScheduleRatesCheckbox.RowSpan=[rowIdx,rowIdx];
    pScheduleRatesCheckbox.Visible=showSchedulingOptions&&...
    (supportPeriodicEventPorts||modelPartitions);
    pScheduleRatesCheckbox.Enabled=...
    ~source.isHierarchySimulating&&~isExportFcn&&...
    ~isAutosarComposition&&~isComposition;
    pScheduleRatesCheckbox.DialogRefresh=true;


    scheduleRatesValue=Simulink.internal.SlimDialog.getParamValueFromCustomDDGDialog(source,'ScheduleRates');
    isExportingRates=strcmp(scheduleRatesValue,'on');

    isExportingPartitions=...
    strcmp(get_param(h.Handle,'ScheduleRatesWith'),'Schedule Editor');




    showingIRTPorts=(hasMdlInitPort||hasMdlReinitEvent||hasMdlResetEvent)&&...
    ~isAutosarComposition;

    if~modelPartitions&&sltp.BlockAccess(h.Handle).isValidModelBlockForPartitioning(false)&&~isComposition
        showingScheduleDisabledExplanation=true;
    end

    rowIdx=rowIdx+1;
    pScheduleRatesWith=i_GetProperty(source,h,'ScheduleRatesWith',isSlimDialog);
    pScheduleRatesWith.RowSpan=[rowIdx,rowIdx];



    pScheduleRatesWith.Enabled=...
    ~source.isHierarchySimulating&&~showingIRTPorts&&(isExportingPartitions||...
    sltp.BlockAccess(h.Handle).isValidModelBlockForPartitioning(true))&&...
    ~isAutosarComposition&&~isComposition;
    pScheduleRatesWith.Visible=...
    isExportingRates&&...
    (modelPartitions||showingScheduleDisabledExplanation)&&...
    showSchedulingOptions;
    pScheduleRatesWith.DialogRefresh=true;




    if~pScheduleRatesWith.Visible
        showingScheduleDisabledExplanation=false;
    end

    if(strcmp(get_param(h.Handle,'ScheduleRatesWith'),'Partitions'))
        set_param(h.Handle,'ScheduleRatesWith','Schedule Editor');
    end



    if showingScheduleDisabledExplanation


        iScheduleDisabledIcon.Type='pushbutton';
        iScheduleDisabledIcon.Tag='schedule_disabled_hint_button';
        iScheduleDisabledIcon.FilePath=...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','help.png');
        iScheduleDisabledIcon.RowSpan=[1,1];
        iScheduleDisabledIcon.ColSpan=[2,2];
        iScheduleDisabledIcon.MatlabMethod='helpview';
        iScheduleDisabledIcon.MatlabArgs={[docroot,'/toolbox/simulink/helptargets.map'],'ExportFunctionConversion'};




        comboboxHintPanel.Type='panel';
        comboboxHintPanel.Tag='schedule_rates_with_combobox_and_hint_panel';
        comboboxHintPanel.LayoutGrid=[1,3];
        comboboxHintPanel.RowStretch=0;



        comboboxHintPanel.RowSpan=pScheduleRatesWith.RowSpan;

        if isSlimDialog


            [pExportName,pScheduleRatesWith]=convertWidgetToSlim(pScheduleRatesWith);

            comboboxHintPanel.ColSpan=pScheduleRatesWith.ColSpan;
            comboboxHintPanel.ColStretch=[1,0,0];

            pScheduleRatesWith.RowSpan=[1,1];
            pScheduleRatesWith.ColSpan=[1,1];

            comboboxHintPanel.Items={pScheduleRatesWith,iScheduleDisabledIcon};

            pScheduleRatesWith={pExportName,comboboxHintPanel};
        else

            comboboxHintPanel.ColSpan=[1,1];
            comboboxHintPanel.ColStretch=[0,0,1];
            pScheduleRatesWith.RowSpan=[1,1];
            pScheduleRatesWith.ColSpan=[1,1];

            comboboxHintPanel.Items={pScheduleRatesWith,iScheduleDisabledIcon};

            pScheduleRatesWith=comboboxHintPanel;
        end

    elseif isSlimDialog

        [pExportName,pScheduleRatesWith]=convertWidgetToSlim(pScheduleRatesWith);
        pScheduleRatesWith={pExportName,pScheduleRatesWith};
    end

    if isSlimDialog
        [pSimModeName,pSimMode]=convertWidgetToSlim(pSimMode);
        pSimMode={pSimModeName,pSimMode};
    end

    tmpItems=[tmpItems,pSimMode];

    if(slfeature('SampleTimeParameterization')>0)
        supportSampleTimeParameterization=mdlrefddg_cb('SupportSampleTimeParameterization',h.Handle);

        if supportSampleTimeParameterization
            rowIdx=rowIdx+1;
            pBaseRate=i_GetProperty(source,h,'BaseRate',isSlimDialog);
            pBaseRate.RowSpan=[rowIdx,rowIdx];
            pBaseRate.Visible=true;
            pBaseRate.Enabled=true;
            pBaseRate.DialogRefresh=true;

            if isSlimDialog
                [pBaseRateName,pBaseRate]=convertWidgetToSlim(pBaseRate);
                pBaseRate={pBaseRateName,pBaseRate};
            end

            tmpItems=[tmpItems,pBaseRate];
        end
    end

    if codeInterfaceActive
        if isSlimDialog
            [pCodeInterfaceName,pCodeInterface]=convertWidgetToSlim(pCodeInterface);
            pCodeInterface={pCodeInterfaceName,pCodeInterface};
        end
        tmpItems=[tmpItems,pCodeInterface];
    end

    tmpItems=[tmpItems,pVariantControl];

    if isSlimDialog

        pMainPanel.LayoutGrid=[numItemsInMainPanel,2];
        pMainPanel.RowStretch=[zeros(1,numItemsInMainPanel-1),1];
        pMainPanel.ColStretch=[4,5];
        pMainPanel.Items=tmpItems;
        tmpItems={};
    end

    if(supportIRTPorts||supportPeriodicEventPorts)&&...
        ~isSlimDialog
        tmpItems=[tmpItems,mdlEventsHeader];
    end
    if supportIRTPorts
        tmpItems=[tmpItems,pShowMdlInitPortCheckbox];
        if slfeature('SupportResetWithInit')
            tmpItems=[tmpItems,pShowMdlReinitPortsCheckbox];
        end
        tmpItems=[tmpItems,pShowMdlResetPortsCheckbox];
        tmpItems=[tmpItems,pShowMdlTermPortCheckbox];
    end
    if showSchedulingOptions&&...
        (supportPeriodicEventPorts||modelPartitions||showingScheduleDisabledExplanation)
        tmpItems=[tmpItems,pScheduleRatesCheckbox];
        tmpItems=[tmpItems,pScheduleRatesWith];
    end

    addSpacer=~isSlimDialog;

    if isSlimDialog

        numItemsInInterfacePanel=rowIdx;

        rowIdx=2;
        pInterfacePanel.Type='togglepanel';
        pInterfacePanel.Tag='Interface_togglepanel';
        pInterfacePanel.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefModelEventsSimulationToggle');
        pInterfacePanel.RowSpan=[rowIdx,rowIdx];
        pInterfacePanel.ColSpan=[1,2];
        pInterfacePanel.Expand=0;
        pInterfacePanel.LayoutGrid=[numItemsInInterfacePanel,1];
        pInterfacePanel.RowStretch=[zeros(1,numItemsInInterfacePanel-1),1];
        pInterfacePanel.Items=tmpItems;
        pInterfacePanel.Visible=(supportIRTPorts||supportPeriodicEventPorts);
        pInterfacePanel.Enabled=(supportIRTPorts||supportPeriodicEventPorts);



        rowIdx=rowIdx+1;
        pArgsPanel.Type='togglepanel';
        pArgsPanel.Tag='Arguments_togglepanel';
        pArgsPanel.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefModelParametersToggle');
        pArgsPanel.RowSpan=[rowIdx,rowIdx+1];
        pArgsPanel.ColSpan=[1,2];
        pArgsPanel.Expand=0;
        pArgsPanel.LayoutGrid=[1,1];


        paramTab=mdlrefddg_InstParamTab(source,isSlimDialog);
        argsWidget=paramTab.getInstParamTab();
        argsItems=argsWidget.Items{1}.Items;



        addSpacer=argsItems{1}.Visible;

        pArgsPanel.Items=argsItems;

        rowIdx=rowIdx+1;


        if slfeature('MultiSolverSimulationSupport')>1
            rowIdx=rowIdx+1;
            pSolverPanel.Type='togglepanel';
            pSolverPanel.Tag='Arguments_localSolverTogglePanel';
            pSolverPanel.Name='Solver';
            pSolverPanel.RowSpan=[rowIdx,rowIdx];
            pSolverPanel.ColSpan=[1,2];
            pSolverPanel.Expand=0;
            pSolverPanel.LayoutGrid=[1,1];

            disableWholeDialog=source.isHierarchyReadonly;
            localSolverTab=mdlrefddg_LocalSolverTab(source,h,isSlimDialog,disableWholeDialog);
            localSolverWidget=localSolverTab.getLocalSolverTab();
            localSolverItems=localSolverWidget.Items{1}.Items;
            addSpacer=localSolverItems{1}.Visible;
            pSolverPanel.Items=localSolverItems;
        end

    end



    if addSpacer

        rowIdx=rowIdx+1;
        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
    end

    if isSlimDialog
        tmpItems={pMainPanel,pInterfacePanel,pArgsPanel};

        if slfeature('MultiSolverSimulationSupport')>1
            tmpItems=[tmpItems,pSolverPanel];
        end

    end


    numCols=1;
    if isSlimDialog
        numCols=2;
    end
    paramPanel.Type='panel';
    paramPanel.LayoutGrid=[rowIdx,numCols];
    paramPanel.RowStretch=[zeros(1,rowIdx-1),1];
    paramPanel.RowSpan=[1,1];
    paramPanel.ColSpan=[1,1];
    paramPanel.Items=tmpItems;

    if isSlimDialog
        paramPanel.ColStretch=[0,1];
        mainPanel=paramPanel;
    else
        mainPanel.Type='panel';
        mainPanel.LayoutGrid=[1,1];
        mainPanel.Items={paramPanel};
    end
end



function property=i_GetProperty(source,h,propName,isSlimDialog)



    property.ObjectProperty=propName;
    property.Tag=propName;


    property.Name=h.IntrinsicDialogParameters.(propName).Prompt;


    switch lower(h.IntrinsicDialogParameters.(propName).Type)
    case 'enum'
        property.Type='combobox';
        property.Entries=h.getPropAllowedValues(propName,true);
        property.MatlabMethod='handleComboSelectionEvent';
    case 'boolean'
        property.Type='checkbox';
        property.MatlabMethod='handleCheckEvent';
    otherwise
        property.Type='edit';
        property.MatlabMethod='handleEditEvent';
    end

    if isSlimDialog
        property.MatlabMethod='slDialogUtil';
        property.MatlabArgs={source,'sync','%dialog',property.Type,'%tag'};
    else
        property.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};
    end
end



function paramGrp=i_GetParamGroup(source,h,disableWholeDialog,...
    isSlimDialog)
    i_CacheUserData(source,h,disableWholeDialog);


    if isSlimDialog
        mainTab=i_GetMainTab(source,h,isSlimDialog);
    else
        mainTab.Tag='TabbarOfParameterArgumentValues';
        mainTab.Type='tab';
        mainTab.RowSpan=[2,2];
        mainTab.ColSpan=[1,1];
        mainTab.Source=h;
        mainTab.Tabs={};
        mainTab.Tabs{end+1}=i_GetMainTab(source,h,isSlimDialog);


        paramTab=mdlrefddg_InstParamTab(source,isSlimDialog);
        mainTab.Tabs{end+1}=paramTab.getInstParamTab();


        localSolverTab=mdlrefddg_LocalSolverTab(source,h,isSlimDialog,disableWholeDialog);
        localSolverTab_tab=localSolverTab.getLocalSolverTab();
        if~isempty(localSolverTab_tab)
            mainTab.Tabs{end+1}=localSolverTab_tab;
        end

    end

    paramGrp.Type='group';
    paramGrp.LayoutGrid=[1,1];


    if isSlimDialog
        paramGrp.Items={mainTab.Items{1}.Items{1}};
        paramGrp.Items{1}.Source=h;
    else
        mainTab.Visible=true;
        paramGrp.Items={mainTab};
        paramGrp.RowSpan=[2,2];
        paramGrp.ColSpan=[1,1];
        paramGrp.Source=h;
    end
end


function descGrp=i_GetDescGroup(source)


    text=DAStudio.message('Simulink:blkprm_prompts:ModelRefBlockDescription');

    descTxt.Name=text;
    descTxt.Type='text';
    descTxt.WordWrap=true;
    descTxt.Tag='ModelReferenceBlockDescriptionText';

    descGrp.Name=DAStudio.message('Simulink:modelReference:dialogDescName');
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.LayoutGrid=[1,1];
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];

end

function thisTab=i_GetMainTab(source,h,isSlimDialog)
    aPanel.Type='panel';
    aPanel.Items={i_GetMainPanel(source,h,isSlimDialog)};
    thisTab.Name=DAStudio.message('Simulink:dialog:Main');
    thisTab.Items={aPanel};
end

function ret=i_HasGenericEvent(h)
    ret=false;
    events=get_param(h.Handle,'IRTResetReinitEventNames');
    if isempty(events)
        return;
    end
    for i=1:numel(events)
        elem=events(i);
        if~elem.IncludeImplicitInitialize
            ret=true;
            return;
        end
    end
end

function ret=i_HasReinitEvent(h)
    ret=false;
    events=get_param(h.Handle,'IRTResetReinitEventNames');
    if isempty(events)
        return;
    end
    for i=1:numel(events)
        elem=events(i);
        if elem.IncludeImplicitInitialize
            ret=true;
            return;
        end
    end
end





