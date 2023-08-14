classdef Validator<autosar.composition.utils.SLCompositionVisitor





    properties(SetAccess=immutable,GetAccess=private)
        RootModelName;
        SystemPathToValidate;
        ExportECUExtract;
    end

    properties(Access=private)
        MessageLogger;
        CompModelToInfoMap;
        CompositionBlockToInfoMap;
        DataElementQNameToSlPortTypeInfoMap;

        InterfaceDictsUsedByRootModel;


        AllDictsInterfaceNames;
    end

    methods
        function this=Validator(systemPath,varargin)
            doVisitSubCompositions=true;
            rootModelName=get_param(bdroot(systemPath),'Name');
            this@autosar.composition.utils.SLCompositionVisitor(...
            rootModelName,doVisitSubCompositions);
            this.RootModelName=rootModelName;
            this.SystemPathToValidate=getfullname(systemPath);


            p=inputParser;
            p.addParameter('ExportECUExtract',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            p.parse(varargin{:});
            this.ExportECUExtract=p.Results.ExportECUExtract;
        end

        function verify(this)

            this.init();



            this.visitRootModel();


            this.visitCompBlocks(this.SystemPathToValidate);


            this.runPostVisitChecks();


            this.visitAdapterBlocks();


            this.MessageLogger.flush(...
            'autosarstandard:validation:CompositionValidationError');
        end

        function info=getCompModelsToInfoMap(this)
            info=this.CompModelToInfoMap;
        end
    end

    methods(Access=protected)
        function visitCompBlock(this,compBlk)




            if autosar.composition.Utils.isComponentBlock(compBlk)
                this.verifyComponentBlockIsLinked(compBlk);
                if autosar.composition.Utils.isCompBlockLinked(compBlk)
                    this.collectCompModelInfo(compBlk);
                end
            elseif autosar.composition.Utils.isCompositionBlock(compBlk)
                this.verifyCompositionPortInterfaces(compBlk);
                this.collectCompositionBlockInfo(compBlk);
            else
                assert(false,'Did not expect to get here');
            end
        end
    end

    methods(Access=private)
        function init(this)
            this.MessageLogger=autosar.utils.MessageLogger();
            this.CompModelToInfoMap=containers.Map();
            this.CompositionBlockToInfoMap=containers.Map();
            this.DataElementQNameToSlPortTypeInfoMap=containers.Map();



            this.InterfaceDictsUsedByRootModel=SLDictAPI.getTransitiveInterfaceDictsForModel(...
            get_param(this.RootModelName,'handle'));
            this.AllDictsInterfaceNames=[];
            if numel(this.InterfaceDictsUsedByRootModel)>0
                archModelAPI=autosar.arch.loadModel(this.RootModelName);
                this.AllDictsInterfaceNames={archModelAPI.Interfaces.Name};
            end





            find_mdlrefs(this.SystemPathToValidate,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
        end

        function verifyAutosarCompliantForModel(this,modelName)

            if~strcmp(get_param(modelName,'AutosarCompliant'),'on')
                this.logError(...
                'autosarstandard:validation:Composition_ModelNotAutosarCompliant',...
                modelName);
            end
        end

        function verifyNoConnectedRootPorts(this,compBlkH)




            compModel=get_param(compBlkH,'ModelName');

            rootInportBlocks=find_system(compModel,'SearchDepth','1',...
            'BlockType','Inport','IsBusElementPort','off',...
            'OutputFunctionCall','off');
            rootOutportBlocks=find_system(compModel,'SearchDepth','1',...
            'BlockType','Outport','IsBusElementPort','off',...
            'OutputFunctionCall','off');
            rootPortBlocks=[rootInportBlocks;rootOutportBlocks]';

            for curPort=rootPortBlocks
                this.verifyNonCompositePortUnconnected(curPort{1},compBlkH);
            end
        end

        function verifyNonCompositePortUnconnected(this,portPath,compBlkH)



            rootPortName=get_param(portPath,'PortName');


            [~,compName]=fileparts(getfullname(compBlkH));
            archModel=autosar.arch.loadModel(this.RootModelName);
            component=archModel.find("Component","Name",compName,"AllLevels",true);
            componentPort=component.find("Port","Name",rootPortName);

            if componentPort.Connected
                if strcmp(componentPort.Kind,'Receiver')
                    portType='Inport';
                elseif strcmp(componentPort.Kind,'Sender')
                    portType='Outport';
                else
                    assert(false,'Did not expect to get here');
                end
                this.logError(...
                'autosarstandard:validation:Composition_ConnectedRootPort',...
                portType,portPath);
            end

        end

        function verifyCompositionPortInterfaces(this,compositionH)










            import autosar.validation.InterfaceDictionaryValidator

            inportBlks=autosar.composition.Utils.findCompositeInports(compositionH);
            outportBlks=autosar.composition.Utils.findCompositeOutports(compositionH);
            isInportBlk=[true(length(inportBlks),1);false(length(outportBlks),1)];
            portBlks=[inportBlks;outportBlks];

            for portIdx=1:length(portBlks)
                portBlk=portBlks{portIdx};
                if~this.canInferInterfaceForPort(portBlk,isInportBlk(portIdx))


                    this.logWarning('autosarstandard:validation:Composition_CannotInferInterface',portBlk);
                end
            end



            compositionSys=getfullname(compositionH);
            if numel(this.InterfaceDictsUsedByRootModel)>0
                bepBlks=InterfaceDictionaryValidator.findRootLevelBEPsUsingNonInterfaceDictInterfaces(...
                compositionSys,this.InterfaceDictsUsedByRootModel,IncludeInlinedInterfaces=false);
                for ii=1:numel(bepBlks)
                    bepBlk=bepBlks{ii};





                    interfaceDict=autosar.utils.File.dropPath(this.InterfaceDictsUsedByRootModel{1});
                    this.logWarning(...
                    'autosarstandard:dictionary:UsedInterfaceDefinitionNotInInterfaceDict',...
                    this.RootModelName,getfullname(bepBlk),get_param(bepBlk,'PortName'),interfaceDict);
                end
            end
        end

        function verifyComponentBlockIsLinked(this,componentBlk)


            assert(autosar.composition.Utils.isComponentBlock(componentBlk),...
            '%s it not a component block!',componentBlk);

            if~autosar.composition.Utils.isCompBlockLinked(componentBlk)
                compMdlName=autosar.composition.studio.CompBlockCreateModel.getDefaultMdlName(componentBlk);
                this.logError(...
                'autosarstandard:validation:Composition_ComponentBlockDoesNotHaveBehaviorModel',...
                getfullname(componentBlk),compMdlName);
            end
        end

        function visitRootModel(this)


            if strcmp(this.SystemPathToValidate,this.RootModelName)
                this.verifyCompositionPortInterfaces(this.RootModelName);
            end


            try
                deleteCompile=autosar.validation.CompiledModelUtils.forceCompiledModel(this.RootModelName);
                deleteCompile.delete();
            catch ME
                if~strcmp(ME.identifier,'Simulink:Engine:NoBehaviorsForArchitectureModel')
                    rethrow(ME);
                end
            end

            this.collectCompModelInfo(this.RootModelName);
            this.verifyAutosarCompliantForModel(this.RootModelName);

            if~slfeature('AdaptiveArchitectureModeling')&&...
                Simulink.CodeMapping.isAutosarAdaptiveSTF(this.RootModelName)
                this.logError(...
                'autosarstandard:validation:Composition_AdaptiveNotSupported',...
                this.RootModelName);
            end
        end

        function runPostVisitChecks(this)




            this.checkComponentModelsAutosarCompliant();


            this.checkComponentModelsAreMapped();



            this.MessageLogger.flush(...
            'autosarstandard:validation:CompositionValidationError',...
            onlyErrors=true);


            this.checkSchemaVersionConsistent();




            if this.ExportECUExtract
                this.checkMultiInstanceComponents();
            end


            this.checkNoDuplicateSWCs();



            this.checkNoConnectedRootPortBlocks();





            this.checkComponentModelNotLinkedToSharedAutosarDict();
        end

        function visitAdapterBlocks(this)






            allAdapterBlocks=find_system(this.SystemPathToValidate,...
            'BlockType','SubSystem','SimulinkSubDomain','ArchitectureAdapter');
            errID='autosarstandard:validation:Composition_UnsupportedAdapterMapping';
            for i=1:length(allAdapterBlocks)
                adapterBlockH=get_param(allAdapterBlocks{i},'handle');
                if strcmp(systemcomposer.internal.adapter.getAdapterMode(adapterBlockH),...
                    DAStudio.message('SystemArchitecture:Adapter:ConversionMerge'))



                    continue
                end
                [inputs,outputs]=systemcomposer.internal.adapter.getMappings(adapterBlockH);
                inElemNames=extractAfter(inputs,'.');
                outElemNames=extractAfter(outputs,'.');
                if~isequal(sort(inElemNames),sort(outElemNames))
                    this.logError(errID,getfullname(adapterBlockH));
                end
            end
        end

        function checkComponentModelsAutosarCompliant(this)
            errID='autosarstandard:validation:Composition_ModelNotAutosarCompliant';
            this.applyCheckFcnOnCollectedModels(@(x)x.IsAutosarCompliant,errID);
        end

        function checkComponentModelsAreMapped(this)
            errID='Simulink:Engine:RTWCGAutosarEmptyConfigurationError';
            this.applyCheckFcnOnCollectedModels(@(x)x.IsMapped,errID);
        end

        function checkComponentModelNotLinkedToSharedAutosarDict(this)
            errID='autosarstandard:validation:Composition_ComponentModelLinkedToSharedARDict';
            this.applyCheckFcnOnCollectedModels(@(x)~x.IsLinkedToLegacySharedAutosarDict,errID);
        end

        function applyCheckFcnOnCollectedModels(this,checkFcn,errorID)
            models=this.CompModelToInfoMap.keys;
            allMdlInfos=this.CompModelToInfoMap.values;
            checkPassedArray=cellfun(checkFcn,allMdlInfos,'UniformOutput',false);
            for i=1:length(checkPassedArray)
                if~checkPassedArray{i}
                    this.logError(errorID,models{i});
                end
            end
        end

        function checkSchemaVersionConsistent(this)


            allMdlInfos=this.CompModelToInfoMap.values;
            schemas=cellfun(@(x)x.AutosarSchemaVersion,allMdlInfos,'UniformOutput',false);
            [uniqueSchemas,idx]=unique(schemas,'stable');
            if length(uniqueSchemas)>1
                models=this.CompModelToInfoMap.keys;
                conflictingModels=models(idx);
                conflictingSchemas=schemas(idx);
                this.logError(...
                'autosarstandard:validation:Composition_InconsistentSchemaVersions',...
                autosar.api.Utils.cell2str(conflictingModels),...
                autosar.api.Utils.cell2str(conflictingSchemas));
            end


            modelNames=cellfun(@(x)x.ModelName,allMdlInfos,'UniformOutput',false);
            modelHierarchySchemaVersion=uniqueSchemas{1};


            interfaceDictFilePathsLinkedToModel=this.InterfaceDictsUsedByRootModel;
            for i=1:length(interfaceDictFilePathsLinkedToModel)
                interfaceDictFilePath=interfaceDictFilePathsLinkedToModel{i};
                arProps=autosar.api.getAUTOSARProperties(interfaceDictFilePath);
                if strcmp(arProps.get('XmlOptions','XmlOptionsSource'),'Inherit')

                    continue;
                end
                sharedM3IModel=autosar.dictionary.Utils.getM3IModelForDictionaryFile(interfaceDictFilePath);
                dictSchemaVer=autosar.ui.utils.getAutosarSchemaVersion(sharedM3IModel);
                if~strcmp(dictSchemaVer,uniqueSchemas)



                    if length(modelNames)>1
                        errorMsgId=...
                        'autosarstandard:validation:Composition_InconsistentSchemaVersionsWithInterfaceDictionary';
                    else
                        errorMsgId=...
                        'autosarstandard:validation:Composition_InconsistentSchemaVersionWithInterfaceDictionary';
                    end

                    this.logError(...
                    errorMsgId,...
                    autosar.api.Utils.cell2str(modelNames),...
                    modelHierarchySchemaVersion,...
                    autosar.utils.File.dropPath(interfaceDictFilePath),...
                    dictSchemaVer);
                end
            end
        end

        function checkMultiInstanceComponents(this)
            allMdlInfos=this.CompModelToInfoMap.values;
            allComponentBlocks=cellfun(@(x)x.ReferencedBy,allMdlInfos,'UniformOutput',false);
            for i=1:length(allComponentBlocks)
                componentBlocks=allComponentBlocks{i};
                if length(componentBlocks)>1


                    [~,componentModel]=autosar.composition.Utils.isCompBlockLinked(componentBlocks{1});
                    if strcmp(get_param(componentModel,'CodeInterfacePackaging'),'Nonreusable function')
                        this.logError(...
                        'autosarstandard:validation:Composition_InvalidCodeInterfacePackaging',...
                        componentModel);
                    end
                end
            end
        end

        function checkNoDuplicateSWCs(this)
            allMdlInfos=this.CompModelToInfoMap.values;
            models=this.CompModelToInfoMap.keys;
            allCompositionBlocksInfo=this.CompositionBlockToInfoMap.values;
            compositionBlocks=this.CompositionBlockToInfoMap.keys;
            swcCompNames=cellfun(@(x)x.ComponentName,allMdlInfos,'UniformOutput',false);
            swcParamNames=cellfun(@(x)x.UsedSwcParamNames,allMdlInfos,'UniformOutput',false);
            compositionNames=cellfun(@(x)x.CompositionName,allCompositionBlocksInfo,'UniformOutput',false);










            swcParamNames=unique([swcParamNames{:}]);


            allCompNames=[swcCompNames,swcParamNames,compositionNames];
            duplicateCompNames=this.findDuplicates(allCompNames);

            if~isempty(duplicateCompNames)
                modeledCompNames=[swcCompNames,compositionNames];
                modelsAndBlocksDefiningTypes=[models,compositionBlocks];
                firstDuplicateCompName=duplicateCompNames{1};
                conflictingIdx=strcmp(modeledCompNames,firstDuplicateCompName);
                conflictingSystems=modelsAndBlocksDefiningTypes(conflictingIdx);


                if length(conflictingSystems)<2
                    for i=1:length(swcParamNames)
                        if~isempty(swcParamNames{i})
                            conflictingIdx=strcmp(swcParamNames{i},firstDuplicateCompName);
                            if~isempty(find(conflictingIdx,1))
                                conflictingSystems{end+1}=models{i};%#ok<AGROW>
                            end
                        end
                    end
                end

                m3iModel=autosar.api.Utils.m3iModel(this.RootModelName);
                newName=this.getUniqueCompName(m3iModel,firstDuplicateCompName);
                if autosar.arch.Utils.isSubSystem(conflictingSystems{2})
                    this.logError(...
                    'autosarstandard:validation:Composition_DuplicateCompositionNames',...
                    conflictingSystems{1},conflictingSystems{2},firstDuplicateCompName,newName);
                else
                    this.logError(...
                    'autosarstandard:validation:Composition_DuplicateSWCNames',...
                    conflictingSystems{1},conflictingSystems{2},firstDuplicateCompName,newName);
                end
            end
        end

        function newName=getUniqueCompName(this,m3iModel,defaultName)%#ok<INUSD>

            m3iExistingComps=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.component.Component.MetaClass,true,true);
            excludeNames=m3i.mapcell(@(x)x.Name,m3iExistingComps);
            newName=autosar.api.Utils.makeUniqueCaseInsensitiveStrings(...
            arxml.arxml_private('p_create_aridentifier',defaultName,128),...
            excludeNames,128);
        end

        function checkNoConnectedRootPortBlocks(this)
            allMdlInfos=this.CompModelToInfoMap.values;
            allComponentBlocks=cellfun(@(x)x.ReferencedBy,allMdlInfos,'UniformOutput',false);

            allComponentBlocks=[allComponentBlocks{:}];
            for curCompBlock=allComponentBlocks
                this.verifyNoConnectedRootPorts(curCompBlock{1});
            end
        end

        function logError(this,identifier,varargin)

            this.MessageLogger.logError(identifier,varargin{:});
        end

        function logWarning(this,identifier,varargin)

            this.MessageLogger.logWarning(identifier,varargin{:});
        end


        function collectCompModelInfo(this,sys)
            sys=getfullname(sys);
            collectingInfoForComponentModel=contains(sys,'/');

            if collectingInfoForComponentModel
                [isLinked,modelName]=autosar.composition.Utils.isCompBlockLinked(sys);
                assert(isLinked,'expected a linked component block');
            else
                modelName=sys;
            end



            if collectingInfoForComponentModel&&this.CompModelToInfoMap.isKey(modelName)
                info=this.CompModelToInfoMap(modelName);
                info.ReferencedBy=[info.ReferencedBy,{sys}];
                this.CompModelToInfoMap(modelName)=info;
                return;
            end



            info=this.newCompModelInfo();
            info.ModelName=modelName;
            if collectingInfoForComponentModel
                info.ReferencedBy={sys};
                info.IsMapped=this.isComponentMapped(modelName);
            else
                info.IsMapped=autosar.api.Utils.isMappedToComposition(modelName);
            end

            info.IsAutosarCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');

            if~info.IsAutosarCompliant||~info.IsMapped


                this.CompModelToInfoMap(modelName)=info;
                return
            end


            info.AutosarSchemaVersion=get_param(modelName,'AutosarSchemaVersion');


            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            info.ComponentName=m3iComp.Name;
            if m3iComp.has('Kind')
                info.ComponentKind=m3iComp.Kind.toString;
            end
            info.ComponentPkg=autosar.api.Utils.getQualifiedName(m3iComp.containerM3I);

            if collectingInfoForComponentModel

                info.UsedSwcParamNames=this.collectParameterSWCInfo(modelName);
            end


            info.InterfaceDictsUsedByRootModel=this.InterfaceDictsUsedByRootModel;
            info.AllDictsInterfaceNames=this.AllDictsInterfaceNames;
            interfaceDictsUsedByModel=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
            if~isempty(interfaceDictsUsedByModel)
                info.ReferencedInterfaceDicts=interfaceDictsUsedByModel;
            elseif autosar.api.Utils.isUsingSharedAutosarDictionary(modelName)




                info.IsLinkedToLegacySharedAutosarDict=true;
            end


            this.CompModelToInfoMap(modelName)=info;



            if collectingInfoForComponentModel
                this.collectTypeInfoForMappedDataElements(modelName);
            end
        end

        function collectCompositionBlockInfo(this,sys)

            info=this.newCompositionBlockInfo();
            compositionName=get_param(sys,'Name');
            info.CompositionName=compositionName;


            this.CompositionBlockToInfoMap(getfullname(sys))=info;
        end


        function paramSwcNames=collectParameterSWCInfo(this,modelName)
            import autosar.composition.validation.Validator

            paramSwcNames={};

            vars=[];
            try
                vars=autosar.validation.CompiledModelUtils.getReferencedWSVars(modelName,false);
            catch ME
                if strcmp(ME.identifier,'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate')
                    assert(strcmp(get_param(this.RootModelName,'EnableParallelModelReferenceBuilds'),'on'),...
                    'Cached compile info should be available except in context of parallel builds.');





                    varInfoFile=fullfile(slprivate('getVarCacheFilePath',modelName),'varInfo.mat');


                    if exist(varInfoFile,'file')
                        vars=Validator.getUsedGlobalVarsFromVarInfoMatFile(modelName,varInfoFile);
                    end
                end
            end

            for i=1:length(vars)
                obj=vars(i).obj;


                if((isa(obj,'AUTOSAR.Parameter')&&...
                    strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&...
                    strcmp(obj.CoderInfo.CustomStorageClass,'CalPrm')))
                    paramSwcQName=obj.CoderInfo.CustomAttributes.CalibrationComponent;
                    if~isempty(paramSwcQName)
                        [~,paramSwcName]=autosar.utils.splitQualifiedName(paramSwcQName);
                        if~isempty(paramSwcName)
                            paramSwcNames{end+1}=paramSwcName;%#ok<AGROW>
                        end
                    end
                end
            end

            paramSwcNames=unique(paramSwcNames);
        end

        function collectTypeInfoForMappedDataElements(this,modelName)





            deleteCompile=autosar.validation.CompiledModelUtils.forceCompiledModel(modelName);%#ok<NASGU>

            mapping=autosar.api.Utils.modelMapping(modelName);
            ports=[mapping.Inports,mapping.Outports];
            isInport=[ones(size(mapping.Inports)),zeros(size(mapping.Outports))];

            for portIdx=1:length(ports)
                curPort=ports(portIdx);

                if isa(curPort.MappedTo,'Simulink.AutosarTarget.PortElement')&&...
                    any(strcmp(curPort.MappedTo.DataAccessMode,{'ErrorStatus','IsUpdated'}))


                    continue;
                end


                compiledPortDataType=get_param(curPort.Block,'CompiledPortDataTypes');
                compiledPortWidths=get_param(curPort.Block,'CompiledPortWidths');
                if isInport(portIdx)
                    portProperty='Outport';
                else
                    portProperty='Inport';
                end

                if isempty(compiledPortDataType)||isempty(compiledPortWidths)



                    continue;
                end

                portType=compiledPortDataType.(portProperty);
                portWidth=compiledPortWidths.(portProperty);

                dataElementQualifiedName=...
                this.getDataElementQNameFromMapping(curPort,modelName);

                if this.DataElementQNameToSlPortTypeInfoMap.isKey(dataElementQualifiedName)

                    existingSlPortInfo=...
                    this.DataElementQNameToSlPortTypeInfoMap(dataElementQualifiedName);
                    if~(strcmp(portType,existingSlPortInfo.portType)&&...
                        isequal(portWidth,existingSlPortInfo.portWidth))
                        this.logError('autosarstandard:validation:Composition_InterfaceInconsistent',...
                        existingSlPortInfo.PortPath,curPort.Block,dataElementQualifiedName);
                    end
                else

                    slPortTypeInfo.PortPath=curPort.Block;
                    slPortTypeInfo.portType=portType;
                    slPortTypeInfo.portWidth=portWidth;
                    this.DataElementQNameToSlPortTypeInfoMap(dataElementQualifiedName)=...
                    slPortTypeInfo;
                end

            end
        end

        function info=newCompositionBlockInfo(this)%#ok<MANU>
            info=struct();

            info.CompositionName='';
        end
        function info=newCompModelInfo(this)%#ok<MANU>
            info=struct();

            info.ModelName='';
            info.IsAutosarCompliant=false;
            info.IsMapped=false;
            info.AutosarSchemaVersion='';
            info.IsLinkedToLegacySharedAutosarDict=false;
            info.ReferencedInterfaceDicts={};

            info.ComponentName='';
            info.ComponentKind='';
            info.ComponentPkg='';

            info.ReferencedBy={};

            info.UsedSwcParamNames={};
        end

        function isMapped=isComponentMapped(this,modelName)
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(this.RootModelName)
                isMapped=autosar.api.Utils.isMappedToAdaptiveApplication(modelName);
            else
                isMapped=autosar.api.Utils.isMappedToComponent(modelName);
            end
        end

        function dataElementQualifiedName=getDataElementQNameFromMapping(this,blockMapping,modelName)


            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            isAdaptive=Simulink.CodeMapping.isAutosarAdaptiveSTF(this.RootModelName);

            elementMappingName='Element';
            if isAdaptive
                elementMappingName='Event';
            end

            arPortName=blockMapping.MappedTo.Port;
            arDataElementName=blockMapping.MappedTo.(elementMappingName);

            m3iPort=autosar.mm.Model.findM3IPortByName(m3iComp,arPortName);

            if~m3iPort.isvalid()



                componentAdapter=autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(modelName);
                defaultItfName=componentAdapter.getAutosarInterfaceName(blockMapping.Block);
                defaultItfPackage=m3iComp.modelM3I.RootPackage.front.InterfacePackage;
                dataElementQualifiedName=[defaultItfPackage,'/'...
                ,defaultItfName,'/',arDataElementName];
            else
                m3iInterface=m3iPort.Interface;
                switch class(m3iInterface)
                case 'Simulink.metamodel.arplatform.interface.ServiceInterface'
                    elementPropName='Events';
                otherwise
                    elementPropName='DataElements';
                end

                if isa(m3iInterface,'Simulink.metamodel.arplatform.interface.ModeSwitchInterface')
                    m3iDataElement=m3iInterface.ModeGroup;
                else
                    m3iDataElement=autosar.mm.Model.findElementInSequenceByName(...
                    m3iInterface.(elementPropName),arDataElementName);
                end
                if isempty(m3iDataElement)



                    assert(autosar.composition.Utils.isCompositePortBlock(blockMapping.Block));
                    dataElementQualifiedName=[autosar.api.Utils.getQualifiedName(m3iInterface),...
                    '/',arDataElementName];
                else
                    dataElementQualifiedName=autosar.api.Utils.getQualifiedName(m3iDataElement);
                end
            end
        end

        function canInfer=canInferInterfaceForPort(this,port,isInport)




            portData=get_param(port,'PortConnectivity');

            if isInport
                portProp='DstBlock';
            else
                portProp='SrcBlock';
            end

            isConnected=~isempty(portData.(portProp))&&~isequal(portData.(portProp),-1);

            if~isConnected






                [isUsingBusObj,busObjName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(port);
                if isUsingBusObj&&any(strcmp(autosar.utils.StripPrefix(busObjName),this.AllDictsInterfaceNames))
                    canInfer=true;
                    return;
                end


                if autosar.composition.Utils.isCompositionBlock(get_param(port,'Parent'))


                    if autosar.composition.validation.Validator.isPortConnectedOutsideComposition(port,isInport)




                        canInfer=true;
                        return;
                    else


                    end
                else



                end
                m3iPort=...
                autosar.composition.Utils.findM3IPortForCompositePort(...
                getfullname(port));
                canInfer=m3iPort.Interface.isvalid();
            else




                canInfer=true;
            end
        end
    end

    methods(Static,Access=private)
        function wsVar=getUsedGlobalVarsFromVarInfoMatFile(modelName,varInfoFile)


            wsVar=[];
            varInfo=load(varInfoFile);
            usedVars=varInfo.GlobalWorkspace;
            for i=1:size(usedVars,2)
                usedVar=usedVars(1:end,i);
                usedVarName=usedVar{1};
                wsVar(end+1).objName=usedVarName;%#ok
                wsVar(end).obj=Simulink.data.internal.getModelGlobalVariable(...
                modelName,usedVarName);
            end
        end

        function duplicates=findDuplicates(names)

            numNames=length(names);
            [~,unique_name_indices]=unique(names);
            duplicates=unique(names(setdiff(1:numNames,unique_name_indices)));
        end

        function isConnected=isPortConnectedOutsideComposition(port,isInport)



            compositionBlkH=get_param(port,'Parent');


            relevantPortNum=str2double(get_param(port,'Port'));


            compBlkPortHandles=get_param(compositionBlkH,'PortHandles');
            if isInport
                compBlkPortHandles=compBlkPortHandles.Inport;
                lineEndProp='SrcBlockHandle';
            else
                compBlkPortHandles=compBlkPortHandles.Outport;
                lineEndProp='DstBlockHandle';
            end
            portNums=get_param(compBlkPortHandles,'PortNumber');
            if iscell(portNums)

                portNums=cell2mat(portNums);
            end

            relevantPortH=compBlkPortHandles(portNums==relevantPortNum);
            assert(length(relevantPortH)==1,'Expected to find 1 port');

            lineH=get_param(relevantPortH,'Line');
            if lineH==-1

                isConnected=false;
            else
                connectedBlkH=get_param(lineH,lineEndProp);
                isConnected=~isempty(connectedBlkH)&&connectedBlkH~=-1;
            end
        end
    end
end



