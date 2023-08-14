function create(modelName,mode,varargin)









































    autosar.api.Utils.autosarlicensed(true);

    if nargin>0
        modelName=convertStringsToChars(modelName);
    end

    if nargin>1
        mode=lower(convertStringsToChars(mode));
    end

    if nargin<2

        mode='auto';
    end


    argParser=inputParser;


    supportedComponentTypes={'AtomicComponent','CompositionComponent'};
    argParser.addParameter('ComponentType','AtomicComponent',...
    @(x)any(validatestring(x,supportedComponentTypes)));
    argParser.addRequired('mode',...
    @(x)any(validatestring(x,{'auto','incremental','init','default'})));
    argParser.addParameter('CreateReport',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('ReferencedFromComponentModel',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('DisableM3IListeners',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.parse(mode,varargin{:});

    mode=argParser.Results.mode;



    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
    end

    bdType=get_param(modelName,'BlockDiagramType');
    if isequal(bdType,'subsystem')

        DAStudio.error('RTW:autosar:SubsystemReferenceModel',modelName);
    elseif isequal(bdType,'library')

        DAStudio.error('RTW:autosar:LibraryModel',modelName);
    end


    isCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');
    if~isCompliant
        DAStudio.error('RTW:autosar:nonAutosarCompliant');
    end


    if autosar.api.Utils.isMappedToComposition(modelName)||...
        (Simulink.internal.isArchitectureModel(modelName)&&...
        ~strcmp(argParser.Results.ComponentType,'CompositionComponent'))
        DAStudio.error('autosarstandard:api:CompositionMappingNotSupported',modelName);
    end

    componentType=argParser.Results.ComponentType;
    if Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)
        if strcmp(argParser.Results.ComponentType,'CompositionComponent')
            DAStudio.error('autosarstandard:api:CompositionMappingNotSupported',modelName);
        else
            componentType='AdaptiveApplication';
        end
    end

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        if~Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)

            i_checkModelingStyle(modelName);
        end


        mappingType=i_getMappingType(componentType);
        if createSubComponentMapping(modelName,mode,argParser,mappingType)
            return;
        end

        switch mode
        case 'auto'
            [isMappedToSubComponent,~]=Simulink.CodeMapping.isMappedToAutosarSubComponent(modelName);
            if autosar.api.Utils.isMapped(modelName)&&...
                autosar.api.Utils.isMappedModelConsistentWithSTF(modelName)&&~isMappedToSubComponent
                autosar.api.create(modelName,'incremental',varargin{:});
            else
                autosar.api.create(modelName,'default',varargin{:});
            end
            return;
        case 'incremental'

            if~autosar.api.Utils.isMapped(modelName)
                autosar.validation.AutosarUtils.reportErrorWithFixit(...
                'autosarstandard:api:IncrementalModeRequiresMappedModel',modelName);
            end


            if autosar.api.Utils.isMapped(modelName)&&...
                ~autosar.api.Utils.isMappedModelConsistentWithSTF(modelName)
                autosar.validation.AutosarUtils.reportErrorWithFixit(...
                'autosarstandard:api:IncrementalModeRequiresConsistentSTF',modelName);
            end


            i_runInterfaceDictChecks(modelName,mode);



            slChangeLogger=autosar.updater.ChangeLogger();
            componentBuilder=autosar.ui.wizard.builder.Component(modelName,modelName,...
            'PreserveExistingMapping',true,'ChangeLogger',slChangeLogger);

            modelH=get_param(modelName,'Handle');
            componentBuilder.setDefaultConfiguration(modelH);


            m3iModel=autosar.api.Utils.m3iModel(modelName);
            transObj=autosar.utils.M3ITransaction(m3iModel,...
            DisableListeners=argParser.Results.DisableM3IListeners);


            componentBuilder.populateMetamodel(m3iModel,modelName);


            componentBuilder.buildMapping(modelName,'cmdline');


            transObj.commit();


            if argParser.Results.CreateReport
                report=autosar.updater.Report();
                report.buildForAutoConfigAndMap(slChangeLogger,modelName);
                report.dispHelpLine(modelName);
            end


            autosar.simulink.functionPorts.DictionarySyncer.sync(modelName);

        case 'init'


            i_closeCodePerspectiveAndDictionary(modelName);


            interfaceDictName=i_runInterfaceDictChecks(modelName,mode);


            i_createEmptyAutosarMapping(modelName,mappingType,interfaceDictName);


            componentBuilder=autosar.ui.wizard.builder.Component(modelName,modelName);
            compQName=[componentBuilder.ComponentPackage,'/',componentBuilder.ComponentName];

            dataObj=autosar.api.getAUTOSARProperties(modelName,true);
            dataObj.addComponent(compQName,'Category',componentType);


            m3iSWC=autosar.api.Utils.m3iMappedComponent(modelName);
            transObj=autosar.utils.M3ITransaction(m3iSWC.rootModel,...
            DisableListeners=argParser.Results.DisableM3IListeners);
            componentBuilder.populateCorePackages(m3iSWC,modelName);
            transObj.commit();

        case 'default'


            i_closeCodePerspectiveAndDictionary(modelName);


            Simulink.output.Stage(...
            message('coderdictionary:mapping:StageCreateDefaultCompMsg').getString(),...
            'ModelName',modelName,'UIMode',false);


            interfaceDictName=i_runInterfaceDictChecks(modelName,mode);


            i_createEmptyAutosarMapping(modelName,mappingType,interfaceDictName);


            componentBuilder=autosar.ui.wizard.builder.Component(modelName,modelName);

            modelH=get_param(modelName,'Handle');
            componentBuilder.setDefaultConfiguration(modelH);

            m3iModel=autosar.api.Utils.m3iModel(modelName);
            transObj=autosar.utils.M3ITransaction(m3iModel,...
            DisableListeners=argParser.Results.DisableM3IListeners);


            componentBuilder.populateMetamodel(m3iModel,modelName);


            componentBuilder.buildMapping(modelName,'cmdline');
            if strcmp(mappingType,'AutosarTarget')


                mmgr=get_param(modelName,'MappingManager');
                mapping=mmgr.getActiveMappingFor(mappingType);
                mapping.IsSubComponent=false;
            end
            transObj.commit();


            autosar.simulink.functionPorts.DictionarySyncer.sync(modelName);


            autosar.api.Utils.setM3iModelDirty(modelName);

        otherwise
            assert(false,'unexpected mapping creation mode: %s',mode);
        end
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end
end

function success=createSubComponentMapping(modelName,mode,argParser,mappingType)
    success=false;
    if argParser.Results.ReferencedFromComponentModel
        if~strcmp(mode,'default')
            MSLDiagnostic('autosarstandard:api:subComponentMappingCreateMode').reportAsWarning
        end
        success=true;
        if~strcmp(mappingType,'AutosarTarget')
            DAStudio.error('autosarstandard:api:subComponentSupportedForClassic');
        end


        i_closeCodePerspectiveAndDictionary(modelName);


        Simulink.output.Stage(...
        message('coderdictionary:mapping:StageCreateDefaultCompMsg').getString(),...
        'ModelName',modelName,'UIMode',false);



        mmgr=get_param(modelName,'MappingManager');
        [~]=Simulink.AutosarTarget.Component('','');
        [~]=Simulink.AutosarTarget.Composition('','');
        mapping=mmgr.getActiveMappingFor(mappingType);
        if~isempty(mapping)
            mapping.unmap();
            mmgr.deleteMapping(mapping);
        end

        mmgr.createMapping(modelName,mappingType);
        mmgr.activateMapping(modelName);
        mapping=mmgr.getActiveMappingFor(mappingType);
        autosarcore.setModelCallbacks(modelName);
        mapping.IsSubComponent=true;
        autosar.ui.wizard.builder.Component.getForceCompiledData(modelName,mapping,mode);
    else
        [isMappedToSubComponent,~]=Simulink.CodeMapping.isMappedToAutosarSubComponent(modelName);
        if isMappedToSubComponent
            if~any(strcmp(mode,{'default','auto'}))
                DAStudio.error('autosarstandard:api:mappingResetForSubComp',modelName);
            end
        end
    end
end

function i_createEmptyAutosarMapping(modelName,mappingType,interfaceDictName)


    mmgr=get_param(modelName,'MappingManager');
    [~]=Simulink.AutosarTarget.Component('','');
    [~]=Simulink.AutosarTarget.Composition('','');
    [~]=Simulink.AutosarTarget.Application('','');




    autosarMappingKeys={'AutosarTarget','AutosarTargetCPP'};
    for mappingKey=autosarMappingKeys
        mapping=mmgr.getActiveMappingFor(mappingKey{1});
        if~isempty(mapping)
            mapping.unmap();
            mmgr.deleteMapping(mapping);
        end
    end

    mappingName=autosar.api.Utils.createMappingName(modelName,mappingType);

    mmgr.createMapping(mappingName,mappingType);
    mmgr.activateMapping(mappingName);
    mapping=mmgr.getActiveMappingFor(mappingType);

    m3iModel=Simulink.metamodel.foundation.Factory.createNewModel();


    t=M3I.Transaction(m3iModel);
    m3iModel.Name='AUTOSAR';

    autosarPkg=Simulink.metamodel.arplatform.common.AUTOSAR(m3iModel);
    autosarPkg.Name='AUTOSAR';
    m3iModel.RootPackage.append(autosarPkg);
    mapping.AUTOSAR_ROOT=m3iModel;


    t.commit();

    autosarcore.setModelCallbacks(modelName);



    if~isempty(interfaceDictName)
        assert(strcmp(mappingType,'AutosarTarget'),...
        'interface dict only supported for AUTOSAR classic platform');


        dictAPI=Simulink.interface.dictionary.open(interfaceDictName);
        if~dictAPI.hasPlatformMapping('AUTOSARClassic')
            dictAPI.addPlatformMapping('AUTOSARClassic');
        end

        autosar.dictionary.internal.LinkUtils.linkModelDictM3IModels(...
        modelName,interfaceDictName);
    end
end

function i_checkModelingStyle(modelName)
    autosar.validation.ClientServerValidator.checkValidRunnableConfig(modelName);


    bswServices=autosar.bsw.ServiceComponent.find(modelName);
    [demOverrideBlocks,demInjectBlocks]=autosar.bsw.DemStatusValidator.findDemStatusBlocks(modelName);
    unsupportedBlocks=[bswServices,demOverrideBlocks,demInjectBlocks];
    if~isempty(unsupportedBlocks)
        DAStudio.error('autosarstandard:bsw:createDefaultMapping',unsupportedBlocks{1});
    end

end

function i_closeCodePerspectiveAndDictionary(modelName)



    autosar_ui_close(modelName);


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if cp.isInPerspective(modelName)
        editors=GLUE2.Util.findAllEditors(modelName);
        for ii=1:numel(editors)
            simulinkcoder.internal.CodePerspective.getInstance.togglePerspective(editors(ii));
        end
    end
end

function mappingType=i_getMappingType(componentType)
    switch(componentType)
    case{'AtomicComponent'}
        mappingType='AutosarTarget';
    case 'CompositionComponent'
        mappingType='AutosarComposition';
    case 'AdaptiveApplication'
        mappingType='AutosarTargetCPP';
    otherwise
        assert(false,'invalid componentType: %s',componentType);
    end
end

function interfaceDict=i_runInterfaceDictChecks(modelName,mappingMode)
    import autosar.validation.InterfaceDictionaryValidator


    interfaceDict='';
    interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
    if isempty(interfaceDicts)
        if strcmp(mappingMode,'incremental')
            InterfaceDictionaryValidator.runNoInterfaceDictionaryChecks(modelName);
        end
        return;
    end


    InterfaceDictionaryValidator.checkSingleInterfaceDict(modelName,interfaceDicts);
    assert(numel(interfaceDicts)==1,'expect 1 interface dict in model closure');
    interfaceDict=autosar.utils.File.dropPath(interfaceDicts{1});


    InterfaceDictionaryValidator.checkNoAdaptiveComponent(modelName,interfaceDict);
    if strcmp(mappingMode,'incremental')



        InterfaceDictionaryValidator.checkDictPlatformMapping(modelName,interfaceDict,...
        MappingKind=sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic);


        InterfaceDictionaryValidator.checkM3IModelsAreLinked(modelName,interfaceDict);
    end
end



