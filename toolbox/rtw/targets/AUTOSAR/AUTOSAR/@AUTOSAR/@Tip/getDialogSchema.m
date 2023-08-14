




function dlg=getDialogSchema(h,~)

    explorer=h.Explorer;

    mcosRef=explorer.getTreeSelection;
    nodeLabel=mcosRef.getDisplayLabel;


    ar_tip_panel.Type='panel';
    ar_tip_panel.Tag='ar_tip_panel';
    ar_tip_panel.Items={};

    ar_tip_panel.Visible=true;

    helpButton.Type='pushbutton';
    helpButton.Tag='ar_tipview_link';
    helpButton.MatlabMethod='helpview';
    helpButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','help.png');
    switch nodeLabel
    case autosar.ui.metamodel.PackageString.AtomicComponentsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_components'};
    case autosar.ui.metamodel.PackageString.receiverPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_rcvr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ReceiverPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ReceiverPort);
    case autosar.ui.metamodel.PackageString.senderPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_sndr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.SenderPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.SenderPort);
    case autosar.ui.metamodel.PackageString.dataElementsNode
        if~isempty(mcosRef.ParentM3I)
            if isa(mcosRef.ParentM3I,'Simulink.metamodel.arplatform.interface.NvDataInterface')
                helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_nvinterface_data'};
            elseif isa(mcosRef.ParentM3I,'Simulink.metamodel.arplatform.interface.ParameterInterface')
                helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_paraminterface_data'};
            elseif isa(mcosRef.ParentM3I,'Simulink.metamodel.arplatform.interface.PersistencyKeyValueInterface')
                helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
            else
                helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_srinterface_data'};
            end
        else
            helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_srinterface_data'};
        end
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.DupDataElement);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.DupDataElement);
    case autosar.ui.metamodel.PackageString.triggerNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_trinterface_trigger'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.triggerNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.triggerNode);
    case autosar.ui.metamodel.PackageString.InterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_srinterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.SRInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.SRInterface);
    case autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_msinterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ModeSwitchInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ModeSwitchInterface);
    case autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_csinterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.CSInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.CSInterface);
    case autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_paraminterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ParameterInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ParameterInterface);
    case autosar.ui.metamodel.PackageString.parameterNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_parameters'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.Parameter);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.Parameter);
    case autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_nvinterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.NvDataInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.NvDataInterface);
    case autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_trinterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.TriggerInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.TriggerInterface);
    case autosar.ui.metamodel.PackageString.ModeReceiverPortNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_mrcvr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ModeReceiverPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ModeReceiverPort);
    case autosar.ui.metamodel.PackageString.ModeSenderPortNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_msndr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ModeSenderPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ModeSenderPort);
    case autosar.ui.metamodel.PackageString.ParameterReceiverPortNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_prcvr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ParameterReceiverPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ParameterReceiverPort);
    case autosar.ui.metamodel.PackageString.TriggerReceiverPortNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_trrcvr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.TriggerReceiverPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.TriggerReceiverPort);
    case autosar.ui.metamodel.PackageString.runnableNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_runnables'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.DupRunnable);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.DupRunnable);
    case autosar.ui.metamodel.PackageString.irvNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_irv'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.DupIrv);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.DupIrv);
    case autosar.ui.metamodel.PackageString.clientPortsNode
        help_link='autosar_config_props_component_clnt';
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),help_link};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ClientPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ClientPort);
    case autosar.ui.metamodel.PackageString.serverPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_srvr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ServerPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ServerPort);
    case autosar.ui.metamodel.PackageString.senderReceiverPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_sr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.SenderReceiverPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.SenderReceiverPort);
    case autosar.ui.metamodel.PackageString.nvReceiverPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_nvrcvr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.NvReceiverPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.NvReceiverPort);
    case autosar.ui.metamodel.PackageString.nvSenderPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_nvsndr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.NvSenderPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.NvSenderPort);
    case autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_nvsr'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.NvSenderReceiverPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.NvSenderReceiverPort);
    case autosar.ui.metamodel.PackageString.operationsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_csinterface_ops'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.Operation);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.Operation);
    case autosar.ui.metamodel.PackageString.argumentsNode



        isArgumentInAdaptiveServiceInterface=isa(mcosRef.ParentM3I.containerM3I,...
        autosar.ui.metamodel.PackageString.InterfacesCell{7});
        if isArgumentInAdaptiveServiceInterface
            help_link_extension='autosar_config_props_serviceinterface_method_args';
        else
            help_link_extension='autosar_config_props_op_args';
        end
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),help_link_extension};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.OpArgument);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.OpArgument);
    case autosar.ui.metamodel.PackageString.CompuMethods
        if~isempty(mcosRef.ParentM3I)
            helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_compumethods'};
            addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.CompuMethod);
            deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.CompuMethod);
        else
            helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_references'};
        end
    case autosar.ui.metamodel.PackageString.SwAddrMethods
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_swaddrmethods'};
    case autosar.ui.metamodel.PackageString.providedPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_adaptive_provided'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.providedPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.providedPort);
    case autosar.ui.metamodel.PackageString.requiredPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_adaptive_required'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.requiredPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.requiredPort);
    case autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_serviceinterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ServiceInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ServiceInterface);
    case autosar.ui.metamodel.PackageString.eventsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterfaces_events'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.eventNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.eventNode);
    case autosar.ui.metamodel.PackageString.methodsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterfaces_methods'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.methodNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.methodNode);
    case autosar.ui.metamodel.PackageString.fieldsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterfaces_fields'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.fieldNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.fieldNode);
    case autosar.ui.metamodel.PackageString.namespacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterfaces_namespaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.namespaceNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.namespaceNode);
    case autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_adaptive_applications'};
    case autosar.ui.metamodel.PackageString.providedPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_adaptive_provided'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.providedPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.providedPort);
    case autosar.ui.metamodel.PackageString.requiredPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_adaptive_required'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.requiredPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.requiredPort);
    case autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_component_serviceinterfaces'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.ServiceInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.ServiceInterface);
    case autosar.ui.metamodel.PackageString.eventsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterfaces_events'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.eventNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.eventNode);
    case autosar.ui.metamodel.PackageString.methodsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterfaces_methods'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.methodNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.methodNode);
    case autosar.ui.metamodel.PackageString.fieldsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_serviceinterfaces_fields'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.fieldNode);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.fieldNode);
    case autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.PersistencyKeyValueInterface);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.PersistencyKeyValueInterface);
    case autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.persistencyProvidedPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.persistencyProvidedPort);
    case autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.persistencyRequiredPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.persistencyRequiredPort);
    case autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_persistency'};
        addPushButton.ToolTip=DAStudio.message('RTW:autosar:addToolTipStr',autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPort);
        deletePushButton.ToolTip=DAStudio.message('RTW:autosar:deleteToolTipStr',autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPort);
    case autosar.ui.metamodel.PackageString.AdaptiveApplicationsNodeName
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_props_adaptive_applications'};
    otherwise
        helpButton.MatlabArgs={fullfile(docroot,'autosar','helptargets.map'),'autosar_config_slmap'};
    end



    ar_tip_panel.LayoutGrid=[1,6];
    ar_tip_panel.ColStretch=[0,0,0,0,1,0];
    ar_tip_panel.Items={helpButton};




    buttonVisible=autosarinstalled&&autosar.api.Utils.autosarlicensed();
    buttonEnabled=~mcosRef.isReadOnly();

    addPushButton.Type='pushbutton';
    addPushButton.Tag='AddButton';
    addPushButton.MatlabMethod='autosar.ui.utils.addWizard';
    addPushButton.MatlabArgs={explorer};
    addPushButton.FilePath=autosar.ui.metamodel.PackageString.AddIcon;
    addPushButton.Visible=buttonVisible;
    addPushButton.Enabled=buttonEnabled;

    deletePushButton.Type='pushbutton';
    deletePushButton.Tag='DeleteButton';
    deletePushButton.MatlabMethod='autosar.ui.utils.deleteNode';
    deletePushButton.MatlabArgs={explorer};
    deletePushButton.FilePath=autosar.ui.metamodel.PackageString.DeleteIcon;
    deletePushButton.Visible=buttonVisible;
    deletePushButton.Enabled=buttonEnabled;

    ar_tip_panelWithButtons.Type='panel';
    ar_tip_panelWithButtons.Tag='ar_tip_panelWithButtons';
    ar_tip_panelWithButtons.LayoutGrid=[1,6];
    ar_tip_panelWithButtons.ColStretch=[0,0,0,0,1,0];
    ar_tip_panelWithButtons.Items={addPushButton,deletePushButton,helpButton};



    dlg.DialogTitle='';
    dlg.DialogTag='me_view_manager_ui';
    dlg.EmbeddedButtonSet={''};
    dlg.IsScrollable=false;
    switch nodeLabel
    case autosar.ui.metamodel.PackageString.receiverPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.senderPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.senderReceiverPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.serverPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.clientPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ParameterReceiverPortNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.dataElementsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.triggerNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.operationsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.InterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.parameterNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.argumentsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ModeReceiverPortNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ModeSenderPortNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.nvReceiverPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.nvSenderPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.TriggerReceiverPortNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.runnableNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.irvNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.CompuMethods
        if~isempty(mcosRef.ParentM3I)
            dlg.Items={ar_tip_panelWithButtons};
        else
            dlg.Items={ar_tip_panel};
        end
    case autosar.ui.metamodel.PackageString.SwAddrMethods
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.providedPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.requiredPortsNode
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.eventsNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.methodsNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.fieldsNodeName
        dlg.Items={ar_tip_panelWithButtons};
    case autosar.ui.metamodel.PackageString.namespacesNodeName
        dlg.Items={ar_tip_panelWithButtons};
    otherwise
        dlg.Items={ar_tip_panel};
    end











