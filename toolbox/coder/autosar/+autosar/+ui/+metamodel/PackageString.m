




classdef PackageString
    properties(Constant)
        IconMap=containers.Map({'DataElements',...
        'Triggers',...
        'S-R Interfaces',...
        'M-S Interfaces',...
        'C-S Interfaces',...
        'NV Interfaces',...
        'Parameter Interfaces',...
        'Trigger Interfaces',...
        'Service Interfaces',...
        'Persistency Key Value Interfaces',...
        'CompuMethod',...
        'CompuMethods',...
        'SwAddrMethod',...
        'SwAddrMethods',...
'References'...
        ,'AtomicComponents',...
        'AdaptiveApplications',...
        'CompositionComponents',...
        'ParameterComponents',...
        'IRV',...
        'irvRead',...
        'irvWrite',...
        'Arguments',...
        'dataAccess',...
        'Operations',...
        'Methods',...
        'operationBlockingCall',...
        'AtomicComponent',...
        'AdaptiveApplication',...
        'Components',...
        'CompositionComponent',...
        'ParameterComponent',...
        'ReceiverPorts',...
        'SenderPorts',...
        'SenderReceiverPorts',...
        'NvReceiverPorts',...
        'NvSenderPorts',...
        'NvSenderReceiverPorts',...
        'Behavior',...
        'Runnables',...
        'Events',...
        'OperationInvokedEvent',...
        'SenderReceiverInterface',...
        'ClientServerInterface',...
        'ParameterInterface',...
        'ModeSwitchInterface',...
        'TriggerInterface',...
        'NvDataInterface',...
        'ServiceInterface',...
        'PersistencyKeyValueInterface',...
        'PersistencyProvidedPorts',...
        'PersistencyRequiredPorts',...
        'PersistencyProvidedRequiredPorts',...
        'ClientPorts',...
        'ServerPorts',...
        'Parameters',...
        'ParameterData',...
        'ParameterReceiverPorts',...
        'ParameterSenderPorts',...
        'ModeReceiverPorts',...
        'ModeSenderPorts',...
        'TriggerReceiverPorts',...
        'possibleError',...
        'exclusiveArea',...
        'Package',...
        'DataReceiverPort',...
        'DataSenderPort',...
        'Runnable',...
        'TimingEvent',...
        'IrvData',...
        'ImplementationDataTypes',...
        'Integer',...
        'FloatingPoint',...
        'Boolean',...
        'FixedPoint',...
        'Enumeration',...
        'VoidPointer',...
        'Matrix',...
        'LiteralReal',...
        'ConstantSpecification',...
        'ConstantReference',...
        'MatrixValueSpecification',...
        'Cell',...
        'FlowData',...
        'IrvAccess',...
        'FlowDataAccess',...
        'ApplicationComponentBehavior',...
        'XML Options',...
        'Domain',...
        'AUTOSAR',...
        'ProvidedPorts',...
        'RequiredPorts',...
        'Fields',...
        'FieldData',...
        'Namespaces',...
        'SymbolProps'},...
        {fullfile(autosarroot,'resources','DataElements_16.png'),...
        fullfile(autosarroot,'resources','DataElements_16.png'),...
        fullfile(autosarroot,'resources','Interfaces_16.png'),...
        fullfile(autosarroot,'resources','Interfaces_16.png'),...
        fullfile(autosarroot,'resources','Interfaces_16.png'),...
        fullfile(autosarroot,'resources','Interfaces_16.png'),...
        fullfile(autosarroot,'resources','Interfaces_16.png'),...
        fullfile(autosarroot,'resources','Interfaces_16.png'),...
        fullfile(autosarroot,'resources','Interfaces_16.png'),...
        fullfile(autosarroot,'resources','PersistencyKeyValueInterfaces_16.png'),...
        fullfile(autosarroot,'resources','compumethod_16.png'),...
        fullfile(autosarroot,'resources','compumethods_16.png'),...
        fullfile(autosarroot,'resources','swaddrmethod_16.png'),...
        fullfile(autosarroot,'resources','swaddrmethods_16.png'),...
        fullfile(autosarroot,'resources','references_16.png'),...
        fullfile(autosarroot,'resources','AtomicSoftwareComponents_16.png'),...
        fullfile(autosarroot,'resources','AtomicSoftwareComponents_16.png'),...
        fullfile(autosarroot,'resources','CompositionComponents_16.png'),...
        fullfile(autosarroot,'resources','ParameterComponent_16.png'),...
        fullfile(autosarroot,'resources','InterrunnableVariable_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(autosarroot,'resources','Argument_16.png'),...
        fullfile(autosarroot,'resources','DataElements_16.png'),...
        fullfile(autosarroot,'resources','Operator_16.png'),...
        fullfile(autosarroot,'resources','Operator_16.png'),...
        fullfile(autosarroot,'resources','Operator_16.png'),...
        fullfile(autosarroot,'resources','AtomicComponent_16.png'),...
        fullfile(autosarroot,'resources','AtomicComponent_16.png'),...
        fullfile(autosarroot,'resources','AtomicComponent_16.png'),...
        fullfile(autosarroot,'resources','CompositionComponent_16.png'),...
        fullfile(autosarroot,'resources','ParameterComponent_16.png'),...
        fullfile(autosarroot,'resources','ReceiverPort_16.png'),...
        fullfile(autosarroot,'resources','SenderPort_16.png'),...
        fullfile(autosarroot,'resources','SenderReceiverPort_16.png'),...
        fullfile(autosarroot,'resources','NvReceiverPort_16.png'),...
        fullfile(autosarroot,'resources','NvSenderPort_16.png'),...
        fullfile(autosarroot,'resources','NvSenderReceiverPort_16.png'),...
        fullfile(autosarroot,'resources','opaquebehavior.png'),...
        fullfile(autosarroot,'resources','Runnable_16.png'),...
        fullfile(autosarroot,'resources','DataElements_16.png'),...
        fullfile(autosarroot,'resources','timeevent.png'),...
        fullfile(autosarroot,'resources','SenderReceiverInterface_16.png'),...
        fullfile(autosarroot,'resources','InterfaceClientServer_16.png'),...
        fullfile(autosarroot,'resources','SenderReceiverInterface_16.png'),...
        fullfile(autosarroot,'resources','InterfaceMode_16.png'),...
        fullfile(autosarroot,'resources','SenderReceiverInterface_16.png'),...
        fullfile(autosarroot,'resources','SenderReceiverInterface_16.png'),...
        fullfile(autosarroot,'resources','ServiceInterface_16.png'),...
        fullfile(autosarroot,'resources','PersistencyKeyValueInterface_16.png'),...
        fullfile(autosarroot,'resources','PortPerP_16.png'),...
        fullfile(autosarroot,'resources','PortPerR_16.png'),...
        fullfile(autosarroot,'resources','PortPerPR_16.png'),...
        fullfile(autosarroot,'resources','PortClient_16.png'),...
        fullfile(autosarroot,'resources','PortServer_16.png'),...
        fullfile(autosarroot,'resources','DataElements_16.png'),...
        fullfile(autosarroot,'resources','DataElements_16.png'),...
        fullfile(autosarroot,'resources','NvReceiverPort_16.png'),...
        fullfile(autosarroot,'resources','NvSenderPort_16.png'),...
        fullfile(autosarroot,'resources','PortModeReceiver_16.png'),...
        fullfile(autosarroot,'resources','PortModeSender_16.png'),...
        fullfile(autosarroot,'resources','TriggerReceiverPort_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','error.png'),...
        fullfile(autosarroot,'resources','enumeration.png'),...
        fullfile(autosarroot,'resources','package.png'),...
        fullfile(autosarroot,'resources','ReceiverPort_16.png'),...
        fullfile(autosarroot,'resources','SenderPort_16.png'),...
        fullfile(autosarroot,'resources','Runnable_16.png'),...
        fullfile(autosarroot,'resources','timeevent.png'),...
        fullfile(autosarroot,'resources','InterrunnableVariable_16.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(autosarroot,'resources','datatype.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(autosarroot,'resources','DataElements_16.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(matlabroot,'toolbox','shared','dastudio','resources','MatlabArray.png'),...
        fullfile(autosarroot,'resources','opaquebehavior.png'),...
        fullfile(autosarroot,'resources','XMLoptions_16.png'),...
        fullfile(matlabroot,'toolbox','coder','simulinkcoder_app','code_perspective','icons','autosarCode_16.png'),...
        fullfile(autosarroot,'resources','Workspace_16.png'),...
        fullfile(autosarroot,'resources','ProvidedPort_16.png'),...
        fullfile(autosarroot,'resources','RequiredPort_16.png'),...
        fullfile(autosarroot,'resources','adaptive_fields_16.png'),...
        fullfile(autosarroot,'resources','adaptive_fields_16.png'),...
        fullfile(autosarroot,'resources','adaptive_namespaces_16.png'),...
        fullfile(autosarroot,'resources','adaptive_namespaces_16.png')});

        Name='Name';
        NamedProperty='Name';
        RunnableSymbol='symbol';
        M3IObjectName='M3I.Object';
        M3IClassName='M3I.ClassObject';
        M3IValueName='M3I.ValueObject';
        M3IImmutableValueName='M3I.ImmutableValueObject';
        M3IImmutableDataType='M3I.ImmutableDataType';
        M3IImmutableEnumeration='M3I.ImmutableEnumeration';
        M3IBoolean='M3I.Boolean';
        M3IString='M3I.String';
        M3IInteger='M3I.Integer';
        RootName='AUTOSAR';
        HideTag='extension_m3i_hide_in_mcos';
        AtomicComponentsNodeName='AtomicComponents';
        AdaptiveApplicationsNodeName='AdaptiveApplications';
        ParameterComponentsNodeName='ParameterComponents';
        CompositionComponentsNodeName='CompositionComponents';
        InterfacesNodeName='S-R Interfaces';
        ModeSwitchInterfacesNodeName='M-S Interfaces';
        ClientServerInterfacesNodeName='C-S Interfaces';
        NvDataInterfacesNodeName='NV Interfaces';
        ParameterInterfacesNodeName='Parameter Interfaces';
        TriggerInterfacesNodeName='Trigger Interfaces';
        ServiceInterfacesNodeName='Service Interfaces';
        PersistencyKeyValueInterfacesNodeName='Persistency Key Value Interfaces';
        ServiceInterface='Service Interface';
        PersistencyKeyValueInterface='Persistency Key Value Interface';
        ParameterInterface='Parameter Interface';
        CompuMethod='CompuMethod';
        CompuMethods='CompuMethods';
        CompuMethodName='CM';
        ImplementationDataType='ImplementationDataType';
        ImplementationDataTypes='ImplementationDataTypes';
        ModeDeclarationGroupsNodeName='ModeDeclarationGroups';
        ModeDeclarationNodeName='ModeDeclarations';
        ModeReceiverPortNodeName='ModeReceiverPorts';
        ModeSenderPortNodeName='ModeSenderPorts';
        TriggerReceiverPortNodeName='TriggerReceiverPorts';
        ParameterReceiverPortNodeName='ParameterReceiverPorts';
        ParameterReceiverPort='ParameterReceiverPort';
        TargetClassName='Simulink.metamodel.arplatform';
        TargetRootClass='Simulink.metamodel.foundation.Domain';
        ImportIcon=fullfile(autosarroot,'resources','packageimport.png');
        ExportIcon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','save.png');
        AddIcon=fullfile(autosarroot,'resources','Add_16.png');
        DeleteIcon=fullfile(autosarroot,'resources','Delete_16.png');
        ImportButtonText=DAStudio.message('autosarstandard:ui:uiWizardImportXML');
        ExportButtonText=DAStudio.message('autosarstandard:ui:uiWizardExportXML');
        AddStr=DAStudio.message('autosarstandard:ui:uiCommonAddNoParam');
        DeleteStr=DAStudio.message('autosarstandard:ui:uiCommonDeleteNoParam');
        ImportDlgTitle=DAStudio.message('autosarstandard:ui:uiWizardImportXML');
        ImportFileTypes='*.arxml';
        ImportFileTypesDes=DAStudio.message('autosarstandard:ui:uiWizardImportFileTypes');
        PackageView='packageView';
        LogicalView='logicalView';
        ComponentsCell={'Simulink.metamodel.arplatform.component.AtomicComponent',...
        'Simulink.metamodel.arplatform.component.ParameterComponent',...
        'Simulink.metamodel.arplatform.composition.CompositionComponent',...
        'Simulink.metamodel.arplatform.component.AdaptiveApplication'};
        InterfacesCell={'Simulink.metamodel.arplatform.interface.SenderReceiverInterface','Simulink.metamodel.arplatform.interface.ClientServerInterface'...
        ,'Simulink.metamodel.arplatform.interface.ModeSwitchInterface','Simulink.metamodel.arplatform.interface.TriggerInterface',...
        'Simulink.metamodel.arplatform.interface.ParameterInterface','Simulink.metamodel.arplatform.interface.NvDataInterface',...
        'Simulink.metamodel.arplatform.interface.ServiceInterface','Simulink.metamodel.arplatform.interface.PersistencyKeyValueInterface'};
        OperationClass='Simulink.metamodel.arplatform.interface.Operation';
        CompuMethodClass='Simulink.metamodel.types.CompuMethod';
        ValueTypeClass='Simulink.metamodel.foundation.ValueType';
        IntegerClass='Simulink.metamodel.types.Integer';
        FloatingPointClass='Simulink.metamodel.types.FloatingPoint';
        BooleanClass='Simulink.metamodel.types.Boolean';
        EnumerationClass='Simulink.metamodel.types.Enumeration';
        ImplementationDataTypeAdditionalProps={'DataConstr','Unit','CompuMethod','IsSigned','Length'};
        runnableNode='Runnables';
        providedPortsNode='ProvidedPorts';
        providedPort='ProvidedPort';
        requiredPortsNode='RequiredPorts';
        requiredPort='requiredPort';
        persistencyProvidedPortsNode='PersistencyProvidedPorts';
        persistencyProvidedPort='PersistencyProvidedPort';
        persistencyRequiredPortsNode='PersistencyRequiredPorts';
        persistencyRequiredPort='PersistencyRequiredPort';
        persistencyProvidedRequiredPortsNode='PersistencyProvidedRequiredPorts';
        persistencyProvidedRequiredPort='PersistencyProvidedRequiredPort';
        methodsNodeName='Methods';
        methodNode='Method';
        fieldsNodeName='Fields';
        fieldNode='Field'
        eventsNodeName='Events';
        eventNode='Event';
        namespacesNodeName='Namespaces';
        namespaceNode='Namespace';
        behaviorNode='Behavior';
        irvNode='IRV';
        parameterNode='Parameters';
        triggerNode='Triggers';
        Parameter='Parameter';
        receiverPortsNode='ReceiverPorts';
        senderPortsNode='SenderPorts';
        senderReceiverPortsNode='SenderReceiverPorts';
        nvReceiverPortsNode='NvReceiverPorts';
        nvSenderPortsNode='NvSenderPorts';
        nvSenderReceiverPortsNode='NvSenderReceiverPorts';
        serverPortsNode='ServerPorts';
        clientPortsNode='ClientPorts';
        dataElementsNode='DataElements';
        operationsNode='Operations';
        argumentsNode='Arguments';
        packagesNode='Packages';
        packageTreeLabel='ARPackage Structure';
        packageDlgTitle='AUTOSAR Package Browser';
        packageClass='Simulink.metamodel.arplatform.common.Package';
        browseLabel='...';
        packageLabel='Package: ';
        editLabel='Edit';
        errorEnumLabel='Application Errors Enum Type:';
        majorVersionNode='MajorVersion';
        minorVersionNode='MinorVersion';

        Preferences='XML Options';
        InterfacePackage='Interface Package';
        ComponentName='Component Name';
        InternalBehaviorName='Internal Behavior Name';
        ImplementationName='Implementation Name';
        DatatypePackage='Data type Package';
        ExportedXMLFilePackaging='Exported XML file packaging';
        NoRootErr=DAStudio.message('autosarstandard:ui:uiExplorerNoRootErr');
        ErrorTitle='Error';
        Title='AUTOSAR Browser';
        DupDataElement='DataElement';
        DupRunnable='Runnable';
        DupIrv='IRV';
        DupPort='Port';
        DupInterface='Interface';
        DupEvent='Event';
        ComponentClass='Simulink.metamodel.arplatform.component.Component';
        RunnableClass='Simulink.metamodel.arplatform.behavior.Runnable';
        InterfaceClass='Simulink.metamodel.arplatform.interface.PortInterface';
        PortClass='Simulink.metamodel.arplatform.port.Port';
        ModeDeclarationClass='Simulink.metamodel.arplatform.common.ModeDeclaration';
        ModeDeclarationGroupClass='Simulink.metamodel.arplatform.common.ModeDeclarationGroup';
        ModeDeclarationGroupElementClass='Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement';
        TypeProperty='Type';
        BehaviorProperty='Behavior';
        True='true';
        False='false';
        ApplicationComponent='Application Component';
        SensorActuatorComponent='Sensor Actuator Component';
        UnknownType='Unknown Type';
        ReceiverPort='ReceiverPort';
        SenderPort='SenderPort';
        SenderReceiverPort='SenderReceiverPort';
        NvReceiverPort='NvReceiverPort';
        NvSenderPort='NvSenderPort';
        NvSenderReceiverPort='NvSenderReceiverPort';
        ClientPort='ClientPort';
        ServerPort='ServerPort';
        Operation='Operation';
        OpArgument='OperationArgument';
        SRInterface='S-R Interface';
        ModeSwitchInterface='ModeSwitchInterface';
        CSInterface='C-S Interface';
        NvDataInterface='NvDataInterface';
        TriggerInterface='TriggerInterface';
        CseCode='CseCode';
        CseCodeFactor='CseCodeFactor';
        ModeDeclarationGroup='ModeDeclarationGroup';
        ModeDeclaration='ModeDeclaration';
        ModeReceiverPort='ModeReceiverPort';
        ModeSenderPort='ModeSenderPort';
        ModeReceiverPortsStr='Mode Receiver Ports';
        ModeSenderPortsStr='Mode Sender Ports';
        TriggerReceiverPort='TriggerReceiverPort';
        TriggerReceiverPortsStr='Trigger Required Ports';
        ModeDeclarationStr='Mode Declaration';
        ModeDeclarationsStr='Mode Declarations';
        ModeDeclarationGroupStr='Mode Declaration Group';
        ModeDeclarationGroupsColonStr='Mode Declaration Groups: ';
        ModeDeclarationGroupPackageStr='Mode Declaration Group Package: ';
        ModeGroup='ModeGroup';
        ModeGroupStr='Mode Group';
        Mode='Mode';
        ModeAccessType='ModeReceive';
        SwAddrMethod='SwAddrMethod';
        SwAddrMethods='SwAddrMethods';
        SwAddrMethodClass='Simulink.metamodel.arplatform.common.SwAddrMethod';
        DefaultSwAddrMethods={'CODE','CONST','VAR'};
        RunnableSwAddrMethodSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Code};
        RunnableInternalDataSwAddrMethodSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var};
        InternalDataSwAddrMethodSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var};
        ParameterSwAddrMethodSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.Calprm,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.CalibrationVariables,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.Const};
        DataElementSwAddrMethodSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.Const,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.CalibrationVariables};
        IRVSwAddrMethodSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.Const};
        ArgumentSwAddrMethodSectionTypes={Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.Const,...
        Simulink.metamodel.arplatform.behavior.SectionTypeKind.Calprm};
        SectionType='SectionType';
        SectionTypeClass='Simulink.metamodel.arplatform.common.SwAddrMethod.SectionType';
        DefaultSectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var.toString();
        MemoryAllocationKeywordPolicy='MemoryAllocationKeywordPolicy';
        MemoryAllocationKeywordPolicyClass='Simulink.metamodel.arplatform.common.SwAddrMethod.MemoryAllocationKeywordPolicy';
        DefaultMemoryAllocationKeywordPolicy='ADDR-METHOD-SHORT-NAME';
        SwAlignment='SwAlignment';
        ParameterKind='Kind';
        Undefined='undefined';
        Unit='Unit';
        DictionaryNameToken='$DictionaryName'
        ModelNameToken='$ModelName';
        NoUnit='NoUnit';
        UnitClass='Simulink.metamodel.types.Unit';
        DisplayFormat='DisplayFormat';
        LongName=DAStudio.message('RTW:autosar:ArLongNameProperty');
        LongNameClass='Simulink.metamodel.arplatform.documentation.MultiLanguageLongName';
        Category='Category';
        AutosarRootClass='Simulink.metamodel.arplatform.common.AUTOSAR';
        SLTypes='Simulink DataTypes';
        SlDataTypes='SlDataTypes';
        SlDataTypesToolID=['ARXML_',autosar.ui.metamodel.PackageString.SlDataTypes];
        DataClass='Simulink.metamodel.arplatform.common.Data';
        ModeSwitchInterfaceAdditionalProps={autosar.ui.metamodel.PackageString.ModeGroup};
        PortTypes={autosar.ui.metamodel.PackageString.senderPortsNode,...
        autosar.ui.metamodel.PackageString.receiverPortsNode,...
        'ClientPorts','ServerPorts',...
        autosar.ui.metamodel.PackageString.ModeReceiverPortNodeName,...
        autosar.ui.metamodel.PackageString.senderReceiverPortsNode,...
        autosar.ui.metamodel.PackageString.nvReceiverPortsNode,...
        autosar.ui.metamodel.PackageString.nvSenderPortsNode,...
        autosar.ui.metamodel.PackageString.nvSenderReceiverPortsNode,...
        autosar.ui.metamodel.PackageString.ParameterReceiverPortNodeName,...
        autosar.ui.metamodel.PackageString.ModeSenderPortNodeName,...
        autosar.ui.metamodel.PackageString.TriggerReceiverPortNodeName,...
        autosar.ui.metamodel.PackageString.providedPortsNode,...
        autosar.ui.metamodel.PackageString.requiredPortsNode,...
        autosar.ui.metamodel.PackageString.persistencyProvidedPortsNode,...
        autosar.ui.metamodel.PackageString.persistencyRequiredPortsNode,...
        autosar.ui.metamodel.PackageString.persistencyProvidedRequiredPortsNode};
        InterfaceTypes={autosar.ui.metamodel.PackageString.InterfacesNodeName,...
        autosar.ui.metamodel.PackageString.ModeSwitchInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.ClientServerInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.NvDataInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.ParameterInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.TriggerInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.ServiceInterfacesNodeName,...
        autosar.ui.metamodel.PackageString.PersistencyKeyValueInterfacesNodeName};
        MdgSupportedStorageTypesStr={'uint8, uint16, int8, int16, int32'};
        MdgSupportedStorageTypesStrARVersionLowerThan4x={'uint8, uint16'};
        SimulinkFcnLabel='Simulink Function';
        OperationLabel='Operation Name';
        NoneStr='None';
        NoneSelection=DAStudio.message('RTW:autosar:uiUnselectOptions');
        ServiceInterfaceChildrenNames={autosar.ui.metamodel.PackageString.methodsNodeName,...
        autosar.ui.metamodel.PackageString.eventsNodeName,...
        autosar.ui.metamodel.PackageString.fieldsNodeName,...
        autosar.ui.metamodel.PackageString.namespacesNodeName};
        PersistencyKeyValueInterfaceChildrenNames={autosar.ui.metamodel.PackageString.dataElementsNode};
        CommonAdditionalNativeTypeQualifierProperties=...
        {autosar.ui.metamodel.PackageString.IsVolatileString,autosar.ui.metamodel.PackageString.QualifierString};
        ParameterAdditionalNativeTypeQualifierProperties={autosar.ui.metamodel.PackageString.IsConstString};
        IsVolatileString='IsVolatile';
        IsConstString='IsConst';
        QualifierString='Qualifier';
        DefaultRequiredPortName='RequiredPort';
        DefaultProvidedPortName='ProvidedPort';
        DefaultRequiredServiceInterfaceName='RequiredInterface';
        DefaultProvidedServiceInterfaceName='ProvidedInterface';
        DefaultRequiredPersistencyKeyValueInterfaceName='RequiredPersistencyKeyValueInterface';
        DefaultProvidedPersistencyKeyValueInterfaceName='ProvidedPersistencyKeyValueInterface';
    end
end




