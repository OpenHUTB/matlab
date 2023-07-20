classdef ModelBuilder<handle






    properties
        CodeDescriptor;
        CodeDescriptorCache;
        XmlOpts;
        msgStream;
    end

    properties(Access=private)
        m3iSWC;
        m3iSWCPkg;
        m3iBehavior;
        m3iInterfacePkg;
        m3iDataTypePkg;
        m3iConstantPkg;
        m3iUsedDataElement2ServiceDependencyQNameMap;
        MaxShortNameLength;
        ModelName;
        TypeBuilder;
        ConstantBuilder;
        ExpInports;
        CodeDescParamAdapter;
        Prm2LutStructMap;
        Prm2OperatingPointsMap;
        PortOperation2TimeoutMap;
        SymbolicDefinitions;
        ApplicationTypeTracker;
        isAdaptiveAutosar;
        VariationPointMerger;
        M3IElementFactory;
        VariantBuilder autosar.mm.sl2mm.variant.VariantBuilder
    end


    properties(Dependent)

        LocalM3IModel;



        SharedM3IModel;
    end


    methods



        function this=ModelBuilder(codeDescriptor,mdlName,varargin)
            this.ExpInports=[];
            if nargin==3
                this.ExpInports=varargin{1};
            end

            this.CodeDescriptor=codeDescriptor;

            this.ModelName=mdlName;
            this.isAdaptiveAutosar=Simulink.CodeMapping.isAutosarAdaptiveSTF(mdlName);

            dataObj=autosar.api.getAUTOSARProperties(mdlName);
            this.XmlOpts.InterfacePackage=dataObj.get('XmlOptions','InterfacePackage');
            this.XmlOpts.ComponentName=dataObj.get('XmlOptions','ComponentQualifiedName');
            this.XmlOpts.BehaviorName=dataObj.get('XmlOptions','InternalBehaviorQualifiedName');
            this.XmlOpts.ImplementationName=dataObj.get('XmlOptions','ImplementationQualifiedName');
            this.XmlOpts.DataTypePackage=dataObj.get('XmlOptions','DataTypePackage');
            if slfeature('AUTOSARLUTRecordValueSpec')>0&&~this.isAdaptiveAutosar
                this.XmlOpts.LUTApplValueSpec=dataObj.get('XmlOptions',...
                'ExportLookupTableApplicationValueSpecification');
            else
                this.XmlOpts.LUTApplValueSpec=true;
            end

            this.MaxShortNameLength=...
            get_param(mdlName,'AutosarMaxShortNameLength');

            this.msgStream=autosar.mm.util.MessageStreamHandler.instance();
            this.PortOperation2TimeoutMap=containers.Map();
            this.SymbolicDefinitions=containers.Map();
            if~isempty(this.CodeDescriptor)
                for def=this.CodeDescriptor.getFullComponentInterface.SymbolicDimensionDefinitions.toArray
                    this.SymbolicDefinitions(def.Name)=def.DynamicTypedValue;
                end
            end
            this.ApplicationTypeTracker=autosar.mm.sl2mm.ApplicationTypeTracker();

            this.CodeDescriptorCache=autosar.mm.sl2mm.CodeDescriptorCache();
            this.CodeDescParamAdapter=...
            autosar.mm.sl2mm.refmodel.CodeDescParamAdapter(this.CodeDescriptor,this.CodeDescriptorCache);


            this.M3IElementFactory=autosarcore.ModelUtils.getM3IElementFactory(this.ModelName);
        end

        function m3iModel=get.LocalM3IModel(this)
            m3iModel=this.M3IElementFactory.getLocalModel();
        end

        function m3iModel=get.SharedM3IModel(this)
            m3iModel=this.M3IElementFactory.getSharedModel();
        end

        function m3iModel=build(this)
            this.initializeLookupData();
            this.ConstantBuilder=autosar.mm.sl2mm.ConstantBuilder();


            autosar.ui.utils.closeDictionaryUI(this.ModelName);


            assert((this.LocalM3IModel.unparented.size()==0),...
            'Unparented objects in m3iModel before build');
            tran=M3I.Transaction(this.LocalM3IModel);
            if this.LocalM3IModel~=this.SharedM3IModel
                assert((this.SharedM3IModel.unparented.size()==0),...
                'Unparented objects in sharedM3IModel before build');
                tranShared=M3I.Transaction(this.SharedM3IModel);
            end



            autosar.mm.sl2mm.ModelBuilder.destroyDTMappingSetsWithInvalidRefs(this.SharedM3IModel);


            this.xformXmlOptsPackages();
            this.xformXmlOptsSWC();

            this.constructVariantBuilder();
            this.constructTypeBuilder();

            if this.isAdaptiveAutosar
                this.xformCodeDescriptorInports();
                this.xformCodeDescriptorOutports();
                autosar.internal.adaptive.manifest.ManifestUtilities.syncManifestMetaModelWithAutosarDictionary(this.ModelName);
                autosar.mm.sl2mm.ModelBuilder.destroyLegacyClassicSwBaseTypes(this.SharedM3IModel);

                this.xformCodeDescriptorPerCallPoints();

                this.xformCodeDescriptorServerFunctions();
                this.xformCodeDescriptorFunctionCalls();
            else
                this.VariantBuilder.findOrCreatePredefinedVariants();
                this.xformCodeDescriptorRunnables();
                this.xformCodeDescriptorInports();
                this.xformCodeDescriptorOutports();
                this.xformCodeDescriptorServerCallPoints();
                this.xformCodeDescriptorInternalData();


                this.xformCodeDescriptorParameters();
                this.xformCodeDescriptorDataStores();
                this.xformCodeDescriptorGlobalVariables();
                this.xformInternalDataVariables();
                this.xformCodeDescriptorDirectReads();
                this.xformCodeDescriptorDirectWrites();
                this.xformCodeDescriptorRunnableServerCallPoints();
                this.xformExclusiveAreasForSubSystems();
                this.xformVariationPointProxies();
                this.xformSymbolicDimensionDefinitions();
                this.xformCodeDescriptorTimingInformation();
                this.xformIncludedDataTypeSets();


                autosar.mm.sl2mm.PlatformTypesDecorator.moveToPlatformTypesPackage(this.SharedM3IModel);

                exclusiveAreaCleaner=autosar.mm.sl2mm.utils.ExclusiveAreasCleaner(this.m3iBehavior);
                exclusiveAreaCleaner.cleanup();


                swcViewBuilder=autosar.timing.sl2mm.SwcViewBuilder(this.ModelName);
                swcViewBuilder.build();
            end

            this.VariantBuilder.cleanup();


            reRegisterListener=autosarcore.unregisterListenerCBTemporarily(this.LocalM3IModel);%#ok<NASGU>
            if this.LocalM3IModel~=this.SharedM3IModel
                reRegisterListenerShared=autosarcore.unregisterListenerCBTemporarily(this.SharedM3IModel);%#ok<NASGU>



                sharedDictFilePath=Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel(this.SharedM3IModel);
                dictM3IModelListener=autosar.mm.observer.ObserverSharedDictionaryDuringBuild(sharedDictFilePath);
                M3I.registerObservingListener(this.SharedM3IModel,dictM3IModelListener);
                removeDictListener=onCleanup(@()M3I.unregisterObservingListener(this.SharedM3IModel,dictM3IModelListener));

                tranShared.commit();
            end


            isDirtyBeforeCommit=strcmp(get_param(this.ModelName,'Dirty'),'on');
            timeStampBeforeCommit=get_param(this.ModelName,'RTWModifiedTimestamp');
            tran.commit();



            autosar.api.Utils.setM3iModelDirty(this.ModelName);
            set_param(this.ModelName,'RTWModifiedTimestamp',timeStampBeforeCommit);
            if~isDirtyBeforeCommit
                set_param(this.ModelName,'Dirty','off');
            end
            assert((this.LocalM3IModel.unparented.size()==0),'Unparented objects after build');
            assert((this.SharedM3IModel.unparented.size()==0),'Unparented objects for shared m3iModel after build');

            m3iModel=this.LocalM3IModel;
        end

        function[appTypeNames,modeGroupNames]=getAppTypeNamesUsedByModel(this)
            appTypeNames=this.ApplicationTypeTracker.getAppTypeNames();
            modeGroupNames=this.ApplicationTypeTracker.getModeGroupNames();










            codeInfo=this.CodeDescriptor.getComponentInterface();
            if~isempty(codeInfo.Types)
                typeNamesUsedInGeneratedCode={codeInfo.Types.Name};
                [app2ImpMap,~,mode2ImpMap]=autosar.api.Utils.app2ImpMap(this.ModelName);

                appTypes=app2ImpMap.keys;
                for i=1:length(appTypes)
                    appType=appTypes{i};
                    if any(strcmp(appType,typeNamesUsedInGeneratedCode))
                        appTypeNames{end+1}=appType;%#ok<AGROW>
                    end
                end

                modeGroups=mode2ImpMap.keys;
                for i=1:length(modeGroups)
                    modeGroup=modeGroups{i};
                    if any(strcmp(modeGroup,typeNamesUsedInGeneratedCode))
                        modeGroupNames{end+1}=modeGroup;%#ok<AGROW>
                    end
                end
            end
        end
    end

    methods(Access=private)




        function createOrUpdateComSpecInitValue(this,m3iComSpec,m3iType,isTypeEquivalent,accessType,sigBlk)
            needToCreateInitValue=true;

            initValuePropName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iComSpec);
            useInitValue=strcmp(initValuePropName,'InitValue');

            sigInvBlkPresent=strcmp(accessType,'ExplicitSend')&&~isempty(sigBlk);
            dataDictionary=get_param(this.ModelName,'DataDictionary');

            createNewConstantIfNecessary=false;

            if sigInvBlkPresent

                userInputInitValue=get_param(sigBlk,'InitialOutput');


                userInputInitValue=...
                autosar.ui.comspec.ComSpecPropertyHandler.convertValueExpressionToScalarValueString(...
                this.ModelName,userInputInitValue);


                metaModelInitValue=autosar.ui.comspec.ComSpecPropertyHandler.buildSlInitValueFromMetaModel(...
                m3iComSpec,dataDictionary,createNewConstantIfNecessary);
                metaModelInitValueStr=autosar.ui.comspec.ComSpecPropertyHandler.convertValueToString(metaModelInitValue);
                if strcmp(userInputInitValue,metaModelInitValueStr)


                    userInputInitValue='';
                end
            else

                userInputInitValue=...
                autosar.ui.comspec.ComSpecPropertyHandler.getUserInputInitValue(m3iComSpec);
            end

            if~isempty(userInputInitValue)
                userInputInitValue=str2double(userInputInitValue);
            elseif isTypeEquivalent
                if useInitValue
                    m3iInitValue=m3iComSpec.InitValue;
                else
                    m3iInitValue=m3iComSpec.InitialValue;
                end
                needToCreateInitValue=~autosar.mm.sl2mm.ConstantBuilder.checkOrUpdateComSpecInitValue(...
                m3iInitValue,m3iType,this.SymbolicDefinitions);
            end

            if needToCreateInitValue
                if isempty(userInputInitValue)





                    try
                        userInputInitValue=autosar.ui.comspec.ComSpecPropertyHandler.getComSpecPropertyValueStr(...
                        m3iComSpec,initValuePropName,dataDictionary,createNewConstantIfNecessary);
                        userInputInitValue=...
                        autosar.ui.comspec.ComSpecPropertyHandler.convertValueStrToValue(userInputInitValue);
                    catch






                    end
                end
                if userInputInitValue==0

                    userInputInitValue=[];
                end
                this.doCreateOrUpdateInitValue(m3iComSpec,m3iType,userInputInitValue);
            end



            if~isempty(userInputInitValue)
                autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
                m3iComSpec,'InitValue',userInputInitValue);
            end
        end


        function createOrUpdateInitValue(this,m3iData,m3iType,isTypeEquivalent)
            needToCreateInitValue=true;

            if isTypeEquivalent
                propName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iData);
                m3iInitValue=m3iData.(propName);
                needToCreateInitValue=~autosar.mm.sl2mm.ConstantBuilder.checkOrUpdateComSpecInitValue(...
                m3iInitValue,m3iType,this.SymbolicDefinitions);
            end

            if needToCreateInitValue
                this.doCreateOrUpdateInitValue(m3iData,m3iType,[]);
            end
        end


        function doCreateOrUpdateInitValue(this,m3iData,m3iType,initValue)

            propName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iData);
            useInitValue=strcmp(propName,'InitValue');

            if useInitValue
                if~isempty(m3iData.InitValue)&&m3iData.InitValue.isvalid()

                    m3iData.InitValue.destroy();
                end
                initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype(m3iType.Name,this.MaxShortNameLength);
                m3iData.InitValue=autosar.mm.sl2mm.ConstantBuilder.updateOrCreateValueSpecification(m3iData.rootModel,...
                [],[],m3iType,this.MaxShortNameLength,...
                initValueName,initValue,this.SymbolicDefinitions);
            else
                if isempty(initValue)
                    m3iConstantSpec=autosar.mm.sl2mm.ConstantBuilder.findOrCreateConstantSpecificationFromTypeGroundValue(...
                    this.SharedM3IModel,this.m3iConstantPkg,m3iType,...
                    this.MaxShortNameLength,this.SymbolicDefinitions);
                else
                    m3iConstantSpec=autosar.mm.sl2mm.ConstantBuilder.findOrCreateConstantSpecificationFromScalarValue(...
                    this.SharedM3IModel,this.m3iConstantPkg,m3iType,...
                    this.MaxShortNameLength,initValue,this.SymbolicDefinitions);
                end
                m3iData.(propName)=m3iConstantSpec.ConstantValue;
            end
        end

        function createOrUpdateInvalidationPolicy(~,m3iData,sigBlk)

            if~isempty(sigBlk)
                invPolicy=get_param(sigBlk,'InvalidationPolicy');
                switch invPolicy
                case{'Keep'}
                    m3iData.InvalidationPolicy=...
                    Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.Keep;
                case{'Replace'}
                    m3iData.InvalidationPolicy=...
                    Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.Replace;
                case{'DontInvalidate'}
                    m3iData.InvalidationPolicy=...
                    Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.DontInvalidate;
                otherwise
                    m3iData.InvalidationPolicy='None';
                end
            end
        end


        function initializeLookupData(this)
            parameters=this.getCodeDescriptorDataInterfaces('Parameters');
            this.Prm2LutStructMap=containers.Map();
            this.Prm2OperatingPointsMap=containers.Map();
            for indx=1:numel(parameters)
                lookupTable=parameters(indx);
                if~isa(lookupTable,'coder.descriptor.LookupTableDataInterface')
                    continue;
                end
                if~this.Prm2LutStructMap.isKey(lookupTable.GraphicalName)
                    this.Prm2LutStructMap(lookupTable.GraphicalName)=indx;
                else

                end
                axisCount=lookupTable.Breakpoints.Size();
                for axisIndx=1:axisCount
                    lookupTableAxis=lookupTable.Breakpoints(axisIndx);

                    if~isempty(lookupTableAxis.OperatingPoint)
                        if~this.Prm2OperatingPointsMap.isKey(lookupTableAxis.GraphicalName)
                            this.Prm2OperatingPointsMap(lookupTableAxis.GraphicalName)={[indx,axisIndx]};
                        else
                            values=this.Prm2OperatingPointsMap(lookupTableAxis.GraphicalName);
                            entryAdded=false;
                            for ii=1:numel(values)
                                if values{ii}(1)==indx&&values{ii}(2)==axisIndx
                                    entryAdded=true;
                                    break;
                                end
                            end
                            if~entryAdded
                                this.Prm2OperatingPointsMap(lookupTableAxis.GraphicalName)=[values,[indx,axisIndx]];
                            end
                        end
                    end
                end
            end
        end

        function xformXmlOptsPackages(this)

            import autosar.mm.Model;
            import autosar.mm.util.XmlOptionsAdapter;

            m3iRootShared=this.SharedM3IModel.RootPackage.front();


            compPath=this.getNodePathAndName(this.XmlOpts.ComponentName);
            this.m3iSWCPkg=this.M3IElementFactory.getOrAddARPackage('AtomicComponent',compPath);
            this.m3iInterfacePkg=...
            this.M3IElementFactory.getOrAddARPackage('Interface',this.XmlOpts.InterfacePackage);
            this.m3iDataTypePkg=...
            this.M3IElementFactory.getOrAddARPackage('DataType',this.XmlOpts.InterfacePackage);



            implPath=this.getNodePathAndName(this.XmlOpts.ImplementationName);
            Model.getOrAddARPackage(this.LocalM3IModel,implPath);


            constPkg=XmlOptionsAdapter.get(m3iRootShared,'ConstantSpecificationPackage');
            if isempty(constPkg)
                constPkg=[this.XmlOpts.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.ConstantSpecifications];
                XmlOptionsAdapter.set(m3iRootShared,'ConstantSpecificationPackage',...
                constPkg);
            end
            this.m3iConstantPkg=...
            this.M3IElementFactory.getOrAddARPackage('ConstantSpecification',constPkg);


            basePkg=XmlOptionsAdapter.get(m3iRootShared,'SwBaseTypePackage');
            if isempty(basePkg)
                basePkg=[this.XmlOpts.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.SwBaseTypes];
                XmlOptionsAdapter.set(m3iRootShared,'SwBaseTypePackage',basePkg);
            end
            this.M3IElementFactory.getOrAddARPackage('SwBaseType',basePkg);


            XmlOptionsAdapter.set(m3iRootShared,'ImplementationTypeReference',...
            XmlOptionsAdapter.get(m3iRootShared,'ImplementationTypeReference'));
            XmlOptionsAdapter.set(m3iRootShared,'SwCalibrationAccessDefault',...
            XmlOptionsAdapter.get(m3iRootShared,'SwCalibrationAccessDefault'));
            XmlOptionsAdapter.set(m3iRootShared,'CompuMethodDirection',...
            XmlOptionsAdapter.get(m3iRootShared,'CompuMethodDirection'));
        end

        function constructTypeBuilder(this)
            args={this.SharedM3IModel,this.m3iBehavior,this.MaxShortNameLength,...
            this.ModelName,this.XmlOpts,[],...
            this.ApplicationTypeTracker};
            this.TypeBuilder=autosar.mm.sl2mm.TypeBuilder(args{:});
        end

        function constructVariantBuilder(this)
            this.VariantBuilder=autosar.mm.sl2mm.variant.VariantBuilder(...
            this.ModelName,...
            this.LocalM3IModel,...
            this.SharedM3IModel,...
            this.XmlOpts.DataTypePackage,...
            this.m3iBehavior,...
            this.m3iSWC,...
            this.CodeDescriptor);
        end

        function result=getPackageUri(~,aClass)
            aPackage=aClass.package;
            result=aPackage.uri;
            while strcmp(result,'')
                aPackage=aPackage.nestingPackage;
                result=aPackage.uri;
            end
        end

        function xformXmlOptsSWC(this)
            import Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior;
            import Simulink.metamodel.arplatform.instance.ComponentInstanceRef;


            if this.isAdaptiveAutosar
                componentType='AdaptiveApplication';
            else
                componentType='Atomic';
            end
            this.m3iSWC=this.findOrCreateComponentSWC(componentType,...
            this.XmlOpts.ComponentName);

            if~this.m3iSWC.instanceMapping.isvalid()
                this.M3IElementFactory.createElement(this.m3iSWC,'instanceMapping',ComponentInstanceRef.MetaClass);
            else
                irefDeleter=autosar.mm.util.InstanceRefDeleter(this.m3iSWC);
                irefDeleter.delete();
            end


            if this.m3iSWC.Behavior.isvalid()








                evt2RunnableMap=containers.Map();
                evt2InternalTriggeringPointMap=containers.Map();
                for idx=1:this.m3iSWC.Behavior.Events.size()
                    evtObj=this.m3iSWC.Behavior.Events.at(idx);

                    if evtObj.StartOnEvent.isvalid()
                        evt2RunnableMap(evtObj.Name)=evtObj.StartOnEvent.Name;
                    end
                    if isa(evtObj,'Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent')&&...
                        evtObj.InternalTriggeringPoint.isvalid()
                        evt2InternalTriggeringPointMap(evtObj.Name)=...
                        autosar.api.Utils.getQualifiedName(evtObj.InternalTriggeringPoint);
                    end
                end






                slVariantSS=find_system(this.ModelName,...
                'MatchFilter',@Simulink.match.activeVariants,...
                'BlockType','SubSystem','Variant','on',...
                'VariantActivationTime','code-compile');

                variantNames=cell(1,length(slVariantSS));
                index=1;
                for ii=1:length(slVariantSS)
                    variants=get_param(slVariantSS{ii},'Variants');
                    for varIndex=1:length(variants)
                        variantNames{index}=variants(varIndex).Name;
                        index=index+1;
                    end
                end


                vpp2SysConstMap=containers.Map();
                for idx=1:this.m3iSWC.Behavior.variationPointProxy.size()
                    m3iVPPObj=this.m3iSWC.Behavior.variationPointProxy.at(idx);
                    if~isempty(m3iVPPObj.ConditionAccess)
                        vpp2SysConstMap(m3iVPPObj.Name)=m3iVPPObj.ConditionAccess.SysConst;
                    end

                    if~isempty(m3iVPPObj.ValueAccess)
                        vpp2SysConstMap(m3iVPPObj.Name)=m3iVPPObj.ValueAccess.SysConst;
                    end
                end


                m3iAccessSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByParentMetaClass(this.m3iSWC.Behavior,...
                Simulink.metamodel.arplatform.behavior.OperationAccess.MetaClass,...
                true);
                for idx=1:m3iAccessSeq.size()
                    m3iAccess=m3iAccessSeq.at(idx);
                    if m3iAccess.instanceRef.size()==1
                        m3iInstanceRef=m3iAccess.instanceRef.at(1);
                        if m3iInstanceRef.Port.isvalid()&&...
                            m3iInstanceRef.Operations.isvalid()
                            portName=m3iInstanceRef.Port.Name;
                            operationName=m3iInstanceRef.Operations.Name;
                            timeout=m3iAccess.Timeout;

                            this.PortOperation2TimeoutMap([portName,'.',operationName])=timeout;
                        end
                    end
                end




                m3iIrvQNameToLiteralText=containers.Map();
                for idx=1:this.m3iSWC.Behavior.IRV.size()
                    m3iObj=this.m3iSWC.Behavior.IRV.at(idx);
                    propName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iObj);
                    if strcmp(propName,'InitValue')
                        m3iInitValue=m3iObj.(propName);
                        if m3iInitValue.isvalid()&&isa(m3iInitValue,'Simulink.metamodel.types.EnumerationLiteralReference')
                            m3iIrvQNameToLiteralText(m3iObj.qualifiedName)=m3iInitValue.LiteralText;
                        end
                    end
                end

                modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
                mappedDataStoreNames=cell(numel(modelMapping.DataStores),1);
                for i=1:numel(modelMapping.DataStores)
                    mappedDataStoreNames{i}=modelMapping.DataStores(i).Name;
                end

                this.m3iUsedDataElement2ServiceDependencyQNameMap=containers.Map();
                m3iServiceNeedsName2ParamsMap=containers.Map();
                serviceDependenciesToRetain=cell(this.m3iSWC.Behavior.ServiceDependency.size,1);
                for idx=1:this.m3iSWC.Behavior.ServiceDependency.size()
                    m3iServiceDependency=this.m3iSWC.Behavior.ServiceDependency.at(idx);
                    m3iUsedDataElement=m3iServiceDependency.UsedDataElement;
                    if~isempty(m3iServiceDependency.UsedDataElement)
                        isMappedToDSM=any(strcmp(mappedDataStoreNames,m3iUsedDataElement.Name));
                        if isMappedToDSM
                            serviceDependenciesToRetain{idx}=m3iServiceDependency.qualifiedName;
                            m3iServiceNeeds=m3iServiceDependency.ServiceNeeds;
                            if~isempty(m3iServiceNeeds)
                                if isa(m3iServiceNeeds,'Simulink.metamodel.arplatform.behavior.NvBlockNeeds')
                                    nvBlockNeedsParams=autosar.mm.util.NvBlockNeedsCodePropsHelper.createStructOfNvBlockNeeds(m3iServiceNeeds);
                                    m3iServiceNeedsName2ParamsMap(m3iServiceNeeds.Name)=nvBlockNeedsParams;
                                end
                            end
                            if~isempty(m3iUsedDataElement)
                                this.m3iUsedDataElement2ServiceDependencyQNameMap(m3iUsedDataElement.qualifiedName)=m3iServiceDependency.qualifiedName;
                            end
                        end
                    end
                end
                serviceDependenciesToRetain=serviceDependenciesToRetain(~cellfun('isempty',serviceDependenciesToRetain));



                merger=M3I.Merger(this.LocalM3IModel,this.m3iSWC.Behavior);
                merger.initialize();


                m3iObj=this.m3iSWC.Behavior;
                this.m3iBehavior=merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                m3iObj.getMetaClass().qualifiedName,...
                merger.getExternalId(m3iObj));


                for idx=1:this.m3iBehavior.variationPointProxy.size()
                    m3iVPPObj=this.m3iBehavior.variationPointProxy.at(idx);
                    m3iCondAccessObj=m3iVPPObj.ConditionAccess;
                    if any(ismember(variantNames,m3iVPPObj.Name))
                        newObj=merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                        m3iVPPObj.getMetaClass().qualifiedName,...
                        merger.getExternalId(m3iVPPObj));

                        conditionAccessObj=merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                        m3iCondAccessObj.getMetaClass().qualifiedName,...
                        merger.getExternalId(m3iCondAccessObj));
                        for sysIndex=1:vpp2SysConstMap(newObj.Name).size()
                            conditionAccessObj.SysConst.append(vpp2SysConstMap(newObj.Name).at(sysIndex));
                        end
                        conditionAccessObj.BindingTime=m3iCondAccessObj.BindingTime;
                        conditionAccessObj.Body=m3iCondAccessObj.Body;
                    end
                end


                for idx=1:this.m3iBehavior.IRV.size()
                    m3iObj=this.m3iBehavior.IRV.at(idx);
                    merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                    m3iObj.getMetaClass().qualifiedName,merger.getExternalId(m3iObj));

                    propName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iObj);
                    if strcmp(propName,'InitValue')
                        m3iInitValue=m3iObj.(propName);
                        if m3iInitValue.isvalid()
                            m3iNewInitVal=merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iInitValue.getMetaClass()),...
                            m3iInitValue.getMetaClass().qualifiedName,merger.getExternalId(m3iInitValue));

                            if m3iIrvQNameToLiteralText.isKey(m3iObj.qualifiedName)
                                m3iNewInitVal.LiteralText=m3iIrvQNameToLiteralText(m3iObj.qualifiedName);
                            end
                        end
                    end
                end


                for idx=1:this.m3iBehavior.Runnables.size()
                    m3iObj=this.m3iBehavior.Runnables.at(idx);
                    merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                    m3iObj.getMetaClass().qualifiedName,...
                    merger.getExternalId(m3iObj));
                    m3iVPObj=m3iObj.variationPoint;
                    if~isempty(m3iVPObj)
                        merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iVPObj.getMetaClass()),...
                        m3iVPObj.getMetaClass().qualifiedName,...
                        merger.getExternalId(m3iVPObj));
                        m3iConditionObj=m3iVPObj.Condition;
                        if~isempty(m3iConditionObj)
                            merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iConditionObj.getMetaClass()),...
                            m3iConditionObj.getMetaClass().qualifiedName,...
                            merger.getExternalId(m3iConditionObj));
                        end
                    end
                end


                for idx=1:this.m3iBehavior.ServiceDependency.size()
                    m3iServiceDependency=this.m3iBehavior.ServiceDependency.at(idx);
                    if any(contains(serviceDependenciesToRetain,m3iServiceDependency.qualifiedName))
                        merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iServiceDependency.getMetaClass()),...
                        m3iServiceDependency.getMetaClass().qualifiedName,merger.getExternalId(m3iServiceDependency));

                        m3iServiceNeeds=this.m3iBehavior.ServiceDependency.at(idx).ServiceNeeds;
                        if~isempty(m3iServiceNeeds)
                            serviceNeedsParams=m3iServiceNeedsName2ParamsMap(m3iServiceNeeds.Name);
                            m3iNewServiceNeeds=merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iServiceNeeds.getMetaClass()),...
                            m3iServiceNeeds.getMetaClass().qualifiedName,merger.getExternalId(m3iServiceNeeds));
                            if~isempty(serviceNeedsParams)&&isa(m3iNewServiceNeeds,'Simulink.metamodel.arplatform.behavior.NvBlockNeeds')
                                validAttributes=autosar.mm.util.NvBlockNeedsCodePropsHelper.getSupportedNvBlockNeedsAttributes;
                                for i=1:length(validAttributes)
                                    m3iNewServiceNeeds.(validAttributes{i})=serviceNeedsParams.(validAttributes{i});
                                end
                            end
                        end
                    end
                end


                for idx=1:this.m3iBehavior.Events.size()
                    m3iObj=this.m3iBehavior.Events.at(idx);
                    newObj=merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                    m3iObj.getMetaClass().qualifiedName,...
                    merger.getExternalId(m3iObj));
                    if evt2RunnableMap.isKey(newObj.Name)

                        m3iRunnable=...
                        autosar.mm.Model.findChildByNameAndTypeName(...
                        this.m3iBehavior,evt2RunnableMap(newObj.Name),...
                        'Simulink.metamodel.arplatform.behavior.Runnable');
                        assert(m3iRunnable.isvalid(),'Did not find runnable');
                        newObj.StartOnEvent=m3iRunnable;
                    end

                    if evt2InternalTriggeringPointMap.isKey(newObj.Name)

                        m3iIntTrigPoint=...
                        autosar.mm.Model.findChildByNameAndTypeName(...
                        this.m3iBehavior,evt2InternalTriggeringPointMap(newObj.Name),...
                        'Simulink.metamodel.arplatform.behavior.InternalTrigger');
                        assert(m3iIntTrigPoint.isvalid(),'Did not find runnable');

                        merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iIntTrigPoint.getMetaClass()),...
                        m3iIntTrigPoint.getMetaClass().qualifiedName,...
                        merger.getExternalId(m3iIntTrigPoint));

                        newObj.InternalTriggeringPoint=m3iIntTrigPoint;
                    end
                end






                for idx=1:this.m3iBehavior.IncludedDataTypeSets.size()
                    m3iObj=this.m3iBehavior.IncludedDataTypeSets.at(idx);
                    merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                    m3iObj.getMetaClass().qualifiedName,...
                    merger.getExternalId(m3iObj));
                end

                retainParameters=containers.Map();
                lookupParameters=containers.Map();
                if~this.isAdaptiveAutosar
                    for ii=1:numel(modelMapping.LookupTables)
                        lookup=modelMapping.LookupTables(ii);
                        arParameter=lookup.MappedTo;
                        if~strcmp(arParameter.ParameterAccessMode,'PortParameter')
                            retainParameters(arParameter.Parameter)=true;
                            lookupParameters(lookup.LookupTableName)=arParameter.Parameter;
                        end
                    end
                end
                params=this.getCodeDescriptorDataInterfaces('Parameters');
                for ii=1:length(params)
                    implementation=params(ii).Implementation;
                    if~isempty(implementation)
                        if isa(implementation,'coder.descriptor.AutosarCalibration')
                            accessType=implementation.DataAccessMode;
                            if strcmp(accessType,'InternalCalPrm')
                                if~lookupParameters.isKey(implementation.Port)
                                    retainParameters(implementation.Port)=true;
                                end
                            end
                        end
                    end
                end


                for idx=1:this.m3iBehavior.Parameters.size()
                    m3iObj=this.m3iBehavior.Parameters.at(idx);
                    if m3iObj.Kind~=Simulink.metamodel.arplatform.behavior.ParameterKind.Const||retainParameters.isKey(m3iObj.Name)
                        merger.createObject(this.LocalM3IModel,this.getPackageUri(m3iObj.getMetaClass()),...
                        m3iObj.getMetaClass().qualifiedName,...
                        merger.getExternalId(m3iObj));
                    end
                end
                merger.teardown();
            else
                this.m3iBehavior=this.M3IElementFactory.createElement(this.m3iSWC,'Behavior',ApplicationComponentBehavior.MetaClass);
            end
            this.m3iSWC.Behavior=this.m3iBehavior;

            [~,behaviorName]=this.getNodePathAndName(this.XmlOpts.BehaviorName);

            noUUID=isempty(autosar.api.Utils.getUUID(this.m3iBehavior));
            if noUUID&&~strcmp(this.m3iBehavior.Name,behaviorName)&&...
                ~this.isAdaptiveAutosar



                autosar.api.Utils.setM3iModelDirty(this.ModelName);
            end


            this.m3iBehavior.Name=behaviorName;
            this.m3iBehavior.isMultiInstantiable=...
            strcmp(get_param(this.ModelName,'CodeInterfacePackaging'),...
            'Reusable function');


            for portIdx=1:this.m3iSWC.Port.size()
                m3iPort=this.m3iSWC.Port.at(portIdx);
                if isa(m3iPort,'Simulink.metamodel.arplatform.port.ModeSenderPort')
                    continue;
                end

                if autosar.api.Utils.isNvPort(m3iPort)
                    infoSeq=m3iPort.Info;
                    comSpecStr='ComSpec';
                elseif autosar.api.Utils.isTriggerPort(m3iPort)

                    continue;
                else
                    infoSeq=m3iPort.info;
                    comSpecStr='comSpec';
                end


                m3iComSpecsToDestroy={};
                for infoIdx=1:infoSeq.size()
                    m3iInfo=infoSeq.at(infoIdx);
                    comSpec=m3iInfo.(comSpecStr);


                    if~isempty(comSpec)
                        if isa(comSpec,'Simulink.metamodel.arplatform.port.DataSenderPortComSpec')||...
                            isa(comSpec,'Simulink.metamodel.arplatform.port.NvDataSenderPortComSpec')

                            if~m3iInfo.DataElements.isvalid()||...
                                ~autosar.mm.sl2mm.ModelBuilder.isDataElementMapped(...
                                modelMapping,m3iPort.Name,m3iInfo.DataElements.Name,true,this.isAdaptiveAutosar)
                                m3iComSpecsToDestroy=[m3iComSpecsToDestroy,{m3iInfo}];%#ok<AGROW>
                            end

                        elseif isa(comSpec,'Simulink.metamodel.arplatform.port.DataReceiverPortComSpec')||...
                            isa(comSpec,'Simulink.metamodel.arplatform.port.NvDataReceiverPortComSpec')

                            if~m3iInfo.DataElements.isvalid()||...
                                ~autosar.mm.sl2mm.ModelBuilder.isDataElementMapped(...
                                modelMapping,m3iPort.Name,m3iInfo.DataElements.Name,false,this.isAdaptiveAutosar)
                                m3iComSpecsToDestroy=[m3iComSpecsToDestroy,{m3iInfo}];%#ok<AGROW>
                            end

                        elseif isa(comSpec,'Simulink.metamodel.arplatform.port.ServerPortComSpec')||...
                            isa(comSpec,'Simulink.metamodel.arplatform.port.ClientPortComSpec')



                            m3iComSpecsToDestroy=[m3iComSpecsToDestroy,{m3iInfo}];%#ok<AGROW>

                        elseif isa(comSpec,'Simulink.metamodel.arplatform.port.ParameterReceiverPortComSpec')||...
                            isa(comSpec,'Simulink.metamodel.arplatform.port.ParameterSenderPortComSpec')





                            m3iComSpecsToDestroy=[m3iComSpecsToDestroy,{m3iInfo}];%#ok<AGROW>
                        elseif isa(comSpec,'Simulink.metamodel.arplatform.port.PersistencyReceiverPortComSpec')||...
                            isa(comSpec,'Simulink.metamodel.arplatform.port.PersistencyProvidedPortComSpec')
                            m3iComSpecsToDestroy={};
                        else
                            assert(false,'Unknown ComSpec type "%s"',class(comSpec));
                        end
                    end
                end


                cellfun(@(x)x.destroy(),m3iComSpecsToDestroy);
            end
        end

        function xformCodeDescriptorRunnables(this)

            runnableCls='Simulink.metamodel.arplatform.behavior.Runnable';
            variants=containers.Map;
            modelMap=autosar.api.Utils.modelMapping(this.ModelName);

            initName=modelMap.InitializeFunctions.MappedTo.Runnable;
            m3iRunnable=this.findOrCreateInSequenceNamedItem(...
            this.m3iBehavior,this.m3iBehavior.Runnables,...
            initName,runnableCls);
            initializeFcn=this.getCodeDescriptorFunctionInterfaces('Initialize');
            assert(length(initializeFcn)==1,...
            'Only 1 initialize function is expected');
            m3iRunnable.symbol=initializeFcn(1).Prototype.Name;


            this.updateSwAddrMethodFromMapping(m3iRunnable,...
            modelMap.InitializeFunctions.MappedTo.SwAddrMethod);


            terminateFunction=this.getCodeDescriptorFunctionInterfaces('Terminate');
            if~isempty(terminateFunction)
                terminateName=modelMap.TerminateFunctions.MappedTo.Runnable;
                m3iRunnable=this.findOrCreateInSequenceNamedItem(...
                this.m3iBehavior,this.m3iBehavior.Runnables,...
                terminateName,runnableCls);
                assert(length(terminateFunction)==1,...
                'Only 1 terminate function is expected');
                m3iRunnable.symbol=terminateFunction(1).Prototype.Name;


                this.updateSwAddrMethodFromMapping(m3iRunnable,...
                modelMap.TerminateFunctions.MappedTo.SwAddrMethod);
            end

            outputFcns=this.getCodeDescriptorFunctionInterfaces('Output');
            for ii=1:length(outputFcns)
                runSymbol=outputFcns(ii).Prototype.Name;
                [runName,slRunnablePath]=autosar.mm.sl2mm.ModelBuilder.getRunnableNameFromSymbol(this.ModelName,this.m3iBehavior,runSymbol);
                m3iRunnable=this.findOrCreateInSequenceNamedItem(...
                this.m3iBehavior,this.m3iBehavior.Runnables,...
                runName,runnableCls);
                m3iRunnable.symbol=runSymbol;


                mapObj=autosar.api.Utils.findMappingObjMappedToRunnable(modelMap,m3iRunnable.Name);
                this.updateSwAddrMethodFromMapping(m3iRunnable,...
                mapObj.MappedTo.SwAddrMethod);

                this.updateCodeDescriptorVariants(variants,m3iRunnable,outputFcns(ii).VariantInfo,runName);
                if~isempty(slRunnablePath)
                    m3iDesc=autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescription(m3iRunnable.rootModel,...
                    m3iRunnable.desc,get_param(slRunnablePath,'Description'));
                    if~isempty(m3iDesc)
                        m3iRunnable.desc=m3iDesc;
                    end
                end



                if~this.m3iBehavior.isMultiInstantiable&&...
                    ~isempty(outputFcns(ii).Prototype.Arguments.toArray)
                    for evtIndex=1:m3iRunnable.Events.size()
                        m3Event=m3iRunnable.Events.at(evtIndex);
                        if isa(m3Event,'Simulink.metamodel.arplatform.behavior.OperationInvokedEvent')
                            assert(~isempty(m3Event.instanceRef),'No trigger associated');
                            m3iOperation=m3Event.instanceRef.Operations;
                            assert(~isempty(m3iOperation),'No operation associated');
                            outputFcns=this.getCodeDescriptorFunctionInterfaces('Output');
                            for argIdx=1:length(outputFcns(ii).Prototype.Arguments.toArray)
                                argument=outputFcns(ii).Prototype.Arguments(argIdx);
                                dataTypeObj=this.getArgDataTypeObj(argument);



                                argumentName=autosar.mm.sl2mm.ModelBuilder.escapeArgumentPrefix(...
                                argument.Name);
                                m3iArgument=this.findOrCreateInSequenceNamedItem(...
                                m3iOperation,m3iOperation.Arguments,argumentName,...
                                'Simulink.metamodel.arplatform.interface.ArgumentData');
                                [slAppTypeAttributes,slDesc]=autosar.mm.sl2mm.ModelBuilder.getArgBlockProperties(...
                                slRunnablePath,argument);
                                codeType=[];
                                m3iArgument.Type=this.TypeBuilder.createOrUpdateM3IType(m3iArgument.Type,...
                                dataTypeObj,codeType,slAppTypeAttributes);

                                autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3IDescription(...
                                m3iArgument,m3iArgument.rootModel,slDesc);
                            end
                            m3iPort=m3Event.instanceRef.Port;
                            assert(~isempty(m3iPort),'No port associated');

                            m3iInfo=Simulink.metamodel.arplatform.port.ServerPortInfo(m3iPort.rootModel);
                            m3iComSpec=Simulink.metamodel.arplatform.port.ServerPortComSpec(m3iPort.rootModel);
                            m3iComSpec.QueueLength=1;


                            m3iInfo.Operations=m3iOperation;
                            m3iInfo.comSpec=m3iComSpec;


                            m3iPort.info.append(m3iInfo);

                            m3iInterface=m3iPort.Interface;

                            returnArg=outputFcns(ii).Prototype.Return;
                            this.addPossibleErrors(returnArg,m3iInterface,m3iOperation);
                        end
                    end
                end
            end
            this.VariantBuilder.setVariationPointViaMap(variants);
        end

        function xformCodeDescriptorServerFunctions(this)


            dataObj=autosar.api.getAUTOSARProperties(this.ModelName);

            outputFcns=this.getCodeDescriptorFunctionInterfaces('Output');

            for ii=1:length(outputFcns)
                outputFcn=outputFcns(ii);
                if~isa(outputFcn,'coder.descriptor.SimulinkFunctionInterface')

                    continue;
                end

                methodName=outputFcn.Prototype.Name;
                serverPort=find_system(this.ModelName,'SearchDepth',1,...
                'BlockType','Outport','IsComposite','on',...
                'IsClientServer','on','Element',outputFcn.Prototype.Name);
                if isempty(serverPort)




                    continue;
                end
                portName=get_param(serverPort{1},'PortName');
                portPath=dataObj.find([],'ServiceProvidedPort','Name',portName);
                interfacePath=dataObj.get(portPath{1},'Interface','PathType','FullyQualified');


                [~,m3iInterface,m3iMethod]=this.addServiceProvidedPortWithMethod(...
                interfacePath,methodName,portName);

                this.findOrCreateArgumentsForAdaptiveMethod(m3iInterface,m3iMethod,outputFcn);
            end
        end

        function xformCodeDescriptorFunctionCalls(this)


            dataObj=autosar.api.getAUTOSARProperties(this.ModelName);

            serverCallPoints=this.CodeDescriptor.getFullComponentInterface.ServerCallPoints.toArray;

            for ii=1:length(serverCallPoints)
                caller=serverCallPoints(ii);

                portName=caller.PortName;
                if isempty(portName)



                    continue;
                end

                methodName=erase(caller.Prototype.Name,[portName,'_']);
                portPath=dataObj.find([],'ServiceRequiredPort','Name',portName);
                interfacePath=dataObj.get(portPath{1},'Interface','PathType','FullyQualified');


                [~,m3iInterface,m3iMethod]=this.addServiceRequiredPortWithMethod(...
                interfacePath,methodName,portName);

                this.findOrCreateArgumentsForAdaptiveMethod(m3iInterface,m3iMethod,caller);
            end
        end

        function findOrCreateArgumentsForAdaptiveMethod(this,m3iInterface,m3iMethod,codeDescrFcn)

            for argIdx=1:length(codeDescrFcn.Prototype.Arguments.toArray)
                argument=codeDescrFcn.Prototype.Arguments(argIdx);
                dataTypeObj=argument.Type;
                if~strcmp(argument.IOType,'INPUT')&&...
                    dataTypeObj.isPointer&&~dataTypeObj.BaseType.isVoid
                    dataTypeObj=dataTypeObj.BaseType;
                end

                argumentName=autosar.mm.sl2mm.ModelBuilder.escapeArgumentPrefix(...
                argument.Name);
                m3iArgument=this.findOrCreateInSequenceNamedItem(m3iMethod,...
                m3iMethod.Arguments,argumentName,...
                'Simulink.metamodel.arplatform.interface.ArgumentData');
                slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;
                codeType=[];
                m3iType=this.TypeBuilder.createOrUpdateM3IType(m3iArgument.Type,dataTypeObj,codeType,slAppTypeAttributes);
                m3iArgument.Type=m3iType;
            end


            if isprop(codeDescrFcn.Prototype,'Return')
                returnArg=codeDescrFcn.Prototype.Return;
                this.addPossibleErrors(returnArg,m3iInterface,m3iMethod);
            end
        end

        function xformCodeDescriptorInports(this)
            mapObj=autosar.api.getSimulinkMapping(this.ModelName);


            dataInportToisUpdatedMap=containers.Map();
            inports=this.getCodeDescriptorDataInterfaces('Inports');
            for ii=1:length(inports)
                implementation=inports(ii).Implementation;
                if isempty(implementation)&&~isempty(inports(ii).VariantInfo)
                    continue;
                end

                if autosar.simulink.functionPorts.Utils.isClientServerPort(inports(ii).SID)
                    continue;
                end

                accessType=implementation.DataAccessMode;
                switch accessType
                case 'IsUpdated'
                    PortName=[implementation.Port,'-',...
                    implementation.DataElement];
                    dataInportToisUpdatedMap(PortName)=ii;
                end
            end
            isModelConfiguredForTransformerError=~this.isAdaptiveAutosar&&...
            strcmp(mapObj.getDataDefaults('InportsOutports','EndToEndProtectionMethod'),'TransformerError');
            portVariants=containers.Map;
            for ii=1:length(inports)
                implementation=inports(ii).Implementation;

                if isempty(implementation)&&~isempty(inports(ii).VariantInfo)
                    continue;
                end

                if autosar.simulink.functionPorts.Utils.isClientServerPort(inports(ii).SID)
                    continue;
                end

                graphicalName=inports(ii).GraphicalName;
                accessType=implementation.DataAccessMode;
                isE2E=false;

                switch accessType
                case 'IsUpdated'
                case 'ErrorStatus'
                    continue
                case{'ImplicitReceive','ExplicitReceive','ExplicitReceiveByVal','QueuedExplicitReceive','EndToEndQueuedReceive'}
                    eName=implementation.DataElement;
                    pName=implementation.Port;
                    ifName=implementation.Interface;
                    dataTypeObj=implementation.Type;


                    [m3iPort,~,m3iData]=...
                    this.addReceiverPort(ifName,eName,pName);
                    this.updateCodeDescriptorVariants(portVariants,m3iPort,...
                    inports(ii).VariantInfo,...
                    graphicalName)

                    isNvPort=autosar.api.Utils.isNvPort(m3iPort);
                    if isNvPort
                        infoMetaClass=Simulink.metamodel.arplatform.port.NvDataReceiverPortInfo.MetaClass;
                        [m3iComSpec,m3iInfo]=autosar.mm.sl2mm.ModelBuilder.findPortComSpecAndInfo(m3iPort,eName,infoMetaClass);
                        if m3iInfo.MetaClass~=infoMetaClass
                            if m3iInfo.isvalid()
                                m3iInfo.destroy();
                            end
                            m3iInfo=Simulink.metamodel.arplatform.port.NvDataReceiverPortInfo(m3iPort.rootModel);
                            m3iPort.Info.append(m3iInfo);
                        end

                        if m3iComSpec.MetaClass~=Simulink.metamodel.arplatform.port.NvDataReceiverPortComSpec.MetaClass
                            if m3iComSpec.isvalid()
                                m3iComSpec.destroy();
                            end
                            m3iComSpec=Simulink.metamodel.arplatform.port.NvDataReceiverPortComSpec(m3iPort.rootModel);
                            m3iInfo.ComSpec=m3iComSpec;
                        end
                    else
                        infoMetaClass=Simulink.metamodel.arplatform.port.DataReceiverPortInfo.MetaClass;
                        [m3iComSpec,m3iInfo]=autosar.mm.sl2mm.ModelBuilder.findPortComSpecAndInfo(m3iPort,eName,infoMetaClass);

                        if m3iInfo.MetaClass~=infoMetaClass
                            if m3iInfo.isvalid()
                                m3iInfo.destroy();
                            end
                            m3iInfo=Simulink.metamodel.arplatform.port.DataReceiverPortInfo(m3iPort.rootModel);
                            m3iPort.info.append(m3iInfo);
                        end

                        if((strcmp(accessType,'QueuedExplicitReceive'))||(strcmp(accessType,'EndToEndQueuedReceive')))
                            if m3iComSpec.MetaClass~=Simulink.metamodel.arplatform.port.DataReceiverQueuedPortComSpec.MetaClass
                                if m3iComSpec.isvalid()
                                    m3iComSpec.destroy();
                                end
                                m3iComSpec=Simulink.metamodel.arplatform.port.DataReceiverQueuedPortComSpec(m3iPort.rootModel);
                                m3iInfo.comSpec=m3iComSpec;
                            end
                        elseif m3iComSpec.MetaClass~=Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec.MetaClass
                            if m3iComSpec.isvalid()
                                m3iComSpec.destroy();
                            end
                            m3iComSpec=Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec(m3iPort.rootModel);
                            m3iInfo.comSpec=m3iComSpec;
                        end
                    end

                    if strcmp(accessType,'ExplicitReceive')
                        [~,~,uiAccessMode]=mapObj.getInport(graphicalName);
                        isE2E=strcmp(uiAccessMode,'EndToEndRead');
                    elseif strcmp(accessType,'EndToEndQueuedReceive')
                        isE2E=true;
                    end

                    slBlock=[this.CodeDescriptor.getFullComponentInterface.GraphicalPath,'/',strrep(graphicalName,'/','//')];


                    slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributesGetter.fromPort(slBlock,this.ModelName);


                    try
                        [m3iType,isTypeEquivalent]=this.TypeBuilder.createOrUpdateM3IType(...
                        m3iData.Type,dataTypeObj,implementation.CodeType,slAppTypeAttributes);
                        m3iData.Type=m3iType;
                        this.destroyIncompatibleSpecification(m3iData);
                    catch mExc
                        if strcmp(mExc.identifier,'autosarstandard:exporter:InvalidParameterForExport')
                            msgId='autosarstandard:exporter:BlockTypeError';
                            newException=MException(msgId,DAStudio.message(msgId,slBlock,mExc.message));
                            throw(addCause(newException,mExc));
                        else
                            rethrow(mExc);
                        end
                    end






                    if strcmp(get_param(slBlock,'IsBusElementPort'),'off')
                        autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3IDescription(...
                        m3iData,m3iData.rootModel,get_param(slBlock,'Description'));
                    end


                    if strcmp(accessType,'EndToEndQueuedReceive')

                        if~isNvPort
                            if isE2E
                                m3iComSpec.UsesEndToEndProtection=true;
                            else
                                m3iComSpec.UsesEndToEndProtection=false;
                            end
                        end
                    elseif~strcmp(accessType,'QueuedExplicitReceive')
                        dummyBlk=[];
                        this.createOrUpdateComSpecInitValue(m3iComSpec,m3iType,isTypeEquivalent,accessType,dummyBlk);

                        if~isNvPort
                            if ismember(accessType,{'ExplicitReceive','ExplicitReceiveByVal'})&&...
                                dataInportToisUpdatedMap.isKey([pName,'-',eName])



                                m3iComSpec.EnableUpdate=true;
                            else
                                m3iComSpec.EnableUpdate=false;
                            end

                            if isE2E
                                m3iComSpec.UsesEndToEndProtection=true;
                            else
                                m3iComSpec.UsesEndToEndProtection=false;
                            end
                        end
                    end


                    m3iInfo.DataElements=m3iData;



                    portUsesE2ETransformer=isE2E&&...
                    slfeature("AutosarTransformer")&&...
                    isModelConfiguredForTransformerError;
                    if portUsesE2ETransformer
                        autosar.mm.sl2mm.PortAPIOptionBuilder.createOrUpdatePortAPIOption(m3iPort);
                    end

                case 'ModeReceive'
                    eName=implementation.DataElement;
                    pName=implementation.Port;
                    dataTypeObj=implementation.Type;


                    [m3iPort,~,m3iModeGroup]=this.findModeGroup(...
                    this.m3iSWC,pName,eName);
                    this.updateCodeDescriptorVariants(portVariants,m3iPort,...
                    inports(ii).VariantInfo,...
                    graphicalName);
                    [m3iMdg,~]=this.TypeBuilder.findOrCreateModeAndImpTypes(dataTypeObj,...
                    implementation.CodeType);
                    m3iModeGroup.ModeGroup=m3iMdg;


                otherwise
                    assert(false,DAStudio.message('RTW:autosar:unrecognisedAccessType',string(accessType)));
                end
            end
            this.VariantBuilder.setVariationPointViaMap(portVariants);
        end

        function xformCodeDescriptorOutports(this)

            mapObj=autosar.api.getSimulinkMapping(this.ModelName);

            portVariants=containers.Map;

            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            outports=this.getCodeDescriptorDataInterfaces('Outports');
            isModelConfiguredForTransformerError=~this.isAdaptiveAutosar&&...
            strcmp(mapObj.getDataDefaults('InportsOutports','EndToEndProtectionMethod'),'TransformerError');
            for ii=1:length(outports)
                implementation=outports(ii).Implementation;

                if isempty(implementation)&&~isempty(outports(ii).VariantInfo)
                    continue;
                end

                if autosar.simulink.functionPorts.Utils.isClientServerPort(outports(ii).SID)
                    continue;
                end

                graphicalName=outports(ii).GraphicalName;
                isE2E=false;
                accessType=implementation.DataAccessMode;
                switch accessType
                case 'ErrorStatus'
                    continue
                case{'ImplicitSend','ImplicitSendByRef','ExplicitSend','QueuedExplicitSend','EndToEndQueuedSend'}
                    eName=implementation.DataElement;
                    pName=implementation.Port;
                    ifName=implementation.Interface;
                    dataTypeObj=implementation.Type;



                    [m3iPort,~,m3iData]=...
                    this.addSenderPort(ifName,eName,pName);
                    this.updateCodeDescriptorVariants(portVariants,m3iPort,...
                    outports(ii).VariantInfo,...
                    graphicalName)

                    isNvPort=autosar.api.Utils.isNvPort(m3iPort);
                    if isNvPort
                        infoMetaClass=Simulink.metamodel.arplatform.port.NvDataSenderPortInfo.MetaClass;
                        [m3iComSpec,m3iInfo]=autosar.mm.sl2mm.ModelBuilder.findPortComSpecAndInfo(m3iPort,eName,infoMetaClass);
                        if m3iInfo.MetaClass~=infoMetaClass
                            if m3iInfo.isvalid()
                                m3iInfo.destroy();
                            end
                            m3iInfo=Simulink.metamodel.arplatform.port.NvDataSenderPortInfo(m3iPort.rootModel);
                            m3iPort.Info.append(m3iInfo);
                        end

                        if m3iComSpec.MetaClass~=Simulink.metamodel.arplatform.port.NvDataSenderPortComSpec.MetaClass
                            if m3iComSpec.isvalid()
                                m3iComSpec.destroy();
                            end
                            m3iComSpec=Simulink.metamodel.arplatform.port.NvDataSenderPortComSpec(m3iPort.rootModel);
                            m3iInfo.ComSpec=m3iComSpec;
                        end
                    else
                        infoMetaClass=Simulink.metamodel.arplatform.port.DataSenderPortInfo.MetaClass;
                        [m3iComSpec,m3iInfo]=autosar.mm.sl2mm.ModelBuilder.findPortComSpecAndInfo(m3iPort,eName,infoMetaClass);

                        if m3iInfo.MetaClass~=infoMetaClass
                            if m3iComSpec.isvalid()
                                m3iComSpec.destroy();
                            end
                            m3iInfo=Simulink.metamodel.arplatform.port.DataSenderPortInfo(m3iPort.rootModel);
                            m3iPort.info.append(m3iInfo);
                        end
                        if((strcmp(accessType,'QueuedExplicitSend'))||(strcmp(accessType,'EndToEndQueuedSend')))
                            if m3iComSpec.MetaClass~=Simulink.metamodel.arplatform.port.DataSenderQueuedPortComSpec.MetaClass
                                if m3iComSpec.isvalid()
                                    m3iComSpec.destroy();
                                end
                                m3iComSpec=Simulink.metamodel.arplatform.port.DataSenderQueuedPortComSpec(m3iPort.rootModel);
                                m3iInfo.comSpec=m3iComSpec;
                            end
                        elseif m3iComSpec.MetaClass~=Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec.MetaClass
                            if m3iComSpec.isvalid()
                                m3iComSpec.destroy();
                            end
                            m3iComSpec=Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec(m3iPort.rootModel);
                            m3iInfo.comSpec=m3iComSpec;
                        end
                    end

                    if strcmp(accessType,'ExplicitSend')
                        [~,~,uiAccessMode]=mapObj.getOutport(graphicalName);
                        isE2E=strcmp(uiAccessMode,'EndToEndWrite');
                    elseif strcmp(accessType,'EndToEndQueuedSend')
                        isE2E=true;
                    end

                    slBlock=[this.CodeDescriptor.getFullComponentInterface.GraphicalPath,'/',strrep(graphicalName,'/','//')];


                    slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributesGetter.fromPort(slBlock,this.ModelName);


                    try
                        [m3iType,isTypeEquivalent]=this.TypeBuilder.createOrUpdateM3IType(...
                        m3iData.Type,dataTypeObj,implementation.CodeType,slAppTypeAttributes);
                    catch mExc
                        if strcmp(mExc.identifier,'autosarstandard:exporter:InvalidParameterForExport')
                            msgId='autosarstandard:exporter:BlockTypeError';
                            newException=MException(msgId,DAStudio.message(msgId,slBlock,mExc.message));
                            throw(addCause(newException,mExc));
                        else
                            rethrow(mExc);
                        end
                    end






                    if strcmp(get_param(slBlock,'IsBusElementPort'),'off')
                        autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3IDescription(...
                        m3iData,m3iData.rootModel,get_param(slBlock,'Description'));
                    end


                    sigBlk=[];
                    if~strcmp(accessType,'QueuedExplicitSend')&&~strcmp(accessType,'EndToEndQueuedSend')

                        if strcmp(accessType,'ExplicitSend')
                            for idx=1:length(modelMapping.Outports)
                                outport=modelMapping.Outports(idx);
                                if strcmp(outport.MappedTo.Port,pName)&&...
                                    strcmp(outport.MappedTo.Element,eName)
                                    if~isempty(outport.getSourceSignalInvalidationBlock)
                                        sigBlk=get_param(outport.getSourceSignalInvalidationBlock,'Handle');

                                        this.createOrUpdateInvalidationPolicy(m3iData,sigBlk);
                                    end
                                    break;
                                end
                            end
                        end

                        this.createOrUpdateComSpecInitValue(m3iComSpec,m3iType,isTypeEquivalent,accessType,sigBlk);

                        if~isNvPort
                            if isE2E
                                m3iComSpec.UsesEndToEndProtection=true;
                            elseif~isNvPort
                                m3iComSpec.UsesEndToEndProtection=false;
                            end
                        end
                    end

                    if strcmp(accessType,'EndToEndQueuedSend')
                        if~isNvPort
                            if isE2E
                                m3iComSpec.UsesEndToEndProtection=true;
                            elseif~isNvPort
                                m3iComSpec.UsesEndToEndProtection=false;
                            end
                        end
                    end



                    portUsesE2ETransformer=isE2E&&...
                    slfeature("AutosarTransformer")&&...
                    isModelConfiguredForTransformerError;
                    if portUsesE2ETransformer
                        autosar.mm.sl2mm.PortAPIOptionBuilder.createOrUpdatePortAPIOption(m3iPort);
                    end


                    m3iInfo.DataElements=m3iData;


                    m3iData.Type=m3iType;
                    this.destroyIncompatibleSpecification(m3iData);

                    if(m3iData.InvalidationPolicy==...
                        Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.Keep||...
                        m3iData.InvalidationPolicy==...
                        Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.Replace)
                        autosar.mm.sl2mm.ModelBuilder.setInvalidValueInType(...
                        m3iData.Type,...
                        this.MaxShortNameLength,this.SymbolicDefinitions);
                    end

                case{'ModeSend'}
                    eName=implementation.DataElement;
                    pName=implementation.Port;
                    dataTypeObj=implementation.Type;


                    [m3iPort,~,m3iModeGroup]=this.findModeGroup(...
                    this.m3iSWC,pName,eName);
                    this.updateCodeDescriptorVariants(portVariants,m3iPort,...
                    outports(ii).VariantInfo,...
                    graphicalName);
                    [m3iMdg,~]=this.TypeBuilder.findOrCreateModeAndImpTypes(dataTypeObj,...
                    implementation.CodeType);
                    m3iModeGroup.ModeGroup=m3iMdg;
                otherwise
                    assert(false,DAStudio.message('RTW:autosar:unrecognisedAccessType',accessType));
                end
            end
            this.VariantBuilder.setVariationPointViaMap(portVariants);
        end

        function xformCodeDescriptorPerCallPoints(this)
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            codeDesc=this.CodeDescriptor;
            dataStores=codeDesc.getDataInterfaces('DataStores');
            for ii=1:numel(modelMapping.DataStores)
                dsMapping=modelMapping.DataStores(ii);

                if strcmp(dsMapping.MappedTo.ArDataRole,'Persistency')
                    portName=dsMapping.MappedTo.getPerInstancePropertyValue('Port');
                    dataElementName=dsMapping.MappedTo.getPerInstancePropertyValue('DataElement');
                    [m3iPort,m3iData]=this.getPersistencyPortInfo(portName,dataElementName);

                    if~isempty(m3iPort)&&~isempty(m3iData)

                        for jj=1:numel(dataStores)
                            dataStoreFromDesc=dataStores(jj);



                            numSID=extractAfter(dataStoreFromDesc.SID,':');
                            if strcmp(numSID,dsMapping.BlockSID)
                                break;
                            end
                        end
                        dataTypeObj=dataStoreFromDesc.Type;
                        slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;
                        if~isempty(dataStoreFromDesc.Implementation)&&...
                            ~isempty(dataStoreFromDesc.Implementation.CodeType)
                            codeType=dataStoreFromDesc.Implementation.CodeType;
                        else
                            codeType=[];
                        end
                        [m3iType,~]=this.TypeBuilder.createOrUpdateM3IType(m3iData.Type,...
                        dataTypeObj,codeType,slAppTypeAttributes);
                        m3iData.Type=m3iType;


                        [m3iComSpecReq,m3iInfoReq,~,m3iInfoProv]=...
                        autosar.mm.sl2mm.ModelBuilder.findOrCreatePersistencyPortComSpec(...
                        m3iPort,dataElementName);
                        m3iInfoReq.DataElements=m3iData;
                        m3iInfoProv.DataElements=m3iData;


                        initValBlk=get_param(dsMapping.OwnerBlockHandle,'InitialValue');
                        try
                            isVar=existsInGlobalScope(this.ModelName,initValBlk);
                            if isVar


                                initValue=evalinGlobalScope(this.ModelName,initValBlk);
                                if~isstruct(initValue)


                                    initValue=initValue.Value;
                                end
                            else
                                initValue=eval(initValBlk);
                            end
                        catch
                            return;
                        end
                        this.doCreateOrUpdateInitValue(m3iComSpecReq,m3iType,initValue);
                    end
                end
            end
            autosar.internal.adaptive.manifest.Persistency.updateManifestMetaModelWithPersistencyData(this.ModelName);
        end
        function[m3iPort,m3iData]=getPersistencyPortInfo(...
            this,port,dataElement)

            arPkg='Simulink.metamodel.arplatform';
            dataCls=[arPkg,'.interface.PersistencyData'];
            prPortCls=[arPkg,'.port.PersistencyProvidedRequiredPort'];
            pPortCls=[arPkg,'.port.PersistencyProvidedPort'];
            rPortCls=[arPkg,'.port.PersistencyRequiredPort'];


            m3iPort=this.findInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.PersistencyProvidedRequiredPorts,port,prPortCls);

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.PersistencyProvidedPorts,port,pPortCls);
            end

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.PersistencyRequiredPorts,port,rPortCls);
            end

            m3iInterface=m3iPort.Interface;
            m3iData=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.DataElements,dataElement,dataCls);
        end

        function xformCodeDescriptorInternalData(this)
            internalData=this.CodeDescriptor.getFullComponentInterface.InternalData;

            variants=containers.Map;
            for ii=1:length(internalData.toArray)
                implementation=internalData(ii).Implementation;

                switch class(implementation)
                case{'coder.descriptor.AutosarInterRunnable'}
                    accessType=implementation.DataAccessMode;
                    dataTypeObj=implementation.Type;
                    switch accessType
                    case{'ExplicitInterRunnable','ImplicitInterRunnable'}
                        m3iIrvData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,...
                        this.m3iBehavior.IRV,implementation.VariableName,...
                        'Simulink.metamodel.arplatform.behavior.IrvData');


                        slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;
                        [m3iType,isTypeEquivalent]=this.TypeBuilder.createOrUpdateM3IType(...
                        m3iIrvData.Type,dataTypeObj,implementation.CodeType,slAppTypeAttributes);
                        m3iIrvData.Type=m3iType;





                        if autosar.validation.ExportFcnValidator.isExportFcn(this.ModelName)

                            irvLine=find_system(this.ModelName,'SearchDepth',1,...
                            'FindAll','on','type','line','Name',m3iIrvData.Name);
                            if~isempty(irvLine)
                                slDesc=get_param(irvLine(1),'Description');
                                autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3IDescription(m3iIrvData,m3iIrvData.rootModel,slDesc);
                            end
                        else

                            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
                            for rtIdx=1:length(modelMapping.RateTransition)
                                rateTransitionMapping=modelMapping.RateTransition(rtIdx);
                                if strcmp(rateTransitionMapping.MappedTo.IrvName,m3iIrvData.Name)
                                    slDesc=get_param(rateTransitionMapping.Block,'Description');
                                    autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3IDescription(m3iIrvData,m3iIrvData.rootModel,slDesc);
                                    break;
                                end
                            end
                        end



                        if strcmpi(accessType,'ExplicitInterRunnable')
                            m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Explicit;
                        elseif strcmpi(accessType,'ImplicitInterRunnable')
                            m3iIrvData.Kind=Simulink.metamodel.arplatform.behavior.IrvKind.Implicit;
                        else
                            assert(false,['Expected either implicit or explicit irv got ',accessType]);
                        end


                        this.createOrUpdateInitValue(m3iIrvData,m3iType,isTypeEquivalent);
                        this.updateCodeDescriptorVariants(variants,m3iIrvData,...
                        internalData(ii).VariantInfo,...
                        internalData(ii).GraphicalName);
                    otherwise
                        assert(false,DAStudio.message('RTW:autosar:unrecognisedAccessType',accessType));
                    end
                case{'coder.descriptor.Variable','coder.descriptor.PointerVariable','coder.descriptor.PointerExpression'}


                    if this.m3iBehavior.isMultiInstantiable


                        if isequal(internalData(ii).Implementation.Type.Identifier,...
                            'Rte_Instance')
                            continue
                        end

                        [~,ARPIMVarName,dataTypeIden,rteDataTypeName]=arxml.getPIMInfoFromInternalData(...
                        internalData(ii),this.MaxShortNameLength);


                        m3iPerInstanceMemory=this.M3IElementFactory.createElement(this.m3iBehavior,...
                        'PIM',Simulink.metamodel.arplatform.behavior.PerInstanceMemory.MetaClass);

                        m3iPerInstanceMemory.Name=ARPIMVarName;
                        m3iPerInstanceMemory.typeStr=rteDataTypeName;
                        m3iPerInstanceMemory.typeDefinitionStr=dataTypeIden;




                        this.updateCodeDescriptorVariants(variants,m3iPerInstanceMemory,...
                        internalData(ii).VariantInfo,...
                        internalData(ii).GraphicalName);
                    end
                otherwise
                    assert(false,DAStudio.message('RTW:autosar:unrecognisedInternalDataType',class(implementation)));
                end

            end








            codeDescInternalData=this.CodeDescriptor.getDataInterfaces('InternalData');
            for i=1:length(codeDescInternalData)
                this.TypeBuilder.trackIfApplicationType(codeDescInternalData(i).Type);
            end
            this.VariantBuilder.setVariationPointViaMap(variants);
        end

        function xformCodeDescriptorDataStores(this)
            topMdl_codeDesc=this.CodeDescriptor;
            perInstanceMemoryBuilder=autosar.mm.sl2mm.PerInstanceMemoryBuilder(this.ModelName,this.m3iBehavior,this.TypeBuilder);
            variants=perInstanceMemoryBuilder.addCodeDescriptorDataStoresInM3iModel(topMdl_codeDesc);
            this.VariantBuilder.setVariationPointViaMap(variants);
            this.addDataStoreExclusiveAreas(topMdl_codeDesc);
        end

        function addDataStoreExclusiveAreas(this,topMdl_codeDesc)


            dataStores=topMdl_codeDesc.getDataInterfaces('DataStores');
            for ii=1:length(dataStores)
                datastore=dataStores(ii);
                if~isa(datastore.Implementation,'coder.descriptor.AutosarMemoryExpression')
                    continue;
                end

                dataStoreRunnables=autosar.mm.sl2mm.utils.TimingInterface.getRunnablesAccessingDataStore(...
                topMdl_codeDesc,datastore);

                if~isempty(dataStoreRunnables)
                    dsmName=datastore.Implementation.BaseRegion.Identifier;
                    exclusiveAreaName=arxml.arxml_private('p_create_aridentifier',['EA_',dsmName],this.MaxShortNameLength);

                    m3iExclusiveArea=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,...
                    this.m3iBehavior.exclusiveArea,exclusiveAreaName,'Simulink.metamodel.arplatform.behavior.ExclusiveArea');
                end

                for runnableIdx=1:numel(dataStoreRunnables)
                    currentRunnable=dataStoreRunnables(runnableIdx);
                    m3iRunnable=this.findM3iRunnable(currentRunnable);
                    m3iRunnable.runInsideExclusiveArea.append(m3iExclusiveArea);
                end
            end
        end

        function m3iRunnable=findM3iRunnable(this,codeDescRunnable)

            assert(isa(codeDescRunnable,'coder.descriptor.FunctionInterface'),...
            'Expect a code descriptor function interface');
            runnableName=autosar.mm.sl2mm.ModelBuilder.getRunnableNameFromSymbol(this.ModelName,...
            this.m3iBehavior,codeDescRunnable.Prototype.Name);
            m3iRunnable=autosar.mm.Model.findChildByNameAndTypeName(this.m3iBehavior,runnableName,...
            'Simulink.metamodel.arplatform.behavior.Runnable');
            assert(m3iRunnable.isvalid(),'Did not find runnable');
        end









        function vars=xformCodeDescriptorParametersForSubModel(this,compModelMapping,codeDesc,path)
            vars=[];
            bhm=codeDesc.getBlockHierarchyMap;
            if isempty(bhm)
                return;
            end

            refMdlBlks=bhm.getBlocksByType('ModelReference');
            for ii=1:length(refMdlBlks)
                cur_path=[path,refMdlBlks(ii).Identifier,'_'];
                refMdlName=refMdlBlks(ii).ReferencedModelName;
                refMdl_codeDesc=this.CodeDescriptorCache.getRefModelCodeDescriptor(refMdlName,codeDesc);
                refVars=this.xformCodeDescriptorParametersForSubModel(compModelMapping,refMdl_codeDesc,cur_path);
                vars=[vars,refVars];%#ok<AGROW>
            end
            this.processParametersForSubModel(compModelMapping,codeDesc,path);
        end











        function processParametersForSubModel(this,compModelMapping,codeDesc,path)
            parameters=codeDesc.getDataInterfaces('Parameters');
            if isempty(parameters)
                return;
            end

            subModelMapping=compModelMapping.SubModelMappings.findobj('Name',codeDesc.ModelName);
            if isempty(subModelMapping)||isempty(subModelMapping.Parameters)
                return;
            end

            paramMappings=jsondecode(subModelMapping.Parameters);
            subModelParamMapping=containers.Map;
            for ii=1:numel(paramMappings)
                parameterMapping=paramMappings(ii);
                if~isempty(parameterMapping.PerInstanceProperties)
                    parameterMapping.PerInstanceProperties=jsondecode(parameterMapping.PerInstanceProperties);
                end
                subModelParamMapping(parameterMapping.Name)=parameterMapping;
            end


            paramMap=containers.Map;

            for ii=1:length(parameters)
                if this.isValidParamForSubModel(parameters(ii))
                    param=parameters(ii);
                    implementation=this.getAutosarSubModelParameterImplementation(param);
                    if~isempty(path)
                        name=[path,extractAfter(param.Implementation.CoderDataGroupName,1)];
                    end
                    if this.shouldSkipSubmodelParameter(paramMap,path,implementation,name)
                        continue;
                    end

                    paramMap(name)=implementation;

                    slAppObjs=[];
                    m3iSwAddrMethod=[];
                    for jj=1:length(implementation.Type.Elements)
                        graphicalName=implementation.Type.Elements(jj).Identifier;

                        mappedParam=subModelParamMapping(graphicalName);
                        swAddrMethod='';
                        swCalibrationAccess='ReadWrite';
                        displayFormat='';
                        for kk=1:numel(mappedParam.PerInstanceProperties)
                            prop=mappedParam.PerInstanceProperties(kk);
                            switch prop.Name
                            case 'SwAddrMethod'
                                swAddrMethod=prop.Value;
                            case 'SwCalibrationAccess'
                                swCalibrationAccess=prop.Value;
                            case 'DisplayFormat'
                                displayFormat=prop.Value;
                            end
                        end
                        m3iSwAddrMethod=this.findOrCreateSwAddressMethodFromJsonStr(subModelMapping.SwAddrMethods,swAddrMethod);
                        swCalibrationAccess=this.getM3ISwCalibrationAccessEnumFromString(swCalibrationAccess);
                        lookupTableData=[];
                        for lutIdx=1:numel(parameters)
                            lutParam=parameters(lutIdx);
                            if isa(lutParam,'coder.descriptor.LookupTableDataInterface')
                                if strcmp(lutParam.GraphicalName,graphicalName)
                                    lookupTableData=lutParam;
                                    break;
                                elseif strcmp(lutParam.BreakpointSpecification,'Reference')
                                    breakpoints=lutParam.Breakpoints;
                                    for bpIdx=1:breakpoints.Size()
                                        bpParam=breakpoints(bpIdx);
                                        if strcmp(bpParam.GraphicalName,graphicalName)
                                            lookupTableData=bpParam;
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                        slAppObjs=[slAppObjs,autosar.mm.util.SlAppTypeAttributes(mappedParam.Min,...
                        mappedParam.Max,mappedParam.Unit,...
                        mappedParam.Description,swCalibrationAccess,displayFormat,m3iSwAddrMethod,lookupTableData,graphicalName)];%#ok<AGROW>
                    end
                    m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.Parameters,...
                    name,'Simulink.metamodel.arplatform.interface.ParameterData');
                    m3iData.Kind=this.getM3IParameterKindEnumFromString(mappedParam.ArDataRole);
                    if~isempty(m3iSwAddrMethod)
                        m3iData.SwAddrMethod=m3iSwAddrMethod;
                    end
                    dataTypeObj=implementation.Type;

                    m3iType=this.TypeBuilder.findOrCreateType(dataTypeObj,implementation.CodeType,slAppObjs);
                    m3iData.Type=m3iType;
                end
            end
        end

        function xformCodeDescriptorParameters(this)


            variants=containers.Map;

            this.cleanupComSpecsOnCalibCompsPPorts(this.SharedM3IModel);

            subModelPerInstanceParamNames=this.getSubModelPerInstanceParamNames();

            codeDescParams=this.getCodeDescriptorDataInterfaces('Parameters');
            for paramIndex=1:length(codeDescParams)
                codeDescParam=codeDescParams(paramIndex);
                if isempty(codeDescParam.Implementation)


                    continue;
                end
                if this.isPromotedPerInstanceParameterFromSubmodel(...
                    codeDescParam,subModelPerInstanceParamNames)


                    continue;
                end
                this.processParam(codeDescParam,paramIndex,variants);



                if autosar.mm.sl2mm.LookupTableBuilder.hasValidLookupTableDataInterface(codeDescParam)...
                    &&strcmp(codeDescParam.BreakpointSpecification,'Reference')
                    for bpIndex=1:codeDescParam.Breakpoints.Size()
                        codeDescBP=codeDescParam.Breakpoints.at(bpIndex);
                        if~this.isPromotedPerInstanceParameterFromSubmodel(...
                            codeDescBP,subModelPerInstanceParamNames)
                            this.processParam(codeDescBP,paramIndex,variants);
                        end
                    end
                else
                    [isFixAxisLUT,isEvenSpacingLUT]=...
                    autosar.mm.sl2mm.LookupTableBuilder.hasFixAxisLookupTableDataInterface(codeDescParam);
                    if isEvenSpacingLUT&&~isFixAxisLUT


                        for bpIndex=1:codeDescParam.Breakpoints.Size()
                            codeDescBP=codeDescParam.Breakpoints.at(bpIndex);
                            if~this.isPromotedPerInstanceParameterFromSubmodel(...
                                codeDescBP,subModelPerInstanceParamNames)&&...
                                codeDescBP.IsTunableBreakPoint
                                this.processParam(codeDescBP,paramIndex,variants);
                            else


                            end
                        end
                    end
                end
            end

            if~isempty(subModelPerInstanceParamNames)
                modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
                this.xformCodeDescriptorParametersForSubModel(modelMapping,this.CodeDescriptor,[]);
            end

            this.VariantBuilder.setVariationPointViaMap(variants);
        end

        function subModelPerInstanceParamNames=getSubModelPerInstanceParamNames(this)


            subModelPerInstanceParamNames={};

            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            if isempty(modelMapping)
                return;
            end
            for subModelIndex=1:numel(modelMapping.SubModelMappings)
                subModelMapping=modelMapping.SubModelMappings(subModelIndex);
                if isempty(subModelMapping)||isempty(subModelMapping.Parameters)
                    continue;
                end
                subModelParamMappings=jsondecode(subModelMapping.Parameters);

                for mappingIndex=1:numel(subModelParamMappings)
                    parameterMapping=subModelParamMappings(mappingIndex);
                    if strcmp(parameterMapping.ArDataRole,'PerInstanceParameter')

                        subModelPerInstanceParamNames{end+1}=parameterMapping.Name;%#ok<AGROW>
                    end
                end
            end
        end


        function processParam(this,param,paramIndex,variants)


            dataObj=autosar.mm.util.getValueFromGlobalScope(this.ModelName,param.GraphicalName);
            if isempty(dataObj)
                return;
            end

            implementation=param.Implementation;
            if isa(implementation,'coder.descriptor.AutosarCalibration')
                accessType=implementation.DataAccessMode;
                switch accessType
                case 'Calibration'
                    this.createPortParameter(param,paramIndex,variants);
                case 'InternalCalPrm'
                    this.createInternalCalPrm(param,paramIndex,variants);
                otherwise
                    assert(false,'Unsupported parameter DataAccessMode %s',accessType);
                end
            elseif isa(implementation,'coder.descriptor.Variable')
                this.createConstantMemory(param,variants);
            end
        end

        function createPortParameter(this,param,paramIndex,variants)


            implementation=param.Implementation;
            calPrmGraphicalName=param.GraphicalName;
            eName=implementation.ElementName;
            pName=implementation.Port;
            interfacePath=implementation.InterfacePath;

            dataTypeObj=implementation.Type;
            calibCompPath=implementation.CalibrationComponent;
            paramPPort=implementation.ProviderPortName;




            m3iRPort=this.findOrCreateInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.ParameterReceiverPorts,pName,...
            'Simulink.metamodel.arplatform.port.ParameterReceiverPort');

            if(isempty(interfacePath)||strcmp(interfacePath,'UNDEFINED'))...
                &&m3iRPort.Interface.isvalid()
                m3iInterface=m3iRPort.Interface;
            else

                [interfacePkg,interfaceName]=this.getNodePathAndName(interfacePath);


                m3iIntfPkg=this.M3IElementFactory.getOrAddARPackage('Interface',interfacePkg);
                m3iInterface=this.findOrCreateInSequenceNamedItem(m3iIntfPkg,m3iIntfPkg.packagedElement,interfaceName,'Simulink.metamodel.arplatform.interface.ParameterInterface');
            end
            m3iData=this.findOrCreateInSequenceNamedItem(m3iInterface,m3iInterface.DataElements,eName,'Simulink.metamodel.arplatform.interface.ParameterData');
            dataObjValue=autosar.mm.sl2mm.ConstantBuilder.getDataObjValue(this.ModelName,calPrmGraphicalName);
            if isa(dataObjValue,'struct')


                m3iType=[];
            else
                codeDescParamInfo=this.CodeDescParamAdapter.getCodeDescParamInfo(param);
                if isa(codeDescParamInfo.CodeDescObj,'coder.descriptor.BreakpointDataInterface')
                    m3iType=this.TypeBuilder.findOrCreateSharedAxisType(codeDescParamInfo.CodeDescObj,codeDescParamInfo.GraphicalName);
                    m3iData.category='COM_AXIS';
                else
                    m3iType=this.TypeBuilder.findOrCreateLookupTableType(codeDescParamInfo);
                end
            end
            this.updateM3iModelFromCalPrm(m3iType,m3iData,dataTypeObj,implementation.CodeType,calPrmGraphicalName);



            m3iRPort.Interface=m3iInterface;
            [isMapped,~,~]=this.isMappedParameter(calPrmGraphicalName);
            if~isMapped
                [m3iData.SwCalibrationAccess,m3iData.DisplayFormat]=this.getCalibrationAttributesForDataObject(this.ModelName,param);
            end

            schemaSupportsParamComSpec=...
            ~any(strcmp(get_param(this.ModelName,'AutosarSchemaVersion'),{'2.1','3.0'}));
            if schemaSupportsParamComSpec
                this.addParameterComSpec(m3iRPort,m3iData,calPrmGraphicalName);
            end




            if~isempty(calibCompPath)



                compObj=autosar.mm.Model.findObjectByName(this.SharedM3IModel,calibCompPath);
                if~compObj.isEmpty
                    assert(compObj.size==1,'%s is a duplicate!',calibCompPath);
                    if~isa(compObj.at(1),'Simulink.metamodel.arplatform.component.ParameterComponent')
                        this.msgStream.createError('RTW:autosar:CalPrmProviderComponentConflict',...
                        {calibCompPath,calPrmGraphicalName,calibCompPath});
                    end
                end

                m3iCalibSWC=this.findOrCreateComponentSWC('Parameter',calibCompPath);
                this.TypeBuilder.addDataTypeMappingSetRef(m3iCalibSWC);




                assert(~isempty(paramPPort),...
                'ProviderPPort should not be empty for %s!',...
                calPrmGraphicalName);


                m3iPPort=this.findOrCreateInSequenceNamedItem(...
                m3iCalibSWC,m3iCalibSWC.ParameterSenderPorts,paramPPort,...
                'Simulink.metamodel.arplatform.port.ParameterSenderPort');
                m3iPPort.Interface=m3iInterface;
                if schemaSupportsParamComSpec
                    this.addParameterComSpec(m3iPPort,m3iData,calPrmGraphicalName);
                end
            end
            this.setDualScaledParameter(m3iData,paramIndex,dataTypeObj);
            this.updateCodeDescriptorVariants(variants,m3iData,...
            param.VariantInfo,...
            param.GraphicalName);

            updateTypeQualifier=false;
            this.updateInstanceSpecificProperties(m3iData,'Parameter',updateTypeQualifier,[]);
        end

        function createInternalCalPrm(this,param,paramIndex,variants)

            implementation=param.Implementation;
            calPrmGraphicalName=param.GraphicalName;
            [isMapped,~,shortName,swCalibrationAccess,displayFormat,swAddrMethod]=this.isMappedParameter(implementation.Port);
            if isMapped
                calPrmName=shortName;
            else
                calPrmName=implementation.Port;
            end

            dataTypeObj=implementation.Type;

            if isempty(dataTypeObj)



                return;
            end
            m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.Parameters,calPrmName,'Simulink.metamodel.arplatform.interface.ParameterData');
            dataObjValue=autosar.mm.sl2mm.ConstantBuilder.getDataObjValue(this.ModelName,calPrmGraphicalName);
            if isa(dataObjValue,'struct')


                m3iType=[];
            else
                codeDescParamInfo=this.CodeDescParamAdapter.getCodeDescParamInfo(param);
                if isa(codeDescParamInfo.CodeDescObj,'coder.descriptor.BreakpointDataInterface')
                    m3iType=this.TypeBuilder.findOrCreateSharedAxisType(codeDescParamInfo.CodeDescObj,codeDescParamInfo.GraphicalName);
                    m3iData.category='COM_AXIS';
                else
                    m3iType=this.TypeBuilder.findOrCreateLookupTableType(codeDescParamInfo,...
                    swCalibrationAccess,displayFormat,swAddrMethod);
                end
            end
            this.updateM3iModelFromCalPrm(m3iType,m3iData,dataTypeObj,implementation.CodeType,calPrmGraphicalName);





            if isempty(implementation.Shared)||strcmp(implementation.Shared,'true')
                m3iData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Shared;
            else
                m3iData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Pim;
            end
            m3iData.Name=calPrmName;
            this.setDualScaledParameter(m3iData,paramIndex,dataTypeObj);

            m3iType=m3iData.Type;
            if this.mustExportLUTRecordValueSpecification(m3iType)
                m3iType=this.TypeBuilder.findImpTypeForAppType(m3iType);
            end
            m3iConstantSpec=autosar.mm.sl2mm.ConstantBuilder.findOrCreateConstantSpecificationFromGlobalScopeObj(...
            this.ModelName,this.SharedM3IModel,this.m3iConstantPkg,m3iType,this.MaxShortNameLength,...
            calPrmName,calPrmGraphicalName,this.SymbolicDefinitions);
            m3iData.DefaultValue=m3iConstantSpec.ConstantValue;

            if~isMapped
                [m3iData.SwCalibrationAccess,m3iData.DisplayFormat]=this.getCalibrationAttributesForDataObject(this.ModelName,param);
            end
            this.updateCodeDescriptorVariants(variants,m3iData,...
            param.VariantInfo,...
            param.GraphicalName);

            updateTypeQualifier=false;
            this.updateInstanceSpecificProperties(m3iData,'Parameter',updateTypeQualifier,[]);
        end

        function createConstantMemory(this,param,variants)

            calPrmName=param.Implementation.Identifier;

            dataTypeObj=param.Implementation.Type;
            calPrmGraphicalName=param.GraphicalName;






            dataObj=autosar.mm.util.getValueFromGlobalScope(this.ModelName,calPrmGraphicalName);
            if isa(dataObj,'Simulink.DataObject')
                if isa(dataObj.Value,'Simulink.data.Expression')&&dataObj.getIsValueExpressionPreserved()
                    return;
                end
            end

            [isMapped,parameterAccessModel,shortName,swCalibrationAccess,displayFormat,swAddrMethod]=this.isMappedParameter(calPrmGraphicalName);
            if isMapped&&strcmp(parameterAccessModel,'ConstantMemory')
                m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.Parameters,shortName,'Simulink.metamodel.arplatform.interface.ParameterData');
                isConstMemory=true;
            else
                [isConstMemory,m3iswCalAccessKind,m3iSwAddrMethod,displayFormat]=this.isConstantMemoryParameter(calPrmGraphicalName);
                if isConstMemory


                    m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.Parameters,calPrmName,'Simulink.metamodel.arplatform.interface.ParameterData');
                    m3iData.SwCalibrationAccess=m3iswCalAccessKind;
                    if~isempty(m3iSwAddrMethod)
                        m3iData.SwAddrMethod=m3iSwAddrMethod;
                    end
                    m3iData.DisplayFormat=displayFormat;
                end
            end
            if isConstMemory
                dataObjValue=autosar.mm.sl2mm.ConstantBuilder.getDataObjValue(this.ModelName,calPrmGraphicalName);
                if isa(dataObjValue,'struct')


                    m3iType=[];
                else
                    codeDescParamInfo=this.CodeDescParamAdapter.getCodeDescParamInfo(param);
                    if isa(codeDescParamInfo.CodeDescObj,'coder.descriptor.BreakpointDataInterface')
                        m3iType=this.TypeBuilder.findOrCreateSharedAxisType(codeDescParamInfo.CodeDescObj,codeDescParamInfo.GraphicalName);
                        m3iData.category='COM_AXIS';
                    else
                        m3iType=this.TypeBuilder.findOrCreateLookupTableType(codeDescParamInfo,...
                        swCalibrationAccess,displayFormat,swAddrMethod);
                    end
                end
                this.updateM3iModelFromCalPrm(m3iType,m3iData,dataTypeObj,param.Implementation.CodeType,calPrmGraphicalName);


                m3iData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Const;
                m3iData.Name=calPrmName;

                m3iType=m3iData.Type;
                if this.mustExportLUTRecordValueSpecification(m3iType)
                    m3iType=this.TypeBuilder.findImpTypeForAppType(m3iType);
                end
                m3iConstantSpec=autosar.mm.sl2mm.ConstantBuilder.findOrCreateConstantSpecificationFromGlobalScopeObj(...
                this.ModelName,this.SharedM3IModel,this.m3iConstantPkg,m3iType,this.MaxShortNameLength,calPrmName,...
                calPrmGraphicalName,this.SymbolicDefinitions);
                m3iData.DefaultValue=m3iConstantSpec.ConstantValue;

                updateTypeQualifier=true;
                this.updateInstanceSpecificProperties(m3iData,'Parameter',updateTypeQualifier,[]);


                codeDescParamInfo=this.CodeDescParamAdapter.getCodeDescParamInfo(param);
                codeDescLUTObj=codeDescParamInfo.CodeDescObj;
                if isa(codeDescLUTObj,'coder.descriptor.LookupTableDataInterface')||...
                    isa(codeDescLUTObj,'coder.descriptor.BreakpointDataInterface')
                    if m3iData.Type.IsApplication
                        m3iImpType=this.TypeBuilder.findImpTypeForAppType(m3iData.Type);
                    else
                        m3iImpType=m3iData.Type;
                    end
                    this.TypeBuilder.addSwRecordLayoutAnnotationsToLookupTableImplType(codeDescLUTObj,m3iImpType);
                end
                this.updateCodeDescriptorVariants(variants,m3iData,param.VariantInfo,param.GraphicalName);
            end
        end

        function xformCodeDescriptorGlobalVariables(this)
            mutuallyExclusiveVariables=this.CodeDescriptor.getFullComponentInterface.Code.MutuallyExclusiveVariables;

            globalVariables=this.CodeDescriptor.getFullComponentInterface.Code.GlobalVariables.toArray;

            for ii=1:length(globalVariables)
                globalVariable=globalVariables(ii);
                signalGraphicalName=globalVariable.Identifier;

                [yesNo,m3iswCalAccessKind,m3iSwAddrMethod,displayFormat,dataObj]=this.isAutosarStaticMemorySignal(signalGraphicalName);
                if yesNo
                    signalName=globalVariable.Identifier;
                    dataTypeObj=globalVariable.Type;

                    existingM3IObj=autosar.mm.Model.findChildByName(this.m3iBehavior,signalName,true);
                    isExclusive=any(strcmp(mutuallyExclusiveVariables,signalName));
                    if~isempty(existingM3IObj)&&isExclusive





                        continue;
                    end
                    if~isempty(existingM3IObj)
                        msg=DAStudio.message('autosarstandard:validation:shortNameCaseClash',...
                        signalName,'Static Memory',...
                        existingM3IObj.Name,sprintf('%s %s',existingM3IObj.MetaClass.name,autosar.api.Utils.getQualifiedName(existingM3IObj)));
                        assert(false,msg);
                    end


                    m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.StaticMemory,signalName,'Simulink.metamodel.arplatform.interface.VariableData');
                    slAppTypeAttributes=this.getSLAppTypeAttributes(dataObj);
                    m3iType=this.TypeBuilder.findOrCreateType(dataTypeObj,globalVariable.CodeType,slAppTypeAttributes);


                    m3iData.Name=signalName;
                    m3iData.Type=m3iType;
                    m3iData.SwCalibrationAccess=m3iswCalAccessKind;
                    m3iData.DisplayFormat=displayFormat;
                    if~isempty(m3iSwAddrMethod)
                        m3iData.SwAddrMethod=m3iSwAddrMethod;
                    end
                    this.setSLObjDescriptionForM3iData(dataObj,m3iData);
                end
            end
        end

        function addAutosarMemoryVariable(this,modelName,memoryMode,region,name,variantInfo,elementType,handle,variants)

            [result,errId,arg1,arg2]=autosar.validation.AutosarUtils.validateSubModelShortNames(modelName,[],[]);
            if~result
                this.msgStream.createError(errId,{arg1,arg2});
            end

            dataTypeObj=region.Type;


            switch memoryMode
            case 'ArTypedPerInstanceMemory'
                m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.ArTypedPIM,name,'Simulink.metamodel.arplatform.interface.VariableData');
            case 'StaticMemory'
                m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.StaticMemory,name,'Simulink.metamodel.arplatform.interface.VariableData');
            otherwise
                assert(false,'Incorrect memoryMode %s',memoryMode);
            end

            m3iData.Name=name;
            dataObj=autosar.mm.sl2mm.utils.AutosarMemoryHelper.getSignalObjectForAutosarMemory(this.ModelName,elementType,handle);
            slAppTypeAttributes=this.getSLAppTypeAttributes(dataObj);


            if~isempty(dataObj)&&~strcmp(dataObj.DataType,'auto')
                slAppTypeAttributes.setName(dataObj.DataType);
            end
            this.setSLObjDescriptionForM3iData(dataObj,m3iData);
            [m3iType,~]=this.TypeBuilder.findOrCreateType(dataTypeObj,region.CodeType,slAppTypeAttributes);

            m3iData.Type=m3iType;
            if~isempty(variantInfo)
                this.updateCodeDescriptorVariants(variants,m3iData,variantInfo,m3iData.Name);
            end



            updateTypeQualifier=strcmp(memoryMode,'StaticMemory');
            this.updateInstanceSpecificProperties(m3iData,elementType,updateTypeQualifier,handle);
            if(strcmp(elementType,'DSM')||strcmp(elementType,'SynthesizedDataStore'))&&(exist('dataObj','var')~=0)
                this.updatePIMFromAUTOSARCalPrm(m3iData,dataObj,handle)
            end
        end

















        function addAutosarMemoryVariableForSubModel(this,subModelInternalDataMap,...
            swAddrMethods,memoryMode,region,memoryVariableName,variantInfo,...
            variants,dataType,blkOrPortH)


            assert(~subModelInternalDataMap.isempty(),'Expected non empty subModelInternalDataMap');
            assert(isa(region.Type,'coder.descriptor.types.Struct'),'Expected struct type for subModel memory variable');

            dataTypeObj=region.Type;
            subCompModelName=region.VarOwner;


            switch memoryMode
            case 'ArTypedPerInstanceMemory'
                m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.ArTypedPIM,memoryVariableName,'Simulink.metamodel.arplatform.interface.VariableData');
            case 'StaticMemory'
                m3iData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.StaticMemory,memoryVariableName,'Simulink.metamodel.arplatform.interface.VariableData');
            otherwise
                assert(false,'Incorrect memoryMode %s',memoryMode);
            end

            m3iData.Name=memoryVariableName;


            swAddrMethod=[];
            slAppObjs=[];
            for ii=1:length(region.Type.Elements)
                if subModelInternalDataMap.isKey(region.Type.Elements(ii).Identifier)
                    subModelInternalData=subModelInternalDataMap(region.Type.Elements(ii).Identifier);
                    swAddrMethod='';
                    swCalibrationAccess='ReadOnly';
                    displayFormat='';
                    for kk=1:numel(subModelInternalData.PerInstanceProperties)
                        prop=subModelInternalData.PerInstanceProperties(kk);
                        switch prop.Name
                        case 'SwAddrMethod'
                            swAddrMethod=prop.Value;
                        case 'SwCalibrationAccess'
                            swCalibrationAccess=prop.Value;
                        case 'DisplayFormat'
                            displayFormat=prop.Value;
                        end
                    end
                    if~isempty(swAddrMethods)&&~isempty(swAddrMethod)
                        swAddrMethod=this.findOrCreateSwAddressMethodFromJsonStr(swAddrMethods,swAddrMethod);
                    end
                    swCalibrationAccess=this.getM3ISwCalibrationAccessEnumFromString(swCalibrationAccess);


                    slAppObjs=[slAppObjs,autosar.mm.util.SlAppTypeAttributes(subModelInternalData.Min,...
                    subModelInternalData.Max,subModelInternalData.Unit,...
                    subModelInternalData.Description,swCalibrationAccess,...
                    displayFormat,swAddrMethod,[],region.Type.Elements(ii).Identifier)];%#ok<AGROW>
                end
            end
            [m3iType,~]=this.TypeBuilder.findOrCreateType(dataTypeObj,region.CodeType,slAppObjs);
            if~isempty(swAddrMethod)
                m3iData.SwAddrMethod=swAddrMethod;
            end

            m3iData.Type=m3iType;
            if~isempty(variantInfo)
                this.updateCodeDescriptorVariants(variants,m3iData,variantInfo,m3iData.Name);
            end



            dataObj=autosar.mm.sl2mm.utils.AutosarMemoryHelper.getSignalObjectForAutosarMemory(subCompModelName,dataType,blkOrPortH);
            updateTypeQualifier=strcmp(memoryMode,'StaticMemory');
            this.updateInstanceSpecificProperties(m3iData,dataType,updateTypeQualifier,blkOrPortH,subCompModelName);
            if(strcmp(dataType,'DSM')||strcmp(dataType,'SynthesizedDataStore'))&&(exist('dataObj','var')~=0)
                this.updatePIMFromAUTOSARCalPrm(m3iData,dataObj,blkOrPortH,subCompModelName)
            end
        end









        function vars=xformInternalDataVariablesRecursive(this,compModelMapping,codeDesc,path)
            vars=[];
            bhm=codeDesc.getBlockHierarchyMap;
            if isempty(bhm)
                return;
            end

            refMdlBlks=bhm.getBlocksByType('ModelReference');
            for ii=1:length(refMdlBlks)
                cur_path=[path,refMdlBlks(ii).Identifier,'_'];
                refMdlName=refMdlBlks(ii).ReferencedModelName;
                refMdl_codeDesc=this.CodeDescriptorCache.getRefModelCodeDescriptor(refMdlName,codeDesc);
                refVars=this.xformInternalDataVariablesRecursive(compModelMapping,refMdl_codeDesc,cur_path);
                vars=[vars,refVars];%#ok<AGROW>
            end

            this.xformInternalDataVariablesForSubModel(compModelMapping,codeDesc,path);
        end

        function vars=xformInternalDataVariablesForModel(this,codeDesc,path)
            vars=[];
            bhm=codeDesc.getBlockHierarchyMap;

            if isempty(bhm)
                return;
            end
            variationPoints=containers.Map;


            blkIOsAndStates=codeDesc.getDataInterfaces('InternalData');

            for ii=1:length(blkIOsAndStates)
                [isArTypedPIM,isStatic]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.isAutosarMemoryVariable(blkIOsAndStates(ii));
                if isArTypedPIM||isStatic
                    [region,name,variantInfo]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.getAutosarVariableInfo(blkIOsAndStates(ii));
                    [dataType,handle]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.getHandleForAutosarMemoryMapping(codeDesc,blkIOsAndStates(ii));
                    if~isempty(path)&&isArTypedPIM
                        name=[path,extractAfter(blkIOsAndStates(ii).Implementation.CoderDataGroupName,1)];
                        handle=-1;
                    end
                    if~any(strcmp(name,vars))
                        this.addAutosarMemoryVariable(codeDesc.ModelName,blkIOsAndStates(ii).Implementation.DataAccessMode,...
                        region,name,variantInfo,dataType,handle,variationPoints);
                        vars=[vars,string(name)];%#ok<AGROW>
                    end
                end
            end
            this.VariantBuilder.setVariationPointViaMap(variationPoints);
        end










        function vars=xformInternalDataVariablesForSubModel(this,compModelMapping,codeDesc,path)
            subModelMapping=compModelMapping.SubModelMappings.findobj('Name',codeDesc.ModelName);
            if isempty(subModelMapping)||isempty(subModelMapping.InternalData)
                return;
            end
            vars=[];
            bhm=codeDesc.getBlockHierarchyMap;

            if isempty(bhm)
                return;
            end
            variationPoints=containers.Map;
            internalDataMappings=jsondecode(subModelMapping.InternalData);
            subModelInternalDataMap=containers.Map;
            for ii=1:numel(internalDataMappings)
                internalDataMapping=internalDataMappings(ii);
                shortName=internalDataMapping.Name;
                if~isempty(internalDataMapping.PerInstanceProperties)
                    internalDataMapping.PerInstanceProperties=jsondecode(internalDataMapping.PerInstanceProperties);
                    for jj=1:numel(internalDataMapping.PerInstanceProperties)
                        perInstanceProperty=internalDataMapping.PerInstanceProperties(jj);
                        if strcmp(perInstanceProperty.Name,'ShortName')&&~isempty(perInstanceProperty.Value)

                            shortName=perInstanceProperty.Value;
                        end
                    end
                end
                subModelInternalDataMap(shortName)=internalDataMapping;
            end
            [result,errId,arg1,arg2]=autosar.validation.AutosarUtils.validateSubModelShortNamesForCodeGen(subModelMapping,subModelInternalDataMap);
            if~result
                this.msgStream.createError(errId,{arg1,arg2});
            end

            blkIOsAndStates=codeDesc.getDataInterfaces('InternalData');

            for ii=1:length(blkIOsAndStates)
                blkIOsAndStateImpl=blkIOsAndStates(ii).Implementation;
                [isArTypedPIM,isStatic]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.isAutosarMemoryVariable(blkIOsAndStates(ii));
                if isArTypedPIM||isStatic
                    [region,memoryVariableName,variantInfo]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.getAutosarVariableInfo(blkIOsAndStates(ii));
                    if~isempty(path)&&isArTypedPIM
                        memoryVariableName=[path,extractAfter(blkIOsAndStateImpl.CoderDataGroupName,1)];
                    end
                    if~any(strcmp(memoryVariableName,vars))
                        if~bdIsLoaded(codeDesc.ModelName)

                            load_system(codeDesc.ModelName);
                        end
                        [dataType,blkOrPortH]=autosar.mm.sl2mm.utils.AutosarMemoryHelper.getHandleForAutosarMemoryMapping(codeDesc,blkIOsAndStates(ii));
                        this.addAutosarMemoryVariableForSubModel(...
                        subModelInternalDataMap,subModelMapping.SwAddrMethods,...
                        blkIOsAndStateImpl.DataAccessMode,region,memoryVariableName,...
                        variantInfo,variationPoints,dataType,blkOrPortH);
                        vars=[vars,string(memoryVariableName)];%#ok<AGROW>
                    end
                end
            end
            this.VariantBuilder.setVariationPointViaMap(variationPoints);
        end

        function xformInternalDataVariables(this)
            codeDes=this.CodeDescriptor;

            path=[];
            topMdl_codeDesc=this.CodeDescriptor;
            this.xformInternalDataVariablesForModel(codeDes,path);
            refMdlBlks=topMdl_codeDesc.getBlockHierarchyMap().getBlocksByType('ModelReference');
            if~isempty(refMdlBlks)
                compModelMapping=Simulink.CodeMapping.get(this.ModelName);
                if~isempty(compModelMapping)&&numel(compModelMapping.SubModelMappings)>0
                    this.xformInternalDataVariablesRecursive(compModelMapping,codeDes,path);
                end
            end
        end

        function setDualScaledParameter(this,m3iData,paramIndex,implType)
            params=this.getCodeDescriptorDataInterfaces('Parameters');
            dualScaledParamGraphicalName=params(paramIndex).GraphicalName;
            [isDualScaledParam,paramObj]=this.isDualScaledParameter(...
            this.ModelName,dualScaledParamGraphicalName);
            if isDualScaledParam
                if isa(m3iData.Type,'Simulink.metamodel.types.FloatingPoint')
                    if m3iData.Type.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Single
                        dataTypeObj=coder.types.Single;
                    else
                        dataTypeObj=coder.types.Double;
                    end
                else

                    dataTypeObj=coder.types.Fixed;
                    dataTypeObj.Signedness=m3iData.Type.IsSigned;
                    dataTypeObj.DataTypeMode='Fixed-point: slope and bias scaling';
                    dataTypeObj.WordLength=m3iData.Type.Length.value;
                    dataTypeObj.Slope=0.001;
                    dataTypeObj.Bias=0;
                end

                dataTypeObj.Identifier=this.createAppDataTypeNameDualScaled(m3iData.Name,this.MaxShortNameLength);
                dataTypeObj.Name=dataTypeObj.Identifier;
                slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributesGetter.fromDualScaledParameter(paramObj);
                m3iType=this.TypeBuilder.findOrCreateAppType(dataTypeObj,slAppTypeAttributes);

                m3iData.Type=m3iType;

                this.setSLObjDescriptionForM3iData(paramObj,m3iData);

                if isa(paramObj,'AUTOSAR.DualScaledParameter')&&~isempty(paramObj.CompuMethodName)
                    compuMethodName=paramObj.CompuMethodName;
                else
                    compuMethodName=arxml.arxml_private('p_create_aridentifier',...
                    ['COMPU_',dataTypeObj.Name],this.MaxShortNameLength);
                end
                m3iType.CompuMethod=this.TypeBuilder.createRatFuncCompuMethod(compuMethodName,paramObj,implType);
                clear dataTypeObj;
            end
        end

        function[yesNo,m3iSwCalAccessKind,m3iSwAddrMethod,displayFormat]=isConstantMemoryParameter(self,paramGraphicalName)




            m3iSwCalAccessKind=Simulink.metamodel.foundation.SwCalibrationAccessKind.ReadWrite;
            m3iSwAddrMethod=[];
            displayFormat='';
            [yesNo,dataObj]=autosar.mm.util.getIsAutosarConstantMemory(...
            self.ModelName,paramGraphicalName);
            if yesNo
                swDataDefProps=autosar.mm.sl2mm.ModelBuilder.getAutosarSwDataDefProps(dataObj);

                if~isempty(swDataDefProps.SwCalAccessKind)
                    m3iSwCalAccessKind=autosar.mm.sl2mm.ModelBuilder.getM3ISwCalibrationAccessEnumFromString(swDataDefProps.SwCalAccessKind);
                end
                if~isempty(swDataDefProps.SwAddrMethodName)
                    m3iSwAddrMethod=self.findOrCreateSwAddressMethod(swDataDefProps.SwAddrMethodName,false);
                end
                displayFormat=swDataDefProps.DisplayFormat;
            end
        end

        function[yesNo,m3iSwCalAccessKind,m3iSwAddrMethod,displayFormat,dataObj]=isAutosarStaticMemorySignal(self,signalGraphicalName)

            m3iSwCalAccessKind=Simulink.metamodel.foundation.SwCalibrationAccessKind.ReadOnly;
            m3iSwAddrMethod=[];
            [yesNo,dataObj]=autosar.mm.util.getIsAutosarStaticMemory(self.ModelName,...
            signalGraphicalName);
            displayFormat='';
            if yesNo
                swDataDefProps=autosar.mm.sl2mm.ModelBuilder.getAutosarSwDataDefProps(dataObj);

                if~isempty(swDataDefProps.SwCalAccessKind)
                    m3iSwCalAccessKind=autosar.mm.sl2mm.ModelBuilder.getM3ISwCalibrationAccessEnumFromString(swDataDefProps.SwCalAccessKind);
                end
                if~isempty(swDataDefProps.SwAddrMethodName)
                    m3iSwAddrMethod=self.findOrCreateSwAddressMethod(swDataDefProps.SwAddrMethodName,false);
                end
                displayFormat=swDataDefProps.DisplayFormat;
            end
        end

        function xformCodeDescriptorServerCallPoints(this)

            fcnNameToBlkMap=containers.Map;


            serverFcnBlocks=find_system(this.ModelName,...
            'FollowLinks','on','MatchFilter',@Simulink.match.activeVariants,...
            'blocktype','SubSystem','IsSimulinkFunction','on');
            for blkIndex=1:length(serverFcnBlocks)


                trigPort=find_system(serverFcnBlocks{blkIndex},...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','BlockType','TriggerPort');

                if strcmp(get_param(trigPort,'FunctionVisibility'),'global')
                    fcnName=autosar.ui.utils.getSlFunctionName(serverFcnBlocks{blkIndex});
                    fcnNameToBlkMap(fcnName)=serverFcnBlocks{blkIndex};
                end
            end
            serverCallPoints=this.CodeDescriptor.getFullComponentInterface.ServerCallPoints.toArray;

            for ii=1:length(serverCallPoints)
                serverCallPoint=serverCallPoints(ii);
                [InterfacePath,PortName,OperationName]=...
                autosar.mm.sl2mm.ModelBuilder.findClientBlockPortOpNames(serverCallPoint);

                if~isempty(InterfacePath)
                    isClientBlk=true;
                else
                    isClientBlk=false;
                end

                if autosar.blocks.InternalTriggerBlock.isServerCallPointMappedToInternalTriggerPoint(serverCallPoint)

                    continue
                end


                [~,m3iInterface,m3iOperation]=this.addClientPort(...
                InterfacePath,OperationName,PortName);

                if isClientBlk

                    argMerger=autosar.mm.util.SequenceMerger(m3iOperation.rootModel,m3iOperation.Arguments,...
                    'Simulink.metamodel.arplatform.interface.ArgumentData');
                end

                startIdx=1;
                if this.m3iBehavior.isMultiInstantiable

                    startIdx=2;
                end
                for argIdx=startIdx:length(serverCallPoint.Prototype.Arguments.toArray)
                    argument=serverCallPoint.Prototype.Arguments(argIdx);
                    dataTypeObj=argument.Type;
                    if~strcmp(argument.IOType,'INPUT')&&...
                        dataTypeObj.isPointer&&~dataTypeObj.BaseType.isVoid
                        dataTypeObj=dataTypeObj.BaseType;
                    end
                    if isClientBlk
                        m3iArgument=argMerger.mergeByName(argument.Name);
                    else
                        m3iArgument=this.findOrCreateInSequenceNamedItem(m3iOperation,m3iOperation.Arguments,argument.Name,'Simulink.metamodel.arplatform.interface.ArgumentData');
                    end
                    if fcnNameToBlkMap.isKey(serverCallPoint.Prototype.Name)
                        callerBlock=fcnNameToBlkMap(serverCallPoint.Prototype.Name);
                        [slAppTypeAttributes,slDesc]=autosar.mm.sl2mm.ModelBuilder.getArgBlockProperties(callerBlock,argument);


                        autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3IDescription(...
                        m3iArgument,m3iArgument.rootModel,slDesc);
                    else
                        slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;
                    end
                    codeType=[];
                    m3iType=this.TypeBuilder.createOrUpdateM3IType(m3iArgument.Type,dataTypeObj,codeType,slAppTypeAttributes);
                    m3iArgument.Type=m3iType;





                    m3iArgument.Name=argument.Name;
                    switch argument.IOType
                    case 'INPUT'
                        m3iArgument.Direction=Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In;
                    case 'OUTPUT'
                        m3iArgument.Direction=Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out;
                    case 'INPUT_OUTPUT'
                        m3iArgument.Direction=Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut;
                    otherwise
                        assert(false,'Unknown argument direction ',argument.IOType);
                    end
                end
                if isClientBlk
                    delete(argMerger);
                end


                if~isempty(serverCallPoint.SID)
                    clientServerTypeStr=get_param(serverCallPoint.SID,'serverType');
                    m3iInterface.IsService=autosar.mm.sl2mm.ModelBuilder.convertBasicOrAppSoftwareStrToIsService(clientServerTypeStr);
                end

                if isprop(serverCallPoint.Prototype,'Return')
                    returnArg=serverCallPoint.Prototype.Return;
                    this.addPossibleErrors(returnArg,m3iInterface,m3iOperation);
                end
            end
        end

        function addLUTSwDataDefProps(this,calPrmName,m3iLUTType,m3iLUTInstanceRef)
            if isa(m3iLUTType,'Simulink.metamodel.types.LookupTableType')||...
                isa(m3iLUTType,'Simulink.metamodel.types.SharedAxisType')
                params=this.getCodeDescriptorDataInterfaces('Parameters');
                if this.Prm2LutStructMap.isKey(calPrmName)
                    valueIndex=this.Prm2LutStructMap(calPrmName);
                    codeDescLUTObj=params(valueIndex);
                    if strcmp(codeDescLUTObj.BreakpointSpecification,'Reference')&&isa(m3iLUTType,'Simulink.metamodel.types.LookupTableType')
                        axisCount=codeDescLUTObj.Breakpoints.Size();
                        for axisIndex=1:axisCount
                            bpIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,axisIndex);
                            axisParam=codeDescLUTObj.Breakpoints(bpIndex);
                            operatingPointImplementation=axisParam.Implementation;
                            if~isempty(operatingPointImplementation)&&isa(operatingPointImplementation,'coder.descriptor.AutosarCalibration')
                                accessType=operatingPointImplementation.DataAccessMode;
                                switch accessType
                                case{'Calibration'}
                                    elementName=operatingPointImplementation.ElementName;
                                    portName=operatingPointImplementation.Port;
                                    interfacePath=operatingPointImplementation.InterfacePath;


                                    m3iPort=this.findInSequenceNamedItem(...
                                    this.m3iSWC,this.m3iSWC.ParameterReceiverPorts,portName,...
                                    'Simulink.metamodel.arplatform.port.ParameterReceiverPort');
                                    if(isempty(interfacePath)||strcmp(interfacePath,'UNDEFINED'))...
                                        &&m3iPort.Interface.isvalid()
                                        m3iInterface=m3iPort.Interface;
                                    else

                                        [interfacePkg,interfaceName]=this.getNodePathAndName(interfacePath);
                                        m3iIntfPkg=this.M3IElementFactory.getOrAddARPackage('Interface',interfacePkg);
                                        m3iInterface=autosar.mm.Model.findChildByNameAndTypeName(m3iIntfPkg,interfaceName,'Simulink.metamodel.arplatform.interface.ParameterInterface');
                                    end
                                    m3iOperatingPointData=this.findInSequenceNamedItem(m3iInterface,m3iInterface.DataElements,elementName,'Simulink.metamodel.arplatform.interface.ParameterData');
                                    m3iOperatingPointInstanceRef=autosar.mm.Model.getOrCreateInstanceRef(...
                                    this.m3iSWC,'Simulink.metamodel.arplatform.instance.ParameterDataPortInstanceRef',...
                                    m3iPort,'Port',m3iOperatingPointData,'DataElements');
                                    m3iLUTInstanceRef.SwDataDefPropsInstanceRef.append(m3iOperatingPointInstanceRef);
                                case 'InternalCalPrm'
                                    [isMapped,~,shortName]=this.isMappedParameter(axisParam.GraphicalName);
                                    if isMapped
                                        prmName=shortName;
                                    else
                                        prmName=axisParam.GraphicalName;
                                    end
                                    m3iOperatingPointData=this.findInSequenceNamedItem(...
                                    this.m3iBehavior,this.m3iBehavior.Parameters,prmName,...
                                    'Simulink.metamodel.arplatform.interface.ParameterData');
                                    m3iOperatingPointInstanceRef=autosar.mm.Model.getOrCreateInstanceRef(...
                                    this.m3iSWC,'Simulink.metamodel.arplatform.instance.ParameterDataCompInstanceRef',...
                                    m3iOperatingPointData,'DataElements');
                                    m3iLUTInstanceRef.SwDataDefPropsInstanceRef.append(m3iOperatingPointInstanceRef);
                                end
                            end
                        end
                    end
                end
                if this.Prm2OperatingPointsMap.isKey(calPrmName)
                    operatingPoints=this.Prm2OperatingPointsMap(calPrmName);
                    for opIndex=1:numel(operatingPoints)
                        indexPair=operatingPoints{opIndex};
                        axisIndex=indexPair(2);
                        codeDescLUTObj=params(indexPair(1));
                        axisCount=codeDescLUTObj.Breakpoints.Size();
                        if~isa(m3iLUTType,'Simulink.metamodel.types.SharedAxisType')
                            bpIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,axisIndex);
                        else
                            bpIndex=axisIndex;
                        end
                        axisData=codeDescLUTObj.Breakpoints(bpIndex);
                        if isempty(axisData.OperatingPoint)
                            continue;
                        end
                        operatingPointImplementation=axisData.OperatingPoint.Implementation;
                        m3iOperatingPointInstanceRef=[];

                        if isa(operatingPointImplementation,'coder.descriptor.AutosarSenderReceiver')
                            elementName=operatingPointImplementation.DataElement;
                            portName=operatingPointImplementation.Port;
                            interfaceName=operatingPointImplementation.Interface;


                            [m3iPort,~,m3iOperatingPointData]=...
                            this.addReceiverPort(interfaceName,elementName,portName);



                            m3iOperatingPointInstanceRef=autosar.mm.Model.getOrCreateInstanceRef(...
                            this.m3iSWC,'Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef',...
                            m3iPort,'Port',m3iOperatingPointData,'DataElements');

                        elseif isa(operatingPointImplementation,'coder.descriptor.Variable')
                            signalName=operatingPointImplementation.Identifier;
                            [isStaticMemorySignal,~]=autosar.mm.util.getIsAutosarStaticMemory(this.ModelName,signalName);
                            if~isStaticMemorySignal
                                continue;
                            end

                            m3iOperatingPointData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,...
                            this.m3iBehavior.StaticMemory,signalName,'Simulink.metamodel.arplatform.interface.VariableData');
                            m3iOperatingPointInstanceRef=autosar.mm.Model.getOrCreateInstanceRef(...
                            this.m3iSWC,'Simulink.metamodel.arplatform.instance.VariableDataCompInstanceRef',...
                            m3iOperatingPointData,'DataElements');



                        elseif isa(operatingPointImplementation,'coder.descriptor.AutosarMemoryExpression')
                            variableName=operatingPointImplementation.VariableName;
                            if strcmp(operatingPointImplementation.DataAccessMode,'StaticMemory')
                                m3iOperatingPointData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,...
                                this.m3iBehavior.StaticMemory,variableName,'Simulink.metamodel.arplatform.interface.VariableData');
                            elseif strcmp(operatingPointImplementation.DataAccessMode,'ArTypedPerInstanceMemory')
                                m3iOperatingPointData=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,...
                                this.m3iBehavior.ArTypedPIM,variableName,'Simulink.metamodel.arplatform.interface.VariableData');
                            end
                            m3iOperatingPointInstanceRef=autosar.mm.Model.getOrCreateInstanceRef(...
                            this.m3iSWC,'Simulink.metamodel.arplatform.instance.VariableDataCompInstanceRef',...
                            m3iOperatingPointData,'DataElements');
                        end
                        if~isempty(m3iOperatingPointInstanceRef)
                            m3iLUTInstanceRef.SwDataDefPropsInstanceRef.append(m3iOperatingPointInstanceRef);
                        end
                    end
                end
            end
        end

        function xformCodeDescriptorDirectReads(this)
            inports=this.getCodeDescriptorDataInterfaces('Inports');
            queuedPorts=this.getQueuedDataInterfaces(inports);
            irvToRunnableInfo=this.CodeDescriptor.getFullComponentInterface.IRVReadToRunnableInfo;

            variationPoints=containers.Map;
            runnables=[this.getCodeDescriptorFunctionInterfaces('Initialize'),...
            this.getCodeDescriptorFunctionInterfaces('Output'),...
            this.getCodeDescriptorFunctionInterfaces('Terminate')];
            for jj=1:length(runnables)
                currentRunnable=runnables(jj);
                if isempty(queuedPorts)
                    DirectReads=currentRunnable.DirectReads;
                else
                    DirectReads=[currentRunnable.DirectReads];
                    for i=1:length(queuedPorts)
                        port=queuedPorts(i);
                        if port.Timing.isEquivalentTo(currentRunnable.Timing)
                            DirectReads.add(port);
                        end

                    end
                end



                DirectReads=autosar.mm.sl2mm.ModelBuilder.sortByGraphicalName(DirectReads);

                m3iRunnable=this.findM3iRunnable(currentRunnable);

                for ii=1:length(DirectReads)
                    implementation=DirectReads(ii).Implementation;

                    if isempty(implementation)&&~isempty(DirectWrites(ii).VariantInfo)
                        continue;
                    end

                    switch class(implementation)
                    case{'coder.descriptor.Variable'}

                    case{'coder.descriptor.AutosarMemoryExpression'}

                    otherwise
                        if ismember(implementation.DataAccessMode,...
                            {'ErrorStatus','IsUpdated'})


                            graphicalPortIndex=...
                            str2double(implementation.ReceiverPortNumber);
                            if isempty(this.ExpInports)
                                receiverNum=graphicalPortIndex;
                            else
                                receiverNum=...
                                this.ExpInports(graphicalPortIndex).Index;
                            end
                            inports=this.getCodeDescriptorDataInterfaces('Inports');
                            receiverInp=inports(receiverNum);
                            foundRead=[];
                            for idx=1:numel(DirectReads)
                                if(strcmp(DirectReads(idx).SID,receiverInp.SID)&&...
                                    strcmp(DirectReads(idx).GraphicalName,receiverInp.GraphicalName))
                                    foundRead=idx;
                                    break;
                                end
                            end
                            if isempty(foundRead)
                                implementation=receiverInp.Implementation;
                            end
                        end
                        accessType=implementation.DataAccessMode;
                        switch accessType
                        case{'IsUpdated'}
                        case{'ErrorStatus'}
                            continue
                        case{'Calibration'}
                            eName=implementation.ElementName;
                            pName=implementation.Port;
                            interfacePath=implementation.InterfacePath;


                            m3iPort=this.findInSequenceNamedItem(...
                            this.m3iSWC,this.m3iSWC.ParameterReceiverPorts,pName,...
                            'Simulink.metamodel.arplatform.port.ParameterReceiverPort');
                            if isempty(m3iPort)
                                continue;
                            end
                            if(isempty(interfacePath)||strcmp(interfacePath,'UNDEFINED'))...
                                &&m3iPort.Interface.isvalid()
                                m3iInterface=m3iPort.Interface;
                            else

                                [interfacePkg,interfaceName]=this.getNodePathAndName(interfacePath);
                                m3iIntfPkg=this.M3IElementFactory.getOrAddARPackage('Interface',interfacePkg);
                                m3iInterface=autosar.mm.Model.findChildByNameAndTypeName(m3iIntfPkg,interfaceName,'Simulink.metamodel.arplatform.interface.ParameterInterface');
                            end
                            m3iData=this.findInSequenceNamedItem(m3iInterface,m3iInterface.DataElements,eName,'Simulink.metamodel.arplatform.interface.ParameterData');
                            if isempty(m3iData)
                                continue;
                            end

                            accessName=arxml.arxml_private...
                            ('p_create_aridentifier',...
                            ['CALPRM_',implementation.Port,'_',...
                            implementation.ElementName],this.MaxShortNameLength);

                            m3iAccess=this.findOrCreateInSequenceNamedItem(m3iRunnable,m3iRunnable.portParamRead,accessName,'Simulink.metamodel.arplatform.behavior.PortParameterAccess');

                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.ParameterDataPortInstanceRef.MetaClass);



                            m3iInstanceRef.Port=m3iPort;
                            m3iInstanceRef.DataElements=m3iData;

                            this.addLUTSwDataDefProps(DirectReads(ii).GraphicalName,m3iData.Type,m3iInstanceRef);

                            m3iAccess.instanceRef=m3iInstanceRef;
                            this.updateCodeDescriptorVariants(variationPoints,m3iAccess,...
                            DirectReads(ii).VariantInfo,...
                            DirectReads(ii).GraphicalName);

                            m3iRunnable.portParamRead.append(m3iAccess);
                        case 'InternalCalPrm'
                            [isMapped,~,shortName]=this.isMappedParameter(implementation.Port);
                            if isMapped
                                calPrmName=shortName;
                            else
                                calPrmName=implementation.Port;
                            end
                            m3iData=autosar.mm.Model.findChildByNameAndTypeName(this.m3iBehavior,calPrmName,'Simulink.metamodel.arplatform.interface.ParameterData');
                            if isempty(m3iData)
                                continue;
                            end

                            m3iAccess=this.M3IElementFactory.createElement(m3iRunnable,...
                            'compParamRead',Simulink.metamodel.arplatform.behavior.ComponentParameterAccess.MetaClass);
                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.ParameterDataCompInstanceRef.MetaClass);


                            this.addLUTSwDataDefProps(DirectReads(ii).GraphicalName,m3iData.Type,m3iInstanceRef);



                            m3iInstanceRef.DataElements=m3iData;


                            if strcmp(implementation.Shared,'true')
                                m3iAccess.Name=arxml.arxml_private...
                                ('p_create_aridentifier',...
                                ['SCALPRM_',calPrmName],this.MaxShortNameLength);
                            elseif strcmp(implementation.Shared,'false')
                                m3iAccess.Name=arxml.arxml_private...
                                ('p_create_aridentifier',...
                                ['PICALPRM_',calPrmName],this.MaxShortNameLength);
                            else
                                assert(false,'Should not be here');
                            end
                            m3iAccess.instanceRef=m3iInstanceRef;

                            this.updateCodeDescriptorVariants(variationPoints,m3iAccess,...
                            DirectReads(ii).VariantInfo,...
                            DirectReads(ii).GraphicalName);

                        case{'ImplicitInterRunnable','ExplicitInterRunnable'}

                            m3iAccess=this.M3IElementFactory.createElement(m3iRunnable,...
                            'irvRead',Simulink.metamodel.arplatform.behavior.IrvAccess.MetaClass);
                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.FlowDataCompInstanceRef.MetaClass);



                            m3iData=autosar.mm.Model.findChildByNameAndTypeName(this.m3iBehavior,implementation.VariableName,'Simulink.metamodel.arplatform.behavior.IrvData');



                            m3iInstanceRef.DataElements=m3iData;


                            m3iAccess.Name=arxml.arxml_private...
                            ('p_create_aridentifier',...
                            ['RV_',implementation.VariableName],...
                            this.MaxShortNameLength);

                            m3iAccess.instanceRef=m3iInstanceRef;






                            varInfo=DirectReads(ii).VariantInfo;
                            aIRVReadRunnableInfo=irvToRunnableInfo{implementation.VariableName};
                            if~isempty(aIRVReadRunnableInfo)
                                aRunnableVarInfo=aIRVReadRunnableInfo.RunnableToVariantInfo{m3iRunnable.Name};
                                if~isempty(aRunnableVarInfo)
                                    varInfo=aRunnableVarInfo.VariantInfoForIRV;
                                end
                            end
                            this.updateCodeDescriptorVariants(variationPoints,m3iAccess,...
                            varInfo,...
                            DirectReads(ii).GraphicalName);
                        case{'ImplicitReceive','ExplicitReceive','ExplicitReceiveByVal','QueuedExplicitReceive','EndToEndQueuedReceive'}
                            eName=implementation.DataElement;
                            pName=implementation.Port;
                            ifName=implementation.Interface;


                            m3iAccess=this.M3IElementFactory.createElement(m3iRunnable,...
                            'dataAccess',Simulink.metamodel.arplatform.behavior.FlowDataAccess.MetaClass);
                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef.MetaClass);


                            [m3iPort,~,m3iData]=...
                            this.addReceiverPort(ifName,eName,pName);



                            m3iInstanceRef.Port=m3iPort;
                            m3iInstanceRef.DataElements=m3iData;


                            m3iAccess.Name=arxml.arxml_private('p_create_aridentifier',['IN_',pName,'_',eName],...
                            this.MaxShortNameLength);
                            switch accessType
                            case{'ImplicitReceive'}
                                m3iAccess.Kind=Simulink.metamodel.arplatform.behavior.DataAccessKind.ImplicitRead;
                            case{'ExplicitReceive','QueuedExplicitReceive','EndToEndQueuedReceive'}
                                m3iAccess.Kind=Simulink.metamodel.arplatform.behavior.DataAccessKind.ExplicitReadByArg;
                            case{'ExplicitReceiveByVal'}
                                m3iAccess.Kind=Simulink.metamodel.arplatform.behavior.DataAccessKind.ExplicitReadByValue;

                            otherwise
                                assert(false,'unknown accessType');
                            end

                            m3iAccess.instanceRef=m3iInstanceRef;

                            this.updateCodeDescriptorVariants(variationPoints,m3iAccess,...
                            DirectReads(ii).VariantInfo,...
                            DirectReads(ii).GraphicalName);
                        case{'ModeReceive'}
                            eName=implementation.DataElement;
                            pName=implementation.Port;


                            m3iAccess=this.M3IElementFactory.createElement(m3iRunnable,...
                            'ModeAccessPoint',Simulink.metamodel.arplatform.behavior.ModeAccess.MetaClass);
                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef.MetaClass);


                            [m3iPort,~,m3iModeGroup]=this.findModeGroup(...
                            this.m3iSWC,pName,eName);



                            m3iInstanceRef.Port=m3iPort;
                            m3iInstanceRef.groupElement=m3iModeGroup;


                            m3iAccess.InstanceRef=m3iInstanceRef;
                        otherwise
                            assert(false,DAStudio.message('RTW:autosar:unrecognisedAccessType',accessType));
                        end
                    end
                end
            end
            this.VariantBuilder.setVariationPointViaMap(variationPoints);
        end

        function xformCodeDescriptorDirectWrites(this)
            outports=this.getCodeDescriptorDataInterfaces('Outports');

            queuedPorts=this.getQueuedDataInterfaces(outports);
            irvToRunnableInfo=this.CodeDescriptor.getFullComponentInterface.IRVWriteToRunnableInfo;

            variationPoints=containers.Map();
            runnables=[this.getCodeDescriptorFunctionInterfaces('Initialize'),...
            this.getCodeDescriptorFunctionInterfaces('Output'),...
            this.getCodeDescriptorFunctionInterfaces('Terminate')];
            for jj=1:length(runnables)

                m3iRunnable=this.findM3iRunnable(runnables(jj));

                if isempty(queuedPorts)
                    DirectWrites=runnables(jj).DirectWrites;
                else
                    DirectWrites=[runnables(jj).DirectWrites];
                    for i=1:length(queuedPorts)
                        port=queuedPorts(i);
                        if port.Timing.isEquivalentTo(runnables(jj).Timing)
                            DirectWrites.add(port);
                        end

                    end
                end
                DirectWrites=DirectWrites.toArray;
                for ii=1:length(DirectWrites)
                    implementation=DirectWrites(ii).Implementation;

                    if isempty(implementation)&&~isempty(DirectWrites(ii).VariantInfo)
                        continue;
                    end

                    switch class(implementation)
                    case{'coder.descriptor.Variable'}

                    case{'coder.descriptor.AutosarMemoryExpression'}

                    otherwise
                        accessType=implementation.DataAccessMode;
                        switch accessType
                        case{'ErrorStatus'}
                            assert(false,'Can not have an accessType of ErrorStatus for DirectWrites');
                        case{'ImplicitInterRunnable','ExplicitInterRunnable'}

                            m3iAccess=this.M3IElementFactory.createElement(m3iRunnable,...
                            'irvWrite',Simulink.metamodel.arplatform.behavior.IrvAccess.MetaClass);
                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.FlowDataCompInstanceRef.MetaClass);


                            m3iData=autosar.mm.Model.findChildByNameAndTypeName(this.m3iBehavior,implementation.VariableName,'Simulink.metamodel.arplatform.behavior.IrvData');



                            m3iInstanceRef.DataElements=m3iData;


                            m3iAccess.Name=arxml.arxml_private...
                            ('p_create_aridentifier',...
                            ['WV_',implementation.VariableName],...
                            this.MaxShortNameLength);

                            m3iAccess.instanceRef=m3iInstanceRef;






                            varInfo=DirectWrites(ii).VariantInfo;
                            aIRVWriteRunnableInfo=irvToRunnableInfo{implementation.VariableName};
                            if~isempty(aIRVWriteRunnableInfo)
                                aRunnableVarInfo=aIRVWriteRunnableInfo.RunnableToVariantInfo{m3iRunnable.Name};
                                if~isempty(aRunnableVarInfo)
                                    varInfo=aRunnableVarInfo.VariantInfoForIRV;
                                end
                            end

                            this.updateCodeDescriptorVariants(variationPoints,m3iAccess,...
                            varInfo,...
                            DirectWrites(ii).GraphicalName);
                        case{'ImplicitSend','ImplicitSendByRef','ExplicitSend','QueuedExplicitSend','EndToEndQueuedSend'}
                            eName=implementation.DataElement;
                            pName=implementation.Port;
                            ifName=implementation.Interface;


                            m3iAccess=this.M3IElementFactory.createElement(m3iRunnable,...
                            'dataAccess',Simulink.metamodel.arplatform.behavior.FlowDataAccess.MetaClass);
                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef.MetaClass);


                            [m3iPort,~,m3iData]=...
                            this.addSenderPort(ifName,eName,pName);



                            m3iInstanceRef.Port=m3iPort;
                            m3iInstanceRef.DataElements=m3iData;


                            m3iAccess.Name=arxml.arxml_private('p_create_aridentifier',['OUT_',pName,'_',eName],...
                            this.MaxShortNameLength);
                            switch accessType
                            case{'ImplicitSend','ImplicitSendByRef'}
                                m3iAccess.Kind=Simulink.metamodel.arplatform.behavior.DataAccessKind.ImplicitWrite;
                            case{'ExplicitSend','QueuedExplicitSend','EndToEndQueuedSend'}
                                m3iAccess.Kind=Simulink.metamodel.arplatform.behavior.DataAccessKind.ExplicitWrite;
                            otherwise
                                assert(false,'unknown accessType');
                            end
                            m3iAccess.instanceRef=m3iInstanceRef;

                            this.updateCodeDescriptorVariants(variationPoints,m3iAccess,...
                            DirectWrites(ii).VariantInfo,...
                            DirectWrites(ii).GraphicalName);
                        case{'ModeSend'}
                            eName=implementation.DataElement;
                            pName=implementation.Port;


                            m3iAccess=this.M3IElementFactory.createElement(m3iRunnable,...
                            'ModeSwitchPoint',Simulink.metamodel.arplatform.behavior.ModeSwitch.MetaClass);
                            m3iAccess.Name=arxml.arxml_private('p_create_aridentifier',['OUT_',pName,'_',eName],...
                            this.MaxShortNameLength);
                            m3iInstanceRef=this.M3IElementFactory.createElement(this.m3iSWC.instanceMapping,...
                            'instance',Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef.MetaClass);



                            [m3iPort,~,m3iModeGroup]=this.findModeGroup(...
                            this.m3iSWC,pName,eName);



                            m3iInstanceRef.Port=m3iPort;
                            m3iInstanceRef.groupElement=m3iModeGroup;


                            m3iAccess.InstanceRef=m3iInstanceRef;

                        otherwise
                            assert(false,DAStudio.message('RTW:autosar:unrecognisedAccessType',accessType));
                        end
                    end
                end
            end
            this.VariantBuilder.setVariationPointViaMap(variationPoints);
        end

        function xformCodeDescriptorRunnableServerCallPoints(this)
            if isempty(this.CodeDescriptor.getFullComponentInterface.ServerCallPoints.toArray)
                return;
            end
            variationPoints=containers.Map;

            outputFcns=this.getCodeDescriptorFunctionInterfaces('Output');
            initFcns=this.getCodeDescriptorFunctionInterfaces('Initialize');
            termFcns=this.getCodeDescriptorFunctionInterfaces('Terminate');
            CDserverCallPoints=this.CodeDescriptor.getFullComponentInterface.ServerCallPoints.toArray;

            runnables=[outputFcns,...
            initFcns,...
            termFcns];
            isExportFcnModel=autosar.validation.ExportFcnValidator.isExportFcn(this.ModelName);
            isSingleTasking=strcmp(get_param(this.ModelName,'EnableMultiTasking'),'off');
            isRateBasedSingleTaskingModel=~isExportFcnModel&&isSingleTasking;

            for runnableIdx=1:length(runnables)

                m3iRunnable=this.findM3iRunnable(runnables(runnableIdx));

                if initFcns==runnables(runnableIdx)
                    serverCallPoints={};
                    for scpIdx=1:length(CDserverCallPoints)
                        if strcmp(CDserverCallPoints(scpIdx).Timing.TimingMode,'INITIALIZE')
                            serverCallPoints{end+1}=CDserverCallPoints(scpIdx);%#ok<AGROW>
                        end
                    end
                    serverCallPoints=[serverCallPoints{:}];
                elseif termFcns==runnables(runnableIdx)
                    serverCallPoints={};
                    for scpIdx=1:length(CDserverCallPoints)
                        if strcmp(CDserverCallPoints(scpIdx).Timing.TimingMode,'TERMINATE')
                            serverCallPoints{end+1}=CDserverCallPoints(scpIdx);%#ok<AGROW>
                        end
                    end
                    serverCallPoints=[serverCallPoints{:}];
                elseif length(runnables)>1
                    runTiming=runnables(runnableIdx).Timing;
                    serverCallPoints={};
                    if isRateBasedSingleTaskingModel


                        for scpIdx=1:numel(CDserverCallPoints)
                            tmpSCP=CDserverCallPoints(scpIdx);
                            if strcmp(tmpSCP.Timing.TimingMode,'PERIODIC')
                                serverCallPoints{end+1}=tmpSCP;%#ok<AGROW>
                            end
                        end
                    else
                        for scpIdx=1:numel(CDserverCallPoints)
                            tmpSCP=CDserverCallPoints(scpIdx);
                            if(strcmp(tmpSCP.Timing.TimingMode,'UNION'))
                                unionInfo=tmpSCP.Timing.UnionTimingInfo.toArray;
                                for unionIdx=1:numel(unionInfo)
                                    if unionInfo(unionIdx).isEquivalentTo(runTiming)
                                        serverCallPoints{end+1}=tmpSCP;%#ok<AGROW>
                                        break;
                                    end
                                end
                            elseif tmpSCP.Timing.isEquivalentTo(runTiming)
                                serverCallPoints{end+1}=tmpSCP;%#ok<AGROW>
                            end
                        end
                    end
                    serverCallPoints=[serverCallPoints{:}];
                else
                    serverCallPoints=CDserverCallPoints;
                end

                for callPtIdx=1:length(serverCallPoints)
                    serverCallPoint=serverCallPoints(callPtIdx);

                    [InterfacePath,PortName,OperationName]=...
                    autosar.mm.sl2mm.ModelBuilder.findClientBlockPortOpNames(serverCallPoint);

                    if autosar.blocks.InternalTriggerBlock.isServerCallPointMappedToInternalTriggerPoint(serverCallPoint)


                        continue;
                    end


                    accessName=arxml.arxml_private('p_create_aridentifier',...
                    ['SC_',PortName,'_',OperationName],...
                    this.MaxShortNameLength);



                    [m3iClientPort,~,m3iOperation]=...
                    this.addClientPort(InterfacePath,...
                    OperationName,PortName);

                    if autosar.validation.ClientServerValidator.isNvMService(m3iOperation)
                        m3iAccess=this.findOrCreateInSequenceNamedItem(m3iRunnable,...
                        m3iRunnable.OperationNonBlockingCall,...
                        accessName,...
                        'Simulink.metamodel.arplatform.behavior.OperationNonBlockingAccess');
                        m3iAccess.Timeout=1;
                    else
                        m3iAccess=this.findOrCreateInSequenceNamedItem(m3iRunnable,...
                        m3iRunnable.operationBlockingCall,...
                        accessName,...
                        'Simulink.metamodel.arplatform.behavior.OperationBlockingAccess');
                    end

                    if m3iAccess.instanceRef.size==0

                        m3iInstanceRef=Simulink.metamodel.arplatform.instance.OperationPortInstanceRef(this.LocalM3IModel);
                        this.m3iSWC.instanceMapping.instance.append(m3iInstanceRef);
                        m3iAccess.instanceRef.append(m3iInstanceRef);

                        m3iInstanceRef.Port=m3iClientPort;
                        m3iInstanceRef.Operations=m3iOperation;
                    else
                        assert(m3iAccess.instanceRef.size==1,'autosar.mm.ModelBuilder expected instanceRef of size 1');
                        assert(m3iAccess.instanceRef.at(1).Port==m3iClientPort,'instanceRef not pointing to correct port');
                        assert(m3iAccess.instanceRef.at(1).Operations==m3iOperation,'instanceRef not pointing to correct operation');
                    end

                    this.updateCodeDescriptorVariants(variationPoints,m3iAccess,...
                    serverCallPoints(callPtIdx).VariantInfo,...
                    serverCallPoints(callPtIdx).PortName);
                    this.updateCodeDescriptorVariants(variationPoints,m3iClientPort,...
                    serverCallPoints(callPtIdx).VariantInfo,...
                    serverCallPoints(callPtIdx).PortName);


                    portName=m3iAccess.instanceRef.at(1).Port.Name;
                    operationName=m3iAccess.instanceRef.at(1).Operations.Name;
                    key=[portName,'.',operationName];
                    if this.PortOperation2TimeoutMap.isKey(key)
                        m3iAccess.Timeout=this.PortOperation2TimeoutMap(key);
                    end
                end
            end
            this.VariantBuilder.setVariationPointViaMap(variationPoints);
        end

        function xformExclusiveAreasForSubSystems(this)

            mmgr=get_param(this.ModelName,'MappingManager');
            mapping=mmgr.getActiveMappingFor('AutosarTarget');


            for i=1:length(mapping.SubSystemMappings)
                name=mapping.SubSystemMappings(i).MappedTo;
                m3iExclusiveArea=this.findOrCreateInSequenceNamedItem(this.m3iBehavior,this.m3iBehavior.exclusiveArea,...
                name,'Simulink.metamodel.arplatform.behavior.ExclusiveArea');

                runnableName=mapping.SubSystemMappings(i).RunnableName;
                m3iRunnable=autosar.mm.Model.findChildByNameAndTypeName(this.m3iBehavior,runnableName,...
                'Simulink.metamodel.arplatform.behavior.Runnable');

                assert(m3iRunnable.isvalid(),'Did not find runnable');
                m3iRunnable.canEnterExclusiveArea.append(m3iExclusiveArea);

            end
        end

        function xformVariationPointProxies(this)
            [refPreBuildVariantAnnotations,refPostBuildVariantAnnotations]=this.getModelRefVariantAnnotations();
            preBuildVariantAnnotations=[this.CodeDescriptor.getFullComponentInterface.VariantAnnotations.toArray,refPreBuildVariantAnnotations];
            postBuildAnnotations=[this.CodeDescriptor.getFullComponentInterface.PostBuildVariantAnnotations.toArray,refPostBuildVariantAnnotations];

            schemaVersion=get_param(this.ModelName,'AutosarSchemaVersion');
            if~isempty(postBuildAnnotations)&&strcmp(schemaVersion,'4.0')
                DAStudio.error('autosarstandard:exporter:StartupVariantSchema',this.ModelName);
            end

            codegenVariants=this.VariantBuilder.find_codegen_variants();


            this.VariantBuilder.xformCodeGenTimeVariantAnnotations(codegenVariants,preBuildVariantAnnotations);


            this.VariantBuilder.xformPreCompileVariantAnnotations(preBuildVariantAnnotations);


            this.VariantBuilder.xformPostBuildVariantAnnotations(postBuildAnnotations)


            params=this.getCodeDescriptorDataInterfaces('Parameters');
            this.VariantBuilder.xformValueVariants(this.m3iBehavior,params);
        end

        function xformSymbolicDimensionDefinitions(this)
            symdims=this.CodeDescriptor.getFullComponentInterface.SymbolicDimensionDefinitions.toArray;
            this.VariantBuilder.xformSymbolicDimensions(symdims);
        end

        function xformCodeDescriptorTimingInformation(this)
            m3iEvents=this.m3iBehavior.Events;
            m3iTimingEvtMap=containers.Map();
            for evtIdx=1:m3iEvents.size()
                m3iEvent=m3iEvents.at(evtIdx);
                if isa(m3iEvent,'Simulink.metamodel.arplatform.behavior.TimingEvent')&&...
                    m3iEvent.StartOnEvent.isvalid()
                    m3iTimingEvtMap(m3iEvent.StartOnEvent.Name)=evtIdx;
                end
            end
            outputFcns=this.getCodeDescriptorFunctionInterfaces('Output');
            for ii=1:length(outputFcns)
                period=outputFcns(ii).Timing.SamplePeriod;
                if(period==0.0)
                    continue;
                end
                runnableName=autosar.mm.sl2mm.ModelBuilder.getRunnableNameFromSymbol(this.ModelName,...
                this.m3iBehavior,outputFcns(ii).Prototype.Name);
                if m3iTimingEvtMap.isKey(runnableName)
                    this.m3iBehavior.Events.at(m3iTimingEvtMap(runnableName)).Period=period;
                end
            end
        end

        function[m3iPort,m3iInterface,m3iOperation]=addClientPort(...
            this,interface,operation,port)



            arPkg='Simulink.metamodel.arplatform';
            csifCls=[arPkg,'.interface.ClientServerInterface'];
            portCls=[arPkg,'.port.ClientPort'];
            opCls=[arPkg,'.interface.Operation'];


            m3iPort=this.findOrCreateInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.ClientPorts,port,portCls);


            if~isempty(interface)
                [ifPkg,ifName]=this.getNodePathAndName(interface);
                m3iIntfPkg=this.M3IElementFactory.getOrAddARPackage('Interface',ifPkg);
                m3iInterface=this.findOrCreateInterface(m3iIntfPkg,...
                ifName,csifCls);
                m3iPort.Interface=m3iInterface;
            else
                m3iInterface=m3iPort.Interface;
            end

            m3iOperation=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.Operations,operation,opCls);

        end

        function xformIncludedDataTypeSets(this)
            includedDataTypeSetBuilder=autosar.mm.sl2mm.IncludedTypeSetBuilder(...
            this.ModelName,this.m3iBehavior,this.TypeBuilder,this.CodeDescriptorCache);
            includedDataTypeSetBuilder.buildOrUpdateIncludedDataTypeSets(this.CodeDescriptor);
        end

        function[m3iPort,m3iInterface,m3iData]=addReceiverPort(...
            this,interface,element,port)

            if this.isAdaptiveAutosar
                [m3iPort,m3iInterface,m3iData]=this.addServiceRequiredPort(...
                interface,element,port);
                return
            end

            arPkg='Simulink.metamodel.arplatform';
            srifCls=[arPkg,'.interface.SenderReceiverInterface'];
            dataCls=[arPkg,'.interface.FlowData'];
            rPortCls=[arPkg,'.port.DataReceiverPort'];
            srPortCls=[arPkg,'.port.DataSenderReceiverPort'];
            n_rPortCls=[arPkg,'.port.NvDataReceiverPort'];
            n_srPortCls=[arPkg,'.port.NvDataSenderReceiverPort'];



            m3iPort=this.findInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.ReceiverPorts,port,rPortCls);

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.SenderReceiverPorts,port,srPortCls);
            end

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.NvReceiverPorts,port,n_rPortCls);
            end

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.NvSenderReceiverPorts,port,n_srPortCls);
            end

            if~m3iPort.isvalid()

                m3iPort=this.createInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.ReceiverPorts,port,rPortCls);
            end

            if isempty(interface)
                assert(m3iPort.Interface.isvalid());
                m3iInterface=m3iPort.Interface;
            else
                m3iInterface=this.findOrCreateInterface(this.m3iInterfacePkg,...
                interface,srifCls);
                m3iPort.Interface=m3iInterface;
            end
            m3iData=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.DataElements,element,dataCls);
        end

        function[m3iPort,m3iInterface,m3iData]=addSenderPort(...
            this,interface,element,port)

            if this.isAdaptiveAutosar
                [m3iPort,m3iInterface,m3iData]=this.addServiceProvidedPort(...
                interface,element,port);
                return
            end

            arPkg='Simulink.metamodel.arplatform';
            srifCls=[arPkg,'.interface.SenderReceiverInterface'];
            dataCls=[arPkg,'.interface.FlowData'];
            pPortCls=[arPkg,'.port.DataSenderPort'];
            srPortCls=[arPkg,'.port.DataSenderReceiverPort'];
            n_sPortCls=[arPkg,'.port.NvDataSenderPort'];
            n_srPortCls=[arPkg,'.port.NvDataSenderReceiverPort'];


            m3iPort=this.findInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.SenderPorts,port,pPortCls);

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.SenderReceiverPorts,port,srPortCls);
            end

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.NvSenderPorts,port,n_sPortCls);
            end

            if~m3iPort.isvalid()

                m3iPort=this.findInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.NvSenderReceiverPorts,port,n_srPortCls);
            end

            if~m3iPort.isvalid()

                m3iPort=this.createInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.SenderPorts,port,pPortCls);
            end


            if isempty(interface)
                assert(m3iPort.Interface.isvalid());
                m3iInterface=m3iPort.Interface;
            else
                m3iInterface=this.findOrCreateInterface(this.m3iInterfacePkg,...
                interface,srifCls);
                m3iPort.Interface=m3iInterface;
            end
            m3iData=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.DataElements,element,dataCls);
        end



        function[m3iPort,m3iInterface,m3iData]=addServiceRequiredPort(...
            this,interface,event,port)

            arPkg='Simulink.metamodel.arplatform';
            ifCls=[arPkg,'.interface.ServiceInterface'];
            dataCls=[arPkg,'.interface.FlowData'];
            rPortCls=[arPkg,'.port.ServiceRequiredPort'];


            m3iPort=this.findInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.RequiredPorts,port,rPortCls);

            if~m3iPort.isvalid()

                m3iPort=this.createInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.RequiredPorts,port,rPortCls);
            end

            if isempty(interface)
                assert(m3iPort.Interface.isvalid());
                m3iInterface=m3iPort.Interface;
            else
                m3iInterface=this.findOrCreateInterface(this.m3iInterfacePkg,...
                interface,ifCls);
                m3iPort.Interface=m3iInterface;
            end
            m3iData=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.Events,event,dataCls);
        end

        function[m3iPort,m3iInterface,m3iOperation]=addServiceRequiredPortWithMethod(...
            this,interface,methodName,portName)


            arPkg='Simulink.metamodel.arplatform';
            svcIfCls=[arPkg,'.interface.ServiceInterface'];
            portCls=[arPkg,'.port.ServiceRequiredPort'];
            methodCls=[arPkg,'.interface.Operation'];


            m3iPort=this.findOrCreateInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.RequiredPorts,portName,portCls);


            if~isempty(interface)
                [ifPkg,ifName]=this.getNodePathAndName(interface);
                m3iIntfPkg=this.M3IElementFactory.getOrAddARPackage('Interface',ifPkg);
                m3iInterface=this.findOrCreateInterface(m3iIntfPkg,...
                ifName,svcIfCls);
                m3iPort.Interface=m3iInterface;
            else
                m3iInterface=m3iPort.Interface;
            end

            m3iOperation=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.Methods,methodName,methodCls);
        end

        function[m3iPort,m3iInterface,m3iData]=addServiceProvidedPort(...
            this,interface,event,port)

            arPkg='Simulink.metamodel.arplatform';
            ifCls=[arPkg,'.interface.ServiceInterface'];
            dataCls=[arPkg,'.interface.FlowData'];
            pPortCls=[arPkg,'.port.ServiceProvidedPort'];


            m3iPort=this.findInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.ProvidedPorts,port,pPortCls);

            if~m3iPort.isvalid()

                m3iPort=this.createInSequenceNamedItem(...
                this.m3iSWC,this.m3iSWC.ProvidedPorts,port,pPortCls);
            end


            if isempty(interface)
                assert(m3iPort.Interface.isvalid());
                m3iInterface=m3iPort.Interface;
            else
                m3iInterface=this.findOrCreateInterface(this.m3iInterfacePkg,...
                interface,ifCls);
                m3iPort.Interface=m3iInterface;
            end
            m3iData=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.Events,event,dataCls);
        end

        function[m3iPort,m3iInterface,m3iOperation]=addServiceProvidedPortWithMethod(...
            this,interface,methodName,portName)


            arPkg='Simulink.metamodel.arplatform';
            svcIfCls=[arPkg,'.interface.ServiceInterface'];
            portCls=[arPkg,'.port.ServiceProvidedPort'];
            methodCls=[arPkg,'.interface.Operation'];


            m3iPort=this.findOrCreateInSequenceNamedItem(...
            this.m3iSWC,this.m3iSWC.ProvidedPorts,portName,portCls);


            if~isempty(interface)
                [ifPkg,ifName]=this.getNodePathAndName(interface);
                m3iIntfPkg=this.M3IElementFactory.getOrAddARPackage('Interface',ifPkg);
                m3iInterface=this.findOrCreateInterface(m3iIntfPkg,...
                ifName,svcIfCls);
                m3iPort.Interface=m3iInterface;
            else
                m3iInterface=m3iPort.Interface;
            end

            m3iOperation=this.findOrCreateInSequenceNamedItem(...
            m3iInterface,m3iInterface.Methods,methodName,methodCls);
        end

        function m3iArgument=addArgument(this,operation,name,m3iType)
            arIntfPkg='Simulink.metamodel.arplatform.interface';
            argCls=[arIntfPkg,'.ArgumentData'];

            m3iArgument=this.findOrCreateInSequenceNamedItem(...
            operation,operation.Arguments,name,argCls);

            if~m3iArgument.Type.isvalid()
                m3iArgument.Type=m3iType;
            else
                assert(m3iType==m3iArgument.Type)
            end
        end


        function addPossibleErrors(this,returnArg,m3iInterface,m3iOperation)

            if~isempty(returnArg)

                if m3iInterface.PossibleError.isEmpty()
                    appErr=this.findOrCreateInSequenceNamedItem(m3iInterface,...
                    m3iInterface.PossibleError,...
                    'NOT_OK',...
                    'Simulink.metamodel.arplatform.common.ApplicationError');
                    appErr.errorCode=1;
                    m3iInterface.PossibleError.append(appErr);
                end


                if m3iOperation.PossibleError.isEmpty()
                    for appErrIdx=1:m3iInterface.PossibleError.size()
                        appErr=m3iInterface.PossibleError.at(appErrIdx);
                        m3iOperation.PossibleError.append(appErr);
                    end
                end
            end

        end


        function m3iSwAddrMethod=findOrCreateSwAddressMethod(this,swAddrMethodName,isSectionTypeCode)


            import autosar.mm.util.XmlOptionsAdapter;

            metaClsStr='Simulink.metamodel.arplatform.common.SwAddrMethod';



            m3iMetaClass=feval(sprintf('%s.MetaClass',metaClsStr));
            arPkg=this.SharedM3IModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,swAddrMethodName,m3iMetaClass);
            if(seq.size==0)

                addrPkg=XmlOptionsAdapter.get(arPkg,...
                'SwAddressMethodPackage');
                if isempty(addrPkg)
                    addrPkg=[this.XmlOpts.DataTypePackage,'/'...
                    ,autosar.mm.util.XmlOptionsDefaultPackages.SwAddressMethods];
                    XmlOptionsAdapter.set(arPkg,'SwAddressMethodPackage',...
                    addrPkg);
                end
                m3iSwAddrMethodPkg=...
                this.M3IElementFactory.getOrAddARPackage('SwAddressMethod',addrPkg);


                m3iSwAddrMethod=this.findOrCreateInSequenceNamedItem(...
                m3iSwAddrMethodPkg,m3iSwAddrMethodPkg.packagedElement,...
                swAddrMethodName,metaClsStr);
                if isSectionTypeCode
                    sectionTypeStr=...
                    Simulink.metamodel.arplatform.behavior.SectionTypeKind.Code;
                else
                    sectionTypeStr=...
                    Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var;
                end
                m3iSwAddrMethod.SectionType=sectionTypeStr;
            elseif(seq.size==1)

                m3iSwAddrMethod=seq.at(1);
                if isSectionTypeCode

                    m3iSwAddrMethod.SectionType=...
                    Simulink.metamodel.arplatform.behavior.SectionTypeKind.Code;
                end
            else
                assert(false,['Multiple sw-address-methods with name: ',swAddrMethodName]);
            end


            m3iSwAddrMethod.MemoryAllocationKeywordPolicy='ADDR-METHOD-SHORT-NAME';
        end

        function m3iSwAddrMethod=findOrCreateSwAddressMethodFromJsonStr(this,jsonString,name)
            m3iSwAddrMethod=Simulink.metamodel.arplatform.common.SwAddrMethod.empty(1,0);
            if isempty(jsonString)
                return;
            end
            records=jsondecode(jsonString);
            result=arrayfun(@(obj)strcmp(obj.Name,name),records);
            if any(result)
                record=records(result);
                metaClsStr='Simulink.metamodel.arplatform.common.SwAddrMethod';

                arRootShared=this.SharedM3IModel.RootPackage.at(1);
                assert(isa(arRootShared,'Simulink.metamodel.arplatform.common.AUTOSAR'));
                swAddrMethodName=record.Name;

                m3iSwAddrMethodPkg=this.M3IElementFactory.getOrAddARPackage('SwAddrMethod',record.qualifiedName);
                seq=autosar.mm.Model.findObjectByName(arRootShared,[record.qualifiedName,'/',swAddrMethodName],false);
                if(seq.size==0)

                    m3iSwAddrMethod=this.findOrCreateInSequenceNamedItem(...
                    m3iSwAddrMethodPkg,m3iSwAddrMethodPkg.packagedElement,...
                    swAddrMethodName,metaClsStr);
                elseif(seq.size==1)

                    m3iSwAddrMethod=seq.at(1);
                else
                    assert(false,['Multiple sw-address-methods with name: ',swAddrMethodName]);
                end


                m3iSwAddrMethod.SectionType=Simulink.metamodel.arplatform.behavior.SectionTypeKind.Var;
                m3iSwAddrMethod.MemoryAllocationKeywordPolicy='ADDR-METHOD-SHORT-NAME';
            end
        end

        function m3iSWC=findOrCreateComponentSWC(this,compType,compPath)

            metaPkgName='Simulink.metamodel.arplatform.component';
            [compPkg,compName]=this.getNodePathAndName(compPath);
            switch(compType)
            case 'Atomic'
                compMetaClass=[metaPkgName,'.AtomicComponent'];
                m3iCompPkg=this.M3IElementFactory.getOrAddARPackage('AtomicComponent',compPkg);
            case 'Parameter'
                compMetaClass=[metaPkgName,'.ParameterComponent'];
                m3iCompPkg=this.M3IElementFactory.getOrAddARPackage('ParameterComponent',compPkg);
            case 'AdaptiveApplication'
                compMetaClass=[metaPkgName,'.AdaptiveApplication'];
                m3iCompPkg=this.M3IElementFactory.getOrAddARPackage('AdaptiveApplication',compPkg);
            otherwise
                assert(false,'Invalid component type passed to findOrCreateComponentSWC');
            end

            m3iSWC=this.findOrCreateInSequenceNamedItem(m3iCompPkg,...
            m3iCompPkg.packagedElement,compName,compMetaClass);
        end

        function addParameterComSpec(this,m3iPort,m3iData,calPrmGraphicalName)
            metaPkg='Simulink.metamodel.arplatform.port';
            if isa(m3iPort,'Simulink.metamodel.arplatform.port.ParameterSenderPort')
                infoMetaClass=[metaPkg,'.ParameterSenderPortInfo'];
                comSpecMetaClass=[metaPkg,'.ParameterSenderPortComSpec'];
            else
                assert(isa(m3iPort,'Simulink.metamodel.arplatform.port.ParameterReceiverPort'),...
                'invalid m3iPort: expect a ParameterSenderPort or ParameterReceiverPort type');
                infoMetaClass=[metaPkg,'.ParameterReceiverPortInfo'];
                comSpecMetaClass=[metaPkg,'.ParameterReceiverPortComSpec'];
            end
            m3iComSpec=[];
            for ii=1:m3iPort.info.size()
                if m3iPort.info.at(ii).DataElements==m3iData
                    m3iComSpec=m3iPort.info.at(ii).comSpec;
                    break;
                end
            end

            if isempty(m3iComSpec)
                m3iInfo=feval(infoMetaClass,m3iPort.rootModel);
                m3iComSpec=feval(comSpecMetaClass,m3iPort.rootModel);

                m3iInfo.DataElements=m3iData;
                m3iInfo.comSpec=m3iComSpec;
                m3iPort.info.append(m3iInfo);
            end

            initValueName=arxml.arxml_private('p_create_aridentifier',...
            [m3iPort.Name,'_',m3iData.Name],this.MaxShortNameLength);
            m3iType=m3iData.Type;
            if this.mustExportLUTRecordValueSpecification(m3iType)
                m3iType=this.TypeBuilder.findImpTypeForAppType(m3iType);
            end
            m3iComSpec.InitValue=autosar.mm.sl2mm.ConstantBuilder.findOrCreateValueSpecificationFromGlobalScopeObj(...
            this.ModelName,m3iPort.rootModel,m3iComSpec.InitValue,this.m3iConstantPkg,m3iType,...
            this.MaxShortNameLength,initValueName,calPrmGraphicalName,this.SymbolicDefinitions);

            m3iComSpec.InitialValue=Simulink.metamodel.foundation.ImmutableValueSpecification.empty(1,0);
        end

        function tf=mustExportLUTRecordValueSpecification(this,m3iType)
            tf=slfeature('AUTOSARLUTRecordValueSpec')>0&&...
            ~this.XmlOpts.LUTApplValueSpec&&...
            (isa(m3iType,'Simulink.metamodel.types.LookupTableType')||...
            isa(m3iType,'Simulink.metamodel.types.SharedAxisType'));
        end

        function cleanupComSpecsOnCalibCompsPPorts(this,m3iModel)
            params=this.getCodeDescriptorDataInterfaces('Parameters');
            for ii=1:length(params)
                implementation=params(ii).Implementation;
                if~isempty(implementation)&&isa(implementation,'coder.descriptor.AutosarCalibration')&&...
                    strcmp(implementation.DataAccessMode,'Calibration')
                    calibCompPath=implementation.CalibrationComponent;
                    if~isempty(calibCompPath)
                        compObj=autosar.mm.Model.findObjectByName(m3iModel,calibCompPath);
                        if~isempty(compObj)&&compObj.size>0
                            compObj=compObj.at(1);
                            for portIdx=1:compObj.ParameterSenderPorts.size
                                infoSeq=compObj.ParameterSenderPorts.at(portIdx).info;
                                while~infoSeq.isEmpty
                                    infoSeq.at(1).destroy();
                                end
                            end
                        end
                    end
                end
            end
        end

        function[alreadyMapped,arParameterAccessMode,arShortName,swCalibrationAccess,displayFormat,swAddrMethod]=isMappedParameter(self,paramGraphicalName)
            alreadyMapped=false;
            arParameterAccessMode=[];
            arShortName=[];
            swCalibrationAccess=[];
            displayFormat='';
            swAddrMethod=Simulink.metamodel.arplatform.common.SwAddrMethod.empty(1,0);
            mapping=autosar.api.Utils.modelMapping(self.ModelName);
            lutObj=mapping.LookupTables.findobj('LookupTableName',paramGraphicalName);
            if~isempty(lutObj)
                arParameter=lutObj.MappedTo;
                arParameterAccessMode=arParameter.ParameterAccessMode;
                arShortName=arParameter.Parameter;
                alreadyMapped=true;
            end

            prmObj=mapping.ModelScopedParameters.findobj('Parameter',paramGraphicalName);
            if~isempty(prmObj)
                dictRef=prmObj.MappedTo;
                arParameterAccessMode=dictRef.ArDataRole;
                if~strcmp(arParameterAccessMode,'Auto')
                    arShortName=dictRef.getPerInstancePropertyValue('ShortName');
                    propValue=dictRef.getPerInstancePropertyValue('SwCalibrationAccess');
                    swCalibrationAccess=self.getM3ISwCalibrationAccessEnumFromString(propValue);
                    propValue=dictRef.getPerInstancePropertyValue('DisplayFormat');
                    if~isempty(propValue)
                        displayFormat=propValue;
                    else
                        displayFormat='';
                    end
                    propValue=dictRef.getPerInstancePropertyValue('SwAddrMethod');
                    if~isempty(propValue)
                        swAddrMethod=self.findOrCreateSwAddressMethod(...
                        propValue,false);
                        assert(~isempty(swAddrMethod),'Could not find SwAddrMethod');
                    end
                end
                if isempty(arShortName)
                    arShortName=paramGraphicalName;
                end
                alreadyMapped=true;
            end
        end

        function updatePIMFromAUTOSARCalPrm(this,m3iData,signalObj,blkH,subCompModelName)




            if nargin<5
                subCompModelName='';
                isSubComponentModel=false;
            else
                isSubComponentModel=true;
            end

            if blkH<0
                return;
            end


            if isSubComponentModel
                mmgr=get_param(subCompModelName,'MappingManager');
            else
                mmgr=get_param(this.ModelName,'MappingManager');
            end
            mapping=mmgr.getActiveMappingFor('AutosarTarget');
            mappingElement=mapping.DataStores.findobj('OwnerBlockHandle',blkH);
            if isempty(mappingElement)
                mappingElement=mapping.SynthesizedDataStores.findobj('Name',get_param(blkH,'DataStoreName'));
            end


            if isempty(mappingElement)||...
                ~strcmp(mappingElement.MappedTo.ArDataRole,'ArTypedPerInstanceMemory')
                return;
            end
            needsNVRAMAccess=mappingElement.MappedTo.getPerInstancePropertyValue('NeedsNVRAMAccess');
            if~strcmp(needsNVRAMAccess,'true')
                return;
            end


            m3iServiceDependency=this.findOrCreateServiceDependency(m3iData);
            if~isempty(signalObj)&&isa(signalObj,'Simulink.Signal')&&...
                ~isempty(signalObj.InitialValue)
                [varExists,paramObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,signalObj.InitialValue);
                if varExists&&~isempty(paramObj)
                    isLegacyParam=isa(paramObj,'Simulink.Parameter')&&...
                    strcmp(paramObj.CoderInfo.StorageClass,'Custom')&&...
                    strcmp(paramObj.CoderInfo.CustomStorageClass,'InternalCalPrm');
                    isMappedParam=this.isMappedParameter(signalObj.InitialValue);
                    if isLegacyParam||isMappedParam
                        paramM3iData=autosar.mm.Model.findChildByNameAndTypeName(this.m3iBehavior,...
                        signalObj.InitialValue,'Simulink.metamodel.arplatform.interface.ParameterData');
                        if~isempty(paramM3iData)&&(paramM3iData.Kind==Simulink.metamodel.arplatform.behavior.ParameterKind.Shared||...
                            paramM3iData.Kind==Simulink.metamodel.arplatform.behavior.ParameterKind.Pim)
                            m3iServiceDependency.UsedParameterElement=paramM3iData;
                        end
                    end
                end
            end
            this.m3iBehavior.ServiceDependency.append(m3iServiceDependency);
        end

        function updateSwAddrMethodFromMapping(this,m3iData,swAddrMethodName)



            if~isempty(swAddrMethodName)
                m3iSwAddrMethod=this.findOrCreateSwAddressMethod(...
                swAddrMethodName,false);
                assert(~isempty(m3iSwAddrMethod),'Could not find SwAddrMethod');

                m3iData.SwAddrMethod=m3iSwAddrMethod;
            else



                m3iData.SwAddrMethod=Simulink.metamodel.arplatform.common.SwAddrMethod.empty(1,0);
            end
        end

        function updateInstanceSpecificProperties(this,m3iData,mappingElementName,updateTypeQualifier,blkOrPortH,subCompModelName)






            if nargin<6
                subCompModelName='';
                isSubComponentModel=false;
            else
                isSubComponentModel=true;
            end

            if blkOrPortH<0
                return;
            end

            if isSubComponentModel
                mmgr=get_param(subCompModelName,'MappingManager');
            else
                mmgr=get_param(this.ModelName,'MappingManager');
            end
            mapping=mmgr.getActiveMappingFor('AutosarTarget');


            switch mappingElementName
            case 'Signal'


                mappingElement=mapping.Signals.findobj('PortHandle',blkOrPortH);
            case 'State'
                mappingElement=mapping.States.findobj('OwnerBlockHandle',blkOrPortH);
            case 'Parameter'
                mappingElement=mapping.ModelScopedParameters.findobj('Parameter',m3iData.Name);
            case 'DSM'
                mappingElement=mapping.DataStores.findobj('OwnerBlockHandle',blkOrPortH);
            case 'SynthesizedDataStore'
                mappingElement=mapping.SynthesizedDataStores.findobj('Name',get_param(blkOrPortH,'DataStoreName'));
            otherwise
                assert(false,'Unexpected mapping element');
            end

            if isempty(mappingElement)


                return;
            end
            assert(length(mappingElement)==1,'Expected to find exactly 1 mapping element');

            if slfeature('AUTOSARLongNameAuthoring')
                longNameInCodeMapping=mappingElement.MappedTo.getPerInstancePropertyValue('LongName');
                if~isempty(longNameInCodeMapping)
                    this.createOrUpdateM3ILongName(this.LocalM3IModel,m3iData,longNameInCodeMapping);
                end
            end


            swAddrMethodName=mappingElement.MappedTo.getPerInstancePropertyValue('SwAddrMethod');
            this.updateSwAddrMethodFromMapping(m3iData,swAddrMethodName);

            if updateTypeQualifier


                this.createOrUpdateTypeForAdditionalNativeTypeQualifier(m3iData,mappingElement);
            end


            swCalAccess=mappingElement.MappedTo.getPerInstancePropertyValue('SwCalibrationAccess');
            if~isempty(swCalAccess)
                m3iSwCalAccessKind=autosar.mm.sl2mm.ModelBuilder.getM3ISwCalibrationAccessEnumFromString(swCalAccess);
                m3iData.SwCalibrationAccess=m3iSwCalAccessKind;
            end
            swDisplayFormat=mappingElement.MappedTo.getPerInstancePropertyValue('DisplayFormat');
            if~isempty(swDisplayFormat)
                m3iData.DisplayFormat=swDisplayFormat;
            end

            needsNVRAMAccess=mappingElement.MappedTo.getPerInstancePropertyValue('NeedsNVRAMAccess');
            if isempty(needsNVRAMAccess)
                needsNVRAMAccess=false;
            else
                needsNVRAMAccess=autosar.mm.util.NvBlockNeedsCodePropsHelper.convertNvBlockNeedFromStringToLogical(needsNVRAMAccess);
            end

            if needsNVRAMAccess&&strcmp(mappingElement.MappedTo.ArDataRole,'ArTypedPerInstanceMemory')
                m3iServiceDependency=this.findOrCreateServiceDependency(m3iData);
                if isempty(m3iServiceDependency.ServiceNeeds)

                    m3iServiceDependency.ServiceNeeds=Simulink.metamodel.arplatform.behavior.NvBlockNeeds(this.LocalM3IModel);
                    m3iServiceDependency.ServiceNeeds.Name=m3iServiceDependency.Name;
                    this.m3iBehavior.ServiceDependency.append(m3iServiceDependency);
                    this.m3iUsedDataElement2ServiceDependencyQNameMap(m3iData.qualifiedName)=m3iServiceDependency.qualifiedName;
                end
                assert(isa(m3iServiceDependency.ServiceNeeds,'Simulink.metamodel.arplatform.behavior.NvBlockNeeds'),'Expected m3iServiceNeeds to be NvBlockNeeds.')
                autosar.mm.util.NvBlockNeedsCodePropsHelper.updateNvBlockNeedsFromCodeProperties(m3iServiceDependency.ServiceNeeds,mappingElement);
            end
        end

        function m3iServiceDependency=findOrCreateServiceDependency(this,m3iData)
            if this.m3iUsedDataElement2ServiceDependencyQNameMap.isKey(m3iData.qualifiedName)

                serviceDependencyQName=this.m3iUsedDataElement2ServiceDependencyQNameMap(m3iData.qualifiedName);
                m3iServiceDependencySeq=autosar.mm.Model.findObjectByName(this.LocalM3IModel,serviceDependencyQName);
                assert(m3iServiceDependencySeq.size==1,'Expected service dependency to be unique');
                m3iServiceDependency=m3iServiceDependencySeq.at(1);
                if isempty(m3iServiceDependency.UsedDataElement)
                    m3iServiceDependency.UsedDataElement=m3iData;
                end
            else

                m3iServiceDependency=Simulink.metamodel.arplatform.behavior.ServiceDependency(this.LocalM3IModel);
                m3iServiceDependency.Name=arxml.arxml_private('p_create_aridentifier',['SwcNv_',m3iData.Name],this.MaxShortNameLength);
                m3iServiceDependency.UsedDataElement=m3iData;
                this.m3iUsedDataElement2ServiceDependencyQNameMap(m3iData.qualifiedName)=m3iServiceDependency.qualifiedName;
            end
        end

        function createOrUpdateTypeForAdditionalNativeTypeQualifier(this,m3iData,mappingElement)






            propertyNames=...
            autosar.ui.metamodel.PackageString.CommonAdditionalNativeTypeQualifierProperties;
            if isa(mappingElement,'Simulink.AutosarTarget.ModelScopedParameterMapping')


                propertyNames=[propertyNames,...
                autosar.ui.metamodel.PackageString.ParameterAdditionalNativeTypeQualifierProperties];
            end
            needNewType=false;
            typeQualifier=[];


            mangledTypeName='';

            if m3iData.Type.IsApplication


                m3iType=this.TypeBuilder.findImpTypeForAppType(m3iData.Type);
            else
                m3iType=m3iData.Type;
            end


            baseTypeName=m3iType.Name;


            for propName=propertyNames
                valueStr=mappingElement.MappedTo.getPerInstancePropertyValue(propName{1});

                if strcmp(valueStr,'false')
                    value=false;
                elseif strcmp(valueStr,'true')
                    value=true;
                else
                    value=valueStr;
                end
                typeQualifier.(propName{1})=value;


                nameExtension='';
                switch propName{1}
                case autosar.ui.metamodel.PackageString.IsVolatileString
                    if typeQualifier.IsVolatile
                        nameExtension='volatile';
                    end
                    needNewType=needNewType||m3iType.(propName{1})~=value;
                    if m3iType.(propName{1})


                        baseTypeName=erase(baseTypeName,'_volatile');
                    end
                case autosar.ui.metamodel.PackageString.IsConstString
                    if typeQualifier.IsConst
                        nameExtension='const';
                    end
                    needNewType=needNewType||m3iType.(propName{1})~=value;
                    if m3iType.(propName{1})


                        baseTypeName=erase(baseTypeName,'_const');
                    end
                case autosar.ui.metamodel.PackageString.QualifierString
                    nameExtension=typeQualifier.Qualifier;
                    needNewType=needNewType||~strcmp(m3iType.(propName{1}),value);
                    if~isempty(m3iType.(propName{1}))


                        baseTypeName=erase(baseTypeName,['_',nameExtension]);
                    end
                otherwise
                    assert(false,'Unexpected type qualifier field name');
                end
                if~isempty(nameExtension)
                    mangledTypeName=[mangledTypeName,'_',nameExtension];%#ok<AGROW>
                end
            end




            if needNewType


                enforeUnique=false;
                mangledTypeName=arxml.arxml_private('p_create_aridentifier',...
                [baseTypeName,mangledTypeName],min(this.MaxShortNameLength,namelengthmax),enforeUnique);
                this.TypeBuilder.findOrCreateM3ITypeWithAdditionalNativeTypeQualifier(...
                m3iData,typeQualifier,mangledTypeName);
            end
        end

        function[isDualScaledParam,dataObj]=isDualScaledParameter(...
            this,modelName,paramName)

            isDualScaledParam=false;
            [varExists,dataObj,isModelWorkspace]=...
            autosar.utils.Workspace.objectExistsInModelScope(modelName,paramName);

            if~varExists
                return
            end

            isDualScaledDataObj=isa(dataObj,'Simulink.AbstractDualScaledParameter');
            if isDualScaledDataObj
                if isModelWorkspace

                    [isMapped,arParameterAccessMode]=this.isMappedParameter(paramName);
                    isDualScaledParam=isMapped&&~strcmp(arParameterAccessMode,'Auto');
                else

                    isDualScaledParam=isa(dataObj,'AUTOSAR.DualScaledParameter')...
                    &&strcmp(dataObj.CoderInfo.StorageClass,'Custom')...
                    &&(isa(dataObj.CoderInfo.CustomAttributes,...
                    'SimulinkCSC.AttribClass_AUTOSAR_InternalCalPrm')...
                    ||isa(dataObj.CoderInfo.CustomAttributes,...
                    'SimulinkCSC.AttribClass_AUTOSAR_CalPrm'));
                end
            end
        end

        function interfaces=getCodeDescriptorFunctionInterfaces(this,type)
            interfaces=this.CodeDescriptor.getFunctionInterfaces(type);
        end

        function interfaces=getCodeDescriptorDataInterfaces(this,type)
            interfaces=this.CodeDescriptor.getDataInterfaces(type);
        end

        function updateM3iModelFromCalPrm(this,m3iType,m3iData,dataTypeObj,codeType,calPrmGraphicalName)
            calPrmWksObj=autosar.mm.util.getValueFromGlobalScope(this.ModelName,calPrmGraphicalName);
            if isempty(m3iType)

                slAppTypeAttributes=this.getSLAppTypeAttributes(calPrmWksObj);
                m3iType=this.TypeBuilder.createOrUpdateM3IType(m3iData.Type,dataTypeObj,codeType,slAppTypeAttributes);
            end
            m3iData.Type=m3iType;

            this.setSLObjDescriptionForM3iData(calPrmWksObj,m3iData);
        end

        function m3iInterface=findOrCreateInterface(this,m3iPkg,name,metaClsStr)

            interface=autosar.mm.Model.findChildByNameAndTypeName(m3iPkg,name,...
            metaClsStr);

            if~interface.isvalid()


                m3iMetaClass=feval(sprintf('%s.MetaClass',metaClsStr));
                arPkg=m3iPkg.rootModel.RootPackage.at(1);
                assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
                seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,name,m3iMetaClass);
                if(seq.size==0)

                    m3iInterface=this.M3IElementFactory.createPackageableElement(m3iPkg,m3iMetaClass);
                    m3iInterface.Name=name;
                elseif(seq.size==1)

                    m3iInterface=seq.at(1);
                else
                    assert(false,['Multiple interfaces with name: ',name]);
                end
            else
                m3iInterface=interface;
            end
        end

        function[preBuildAnnotations,postBuildAnnotations]=getModelRefVariantAnnotations(this)









            mdlRefs=find_mdlrefs(this.ModelName,...
            'MatchFilter',@Simulink.match.codeCompileVariants);
            buildDir=RTW.getBuildDir(this.ModelName);
            mrefsDir=fullfile(buildDir.CodeGenFolder,buildDir.ModelRefRelativeRootTgtDir);
            preBuildAnnotations=[];
            postBuildAnnotations=[];
            for idx=1:length(mdlRefs)
                mrefName=mdlRefs{idx};
                codeInfoFile=fullfile(mrefsDir,mrefName,[mrefName,'_mr_codeInfo.mat']);
                if~exist(codeInfoFile,'file')
                    continue
                end
                mdlrefCodeDesc=this.CodeDescriptorCache.getRefModelCodeDescriptor(mrefName,this.CodeDescriptor);
                preBuildAnnotations=[preBuildAnnotations,mdlrefCodeDesc.getFullComponentInterface.VariantAnnotations.toArray];%#ok<AGROW>
                postBuildAnnotations=[postBuildAnnotations,mdlrefCodeDesc.getFullComponentInterface.PostBuildVariantAnnotations.toArray];%#ok<AGROW>
            end
        end

    end

    methods(Static,Access=public)
        function isParam=isValidParamForSubModel(param)



            isParam=false;

            implementation=param.Implementation;
            if~isempty(implementation)&&isa(implementation,'coder.descriptor.AutosarCalibration')...
                &&strcmp(implementation.DataAccessMode,'InternalCalPrm')&&strcmp(implementation.Shared,'false')
                isParam=true;
            end
        end

        function region=getAutosarSubModelParameterImplementation(param)

            region=param.Implementation;
            if~isempty(region.BaseRegion)&&isa(region.BaseRegion,'coder.descriptor.StructExpression')
                region=region.BaseRegion;
            end

            if isa(region.BaseRegion,'coder.descriptor.Variable')
                region=region.BaseRegion;
            end
        end

        function isPromotedPIMParam=isPromotedPerInstanceParameterFromSubmodel(codeDescParam,subModelPerInstanceParamNames)


            paramName=codeDescParam.GraphicalName;
            if startsWith(paramName,'InstParameterArgument:')


                nameEndingChecker=@(subModelParamName)endsWith(paramName,strcat(':',subModelParamName));
                isPromotedPIMParam=any(cellfun(nameEndingChecker,subModelPerInstanceParamNames));
            else
                isPromotedPIMParam=false;
            end
        end





        function[runnableName,slRunnablePath]=getRunnableNameFromSymbol(modelName,m3iBehavior,symbol)
            mmgr=get_param(modelName,'MappingManager');
            mapping=mmgr.getActiveMappingFor('AutosarTarget');
            runnableName='';
            slRunnablePath='';

            if isobject(mapping)&&isa(mapping,'Simulink.AutosarTarget.ModelMapping')
                m3iRunnables=autosar.mm.Model.findObjectByMetaClass(m3iBehavior,...
                Simulink.metamodel.arplatform.behavior.Runnable.MetaClass,false,false);
                for runIdx=1:m3iRunnables.size
                    runnable=m3iRunnables.at(runIdx);
                    if strcmp(runnable.symbol,symbol)
                        runnableName=runnable.Name;
                        break;
                    elseif isempty(runnable.symbol)&&...
                        strcmp(runnable.Name,symbol)


                        runnableName=runnable.Name;
                        break;
                    end
                end
                assert(~isempty(runnableName),'Cannot find correct symbol in runnables');

                runnableBlockMapping=[mapping.ServerFunctions,mapping.FcnCallInports];
                for blkMapIdx=1:length(runnableBlockMapping)
                    if strcmp(runnableBlockMapping(blkMapIdx).MappedTo.Runnable,runnableName)
                        slRunnablePath=runnableBlockMapping(blkMapIdx).Block;
                        break;
                    end
                end
            else
                runnableName=symbol;
            end
        end


        function[InterfacePath,PortName,OperationName]=findClientBlockPortOpNames(serverCallPoint)
            if~isempty(serverCallPoint.SID)
                InterfacePath=get_param(serverCallPoint.SID,'interfacePath');
            else

                InterfacePath='';
            end
            PortName=serverCallPoint.PortName;
            OperationName=serverCallPoint.Prototype.Name;
        end

        function[elementPath,elementName]=getNodePathAndName(qualifiedName)


            [elementPath,elementName]=autosar.utils.splitQualifiedName(qualifiedName);
        end

        function sortedRTWDataInterface=sortByGraphicalName(RTWDataInterface)


            RTWDataInterface=RTWDataInterface.toArray;
            GraphicalNames=cell(1,length(RTWDataInterface));
            for i=1:length(RTWDataInterface)
                GraphicalNames{i}=RTWDataInterface(i).GraphicalName;
            end

            [~,sortIdx]=sort(GraphicalNames);
            sortedRTWDataInterface=RTWDataInterface(sortIdx);
        end

        function child=findOrCreateInSequenceNamedItem(parent,seq,name,...
            className)
            child=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(parent,seq,...
            name,className);
        end

        function child=findInSequenceNamedItem(parent,seq,name,...
            className)
            child=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(parent,seq,...
            name,className);
        end

        function child=createInSequenceNamedItem(parent,seq,name,...
            className)
            child=Simulink.metamodel.arplatform.ModelFinder.createNamedItemInSequence(parent,seq,...
            name,className);
        end

        function findAndDestroyPackage(parent,pkgPath)
            [names,pkgParent]=...
            autosar.mm.Model.splitObjectPath(parent,pkgPath,true);

            pkgCurr=pkgParent;
            for ii=1:numel(names)

                pkgChild=autosar.mm.Model.findChildByNameAndTypeName(...
                pkgCurr,names{ii},...
                'Simulink.metamodel.arplatform.common.Package');

                if~pkgChild.isvalid()
                    return;
                end

                pkgCurr=pkgChild;
            end
            if(pkgCurr~=pkgParent)
                autosar.mm.sl2mm.ModelBuilder.removeEmptyPackages(pkgCurr);
            end
        end

        function removeEmptyPackages(m3iPackage)
            if m3iPackage.isvalid&&(m3iPackage.packagedElement.size==0)
                m3iParentPackage=m3iPackage.containerM3I();
                m3iPackage.destroy();
                if isa(m3iParentPackage,...
                    'Simulink.metamodel.arplatform.common.Package')
                    autosar.mm.sl2mm.ModelBuilder.removeEmptyPackages(m3iParentPackage);
                end
            end
        end


        function isPIM_CSC=i_get_isCompatibleCSCForDSM(modelName,datastore)
            isPIM_CSC=false;
            implementation=datastore.Implementation;
            if isa(implementation,'coder.descriptor.AutosarMemoryExpression')
                dataObj=autosar.mm.sl2mm.ModelBuilder.getDataObjectForDSMorSynthesizedDS(modelName,datastore);

                isPIM_CSC1=isa(dataObj,'AUTOSAR.Signal')&&...
                dataObj.getIsAutosarPerInstanceMemory();
                isPIM_CSC2=isa(dataObj,'Simulink.Signal')&&...
                strcmp(dataObj.CoderInfo.StorageClass,'Custom')&&...
                isa(dataObj.CoderInfo.CustomAttributes,'SimulinkCSC.AttribClass_AUTOSAR_PerInstanceMemory');
                isPIM_CSC=isPIM_CSC1||isPIM_CSC2;
            end
        end

        function isMapped=isDSMMappedToPIMOrStaticMemory(modelName,datastore)
            isMapped=false;

            if isempty(datastore.SID)
                return
            end

            mmgr=get_param(modelName,'MappingManager');
            mapping=mmgr.getActiveMappingFor('AutosarTarget');


            lastToken=extractAfter(datastore.SID,':');
            if isequal(lastToken,'0')

                mappingElement=mapping.SynthesizedDataStores.findobj('Name',datastore.GraphicalName);
            else

                sid=datastore.SID;
                blkH=-1;

                if strcmp(get_param(sid,'BlockType'),'DataStoreMemory')
                    blkH=get_param(sid,'handle');
                end

                if blkH<0
                    return;
                end
                mappingElement=mapping.DataStores.findobj('OwnerBlockHandle',blkH);
            end

            if isempty(mappingElement)
                return
            end

            if strcmp(mappingElement.MappedTo.ArDataRole,'ArTypedPerInstanceMemory')||...
                strcmp(mappingElement.MappedTo.ArDataRole,'StaticMemory')
                isMapped=true;
            end
        end

        function dataObj=getDataObjectForDSM(modelName,datastore)
            graphicalName=datastore.GraphicalName;
            sid=datastore.SID;

            dataObj=[];
            try
                if~isempty(sid)&&...
                    strcmp(get_param(sid,'BlockType'),'DataStoreMemory')
                    dataObj=get_param(sid,'StateSignalObject');
                end

                isResolved=true;
                if~isempty(sid)
                    isResolved=strcmp(get_param(sid,'StateMustResolveToSignalObject'),'on');
                end

                if isempty(dataObj)&&isResolved



                    [~,dataObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,graphicalName);
                end
            catch %#ok<CTCH>
            end
        end

        function dataObj=getDataObjectForSynthesizedDataStore(modelName,datastore)
            graphicalName=datastore.GraphicalName;
            sid=datastore.SID;

            dataObj=[];
            try
                if~isempty(sid)

                    lastToken=extractAfter(sid,':');
                    if isequal(lastToken,'0')
                        [~,dataObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,graphicalName);
                    end
                end
            catch %#ok<CTCH>
            end
        end

        function dataObj=getDataObjectForDSMorSynthesizedDS(modelName,datastore)
            dataObj=autosar.mm.sl2mm.ModelBuilder.getDataObjectForDSM(modelName,datastore);
            if isempty(dataObj)
                dataObj=autosar.mm.sl2mm.ModelBuilder.getDataObjectForSynthesizedDataStore(modelName,datastore);
            end
        end

        function[m3iPort,m3iInterface,m3iModeGroup]=findModeGroup(...
            m3iSWC,portName,modeGroupName)
            arPkg="Simulink.metamodel.arplatform";
            msifCls=arPkg+'.interface.ModeSwitchInterface';
            dataCls=arPkg+'.interface.ModeDeclarationGroupElement';
            portClasses=[arPkg+".port.ModeReceiverPort",...
            arPkg+".port.DataReceiverPort",...
            arPkg+".port.ModeSenderPort",...
            arPkg+".port.DataSenderPort"];
            for portClass=portClasses
                m3iPort=autosar.mm.Model.findChildByNameAndTypeName(m3iSWC,portName,portClass.char);
                if~isempty(m3iPort)
                    break
                end
            end

            assert(m3iPort.isvalid()&&m3iPort.Interface.isvalid());
            m3iInterface=m3iPort.Interface;
            if isa(m3iInterface,msifCls.char)
                m3iModeGroup=m3iInterface.ModeGroup;
            else
                m3iModeGroup=autosar.mm.Model.findChildByNameAndTypeName(...
                m3iInterface,modeGroupName,dataCls.char);
            end
        end


        function[modeNames,modeValues,defaultModeIndex,storageType,dataSize,isSigned]=getMdgDataFromEnum(...
            modelName,enumName)

            enumName=autosar.mm.util.getBaseEnumName(modelName,enumName);
            [x,modeNames]=enumeration(enumName);
            defaultModeIndex=any(Simulink.data.getEnumTypeInfo(enumName,'DefaultValue')==x);
            modeValues=[];
            dataSize=0;
            isSigned=false;
            storageType=Simulink.data.getEnumTypeInfo(enumName,'StorageType');
            if~strcmp(storageType,'int')
                mdgSupportedStorageTypes={'uint8','uint16','int8','int16','int32'};
            else
                mdgSupportedStorageTypes={'int32'};
            end
            for ii=1:length(mdgSupportedStorageTypes)
                if isa(x,mdgSupportedStorageTypes{ii})
                    expression=mdgSupportedStorageTypes{ii};
                    expression=[expression,'(x)'];%#ok<AGROW>
                    modeValues=eval(expression);
                    storageType=mdgSupportedStorageTypes{ii};
                    break;
                end
            end
            if isempty(storageType)
                return;
            end
            dataSizeStr='';
            if any(strcmp(storageType(end-1),{'1','2','3','4','5','6','7','8','9'}))
                dataSizeStr=storageType(end-1);
            end
            if any(strcmp(storageType(end),{'1','2','3','4','5','6','7','8','9'}))
                dataSizeStr=[dataSizeStr,storageType(end)];
            end
            if storageType(1)=='u'
                isSigned=false;
            else
                isSigned=true;
            end
            dataSize=str2num(dataSizeStr);%#ok<ST2NM>
        end

        function dtName=createAppDataTypeNameDualScaled(name,maxShortNameLength)
            dtName=arxml.arxml_private('p_create_aridentifier',...
            [name,'_DualScaled'],maxShortNameLength);
        end

        function yesNo=isAutosarMemorySection(msDefn)
            msdefn=autosar.mm.sl2mm.ModelBuilder.resolveMemorySectionThruRef(msDefn);
            yesNo=isa(msdefn,'Simulink.MemorySectionDefn')&&...
            strcmp(msdefn.OwnerPackage,'AUTOSAR')&&...
            (strcmp(msdefn.Name,'SwAddrMethod')||...
            strcmp(msdefn.Name,'SwAddrMethod_Const')||...
            strcmp(msdefn.Name,'SwAddrMethod_Const_Volatile')||...
            strcmp(msdefn.Name,'SwAddrMethod_Volatile'));
        end

        function slAppTypeAttributes=getSLAppTypeAttributes(dataObj)
            if isempty(dataObj)
                slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;
            else
                slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributesGetter.fromDataObj(dataObj);
            end
        end

        function setSLObjDescriptionForM3iData(dataObj,m3iData)
            if~isempty(dataObj)
                slDesc=autosar.mm.sl2mm.ModelBuilder.getDescriptionFromDataObj(dataObj);
                autosar.mm.sl2mm.ModelBuilder.createOrUpdateM3IDescription(...
                m3iData,m3iData.rootModel,slDesc);
            end
        end

        function updateCodeDescriptorVariants(codeInfoVariants,m3iElement,ciVariantInfo,ciName)



























            assert(isa(m3iElement,'Simulink.metamodel.arplatform.common.Identifiable'),...
            'Element must be identifiable to have a variationPoint');

            uri=m3iElement.uri;

            expression='true';
            if~isempty(ciVariantInfo)
                expression=ciVariantInfo.CodeVariantCondition;
            end

            postBuildExpression='true';
            if~isempty(ciVariantInfo)
                postBuildExpression=ciVariantInfo.StartupVariantCCondition;
            end

            if~codeInfoVariants.isKey(uri)
                codeInfoVariants(uri)=struct(...
                'M3IElement',m3iElement,...
                'Condition',expression,...
                'PostBuildCondition',postBuildExpression,...
                'BlockName',ciName);%#ok<NASGU>
            else
                portVP=codeInfoVariants(uri);
                portVP.Condition=sprintf('(%s) || (%s)',...
                portVP.Condition,expression);



                portVP.PostBuildCondition=sprintf('(%s) || (%s)',...
                portVP.PostBuildCondition,postBuildExpression);
            end
        end

        function[m3iSwCalAccessKind,displayFormat]=getSwCalibrationAccessForDataObject(modelName,dataInter)
            import Simulink.metamodel.foundation.SwCalibrationAccessKind;
            dataObjGraphicalName=dataInter.GraphicalName;

            m3iSwCalAccessKind=SwCalibrationAccessKind.ReadOnly;
            displayFormat='';
            if isa(dataInter,'coder.descriptor.ReadWriteDataInterface')
                dataObj=autosar.mm.sl2mm.ModelBuilder.getDataObjectForDSMorSynthesizedDS(modelName,dataInter);
            else
                dataObj=autosar.mm.util.getValueFromGlobalScope(modelName,dataObjGraphicalName);
            end
            if isa(dataObj,'AUTOSAR.Parameter')||isa(dataObj,'AUTOSAR.Signal')
                m3iSwCalAccessKind=autosar.mm.sl2mm.ModelBuilder.getM3ISwCalibrationAccessEnumFromString(...
                dataObj.SwCalibrationAccess);
                displayFormat=dataObj.DisplayFormat;
            end
        end

        function createOrUpdateM3ILongName(m3iModel,m3iDataObj,longNameValue)

            import autosar.mm.sl2mm.ModelBuilder

            [isValid,~,longNameValue,errorId]=...
            autosar.validation.AutosarUtils.validateLongNameValue(longNameValue);
            if isValid
                if isempty(m3iDataObj.longName)

                    m3iLongName=...
                    Simulink.metamodel.arplatform.documentation.MultiLanguageLongName(m3iModel);
                    m3iL4=ModelBuilder.createInSequenceNamedItem(...
                    m3iLongName,m3iLongName.L4,'longName',...
                    'Simulink.metamodel.arplatform.documentation.LLongName');
                    m3iL4.language='FOR-ALL';
                    m3iL4.body=longNameValue;
                    m3iDataObj.longName=m3iLongName;
                else
                    if isempty(longNameValue)

                        m3iDataObj.longName.destroy();
                    else

                        m3iLLongName=m3iDataObj.longName.L4.at(1);
                        m3iLLongName.body=longNameValue;
                    end
                end
            else
                DAStudio.error(errorId,longNameValue);
            end
        end

        function destroyDTMappingSetsWithInvalidRefs(m3iModel)










            dtMapsets=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.common.DataTypeMappingSet.MetaClass);
            for mIdx=1:dtMapsets.size()
                dtMapSet=dtMapsets.at(mIdx);


                dtMapSeq=dtMapSet.dataTypeMap;
                indicesToRemove=[];
                for idx=1:dtMapSeq.size
                    dtMapVec=dtMapSeq.at(idx);
                    if~dtMapVec.ApplicationType.isvalid()||...
                        ~dtMapVec.ImplementationType.isvalid()
                        indicesToRemove(end+1)=idx;%#ok<AGROW>
                    end
                end

                indicesToRemove=sort(indicesToRemove,'descend');
                for idxRem=1:length(indicesToRemove)
                    dtMapSeq.at(indicesToRemove(idxRem)).destroy();
                end


                modeReqSeq=dtMapSet.ModeRequestTypeMap;
                indicesToRemove=[];
                for idx=1:modeReqSeq.size
                    modeReqVec=modeReqSeq.at(idx);
                    if~modeReqVec.ModeGroupType.isvalid()||...
                        ~modeReqVec.ImplementationType.isvalid()
                        indicesToRemove(end+1)=idx;%#ok<AGROW>
                    end
                end

                indicesToRemove=sort(indicesToRemove,'descend');
                for idxRem=1:length(indicesToRemove)
                    modeReqSeq.at(indicesToRemove(idxRem)).destroy();
                end
            end
        end
    end

    methods(Static,Access=private)

        function isService=convertBasicOrAppSoftwareStrToIsService(str)



            switch(lower(str))
            case{'application software'}
                isService=false;
            case{'basic software'}
                isService=true;
            otherwise
                DAStudio.error('RTW:autosar:unknownBasicOrApplicationSoftwareStr',str);
            end
        end

        function destroyIncompatibleSpecification(m3iData)
            if m3iData.InitValue.isvalid()
                if isa(m3iData.InitValue,'Simulink.metamodel.types.MatrixValueSpecification')...
                    &&~isa(m3iData.Type,'Simulink.metamodel.types.Matrix')
                    m3iData.InitValue.destroy();
                elseif isa(m3iData.InitValue,'Simulink.metamodel.types.StructureValueSpecification')...
                    &&~isa(m3iData.Type,'Simulink.metamodel.types.Structure')
                    m3iData.InitValue.destroy();
                end
            end
            if m3iData.DefaultValue.isvalid()
                if isa(m3iData.DefaultValue,'Simulink.metamodel.types.MatrixValueSpecification')...
                    &&~isa(m3iData.Type,'Simulink.metamodel.types.Matrix')
                    m3iData.DefaultValue.destroy();
                elseif isa(m3iData.DefaultValue,'Simulink.metamodel.types.StructureValueSpecification')...
                    &&~isa(m3iData.Type,'Simulink.metamodel.types.Structure')
                    m3iData.DefaultValue.destroy();
                end
            end
        end

        function destroyLegacyClassicSwBaseTypes(m3iModel)








            swBaseTypeSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.types.SwBaseType.MetaClass);
            platformTypes=autosarcore.mm.sl2mm.SwBaseTypeBuilder.getAdaptivePlatformTypes();

            for typeIdx=1:swBaseTypeSeq.size()
                curSwBaseType=swBaseTypeSeq.at(typeIdx);
                if~any(strcmp(curSwBaseType.Name,platformTypes))
                    curSwBaseType.destroy();
                end
            end
        end

        function str=cell2str(cellArray)


            str='{';
            sep='';
            for ii=1:length(cellArray)
                str=sprintf('%s%s''%s''',str,sep,cellArray{ii});
                sep=', ';
            end
            str=sprintf('%s}',str);
        end

        function msDefn=resolveMemorySectionThruRef(msDefn)
            if isa(msDefn,'Simulink.MemorySectionRefDefn')

                msDefn=processcsc('GetMemorySectionDefn',msDefn.RefPackageName,...
                msDefn.RefDefnName);

                if isa(msDefn,'Simulink.MemorySectionRefDefn')
                    msDefn=autosar.mm.sl2mm.ModelBuilder.resolveMemorySectionThruRef(msDefn);
                end
            end
        end

        function swDataDefProps=getAutosarSwDataDefProps(dataObj)



            SwCalAccessKind='';
            SwAddrMethodName='';
            DisplayFormat='';
            if isa(dataObj,'AUTOSAR.Parameter')||...
                isa(dataObj,'AUTOSAR.Signal')||...
                isa(dataObj,'AUTOSAR.DualScaledParameter')
                SwCalAccessKind=dataObj.SwCalibrationAccess;
                DisplayFormat=dataObj.DisplayFormat;
            end


            if isa(dataObj,'Simulink.Parameter')||...
                isa(dataObj,'Simulink.Signal')...
                &&strcmp(dataObj.CoderInfo.StorageClass,'Custom')
                cscPackageName=dataObj.CSCPackageName;
                cscDefn=processcsc('GetCSCDefn',cscPackageName,dataObj.CoderInfo.CustomStorageClass);
                if cscDefn.IsMemorySectionInstanceSpecific
                    msDefn=processcsc('GetMemorySectionDefn',cscDefn.OwnerPackage,...
                    dataObj.CoderInfo.CustomAttributes.MemorySection);
                else
                    msDefn=processcsc('GetMemorySectionDefn',...
                    cscDefn.OwnerPackage,...
                    cscDefn.MemorySection);
                end
                if autosar.mm.sl2mm.ModelBuilder.isAutosarMemorySection(msDefn)
                    SwAddrMethodName=msDefn.Name;
                end
            end
            swDataDefProps.SwCalAccessKind=SwCalAccessKind;
            swDataDefProps.SwAddrMethodName=SwAddrMethodName;
            swDataDefProps.DisplayFormat=DisplayFormat;
        end
        function[m3iSwCalAccessKind,displayFormat]=getCalibrationAttributesForDataObject(modelName,dataInter)
            import Simulink.metamodel.foundation.SwCalibrationAccessKind;
            dataObjGraphicalName=dataInter.GraphicalName;


            m3iSwCalAccessKind=SwCalibrationAccessKind.ReadOnly;
            displayFormat='';
            dataObj=autosar.mm.util.getValueFromGlobalScope(modelName,dataObjGraphicalName);
            if isa(dataObj,'AUTOSAR.Parameter')
                m3iSwCalAccessKind=autosar.mm.sl2mm.ModelBuilder.getM3ISwCalibrationAccessEnumFromString(...
                dataObj.SwCalibrationAccess);
                displayFormat=dataObj.DisplayFormat;
            end
        end
        function m3iSwCalAccessKind=getM3ISwCalibrationAccessEnumFromString(swCalAccessStr)
            import Simulink.metamodel.foundation.SwCalibrationAccessKind;
            switch(swCalAccessStr)
            case 'NotAccessible'
                m3iSwCalAccessKind=SwCalibrationAccessKind.NotAccessible;
            case 'ReadOnly'
                m3iSwCalAccessKind=SwCalibrationAccessKind.ReadOnly;
            case 'ReadWrite'
                m3iSwCalAccessKind=SwCalibrationAccessKind.ReadWrite;
            otherwise
                error('Should not be here');
            end
        end

        function m3iSwCalAccessKind=getM3IParameterKindEnumFromString(paramKind)
            import Simulink.metamodel.arplatform.behavior.ParameterKind;
            switch(paramKind)
            case 'SharedParameter'
                m3iSwCalAccessKind=ParameterKind.Shared;
            case 'PerInstanceParameter'
                m3iSwCalAccessKind=ParameterKind.Pim;
            case 'ConstantMemory'
                m3iSwCalAccessKind=ParameterKind.Const;
            otherwise
                m3iSwCalAccessKind=ParameterKind.Other;
            end
        end



        function isMapped=isDataElementMapped(modelMapping,portName,dataElementName,isSender,isAdaptiveAutosar)
            isMapped=false;

            if isSender
                portMapping=modelMapping.Outports;
            else
                portMapping=modelMapping.Inports;
            end
            for idx=1:length(portMapping)
                mapInfo=portMapping(idx).MappedTo;
                if isAdaptiveAutosar
                    mapInfoE=mapInfo.Event;
                else
                    mapInfoE=mapInfo.Element;
                end
                if strcmp(mapInfo.Port,portName)&&...
                    strcmp(mapInfoE,dataElementName)
                    isMapped=true;
                    return;
                end
            end
        end


        function[m3iComSpec,m3iInfo]=findPortComSpecAndInfo(m3iPort,dataElementName,infoMetaClass)
            if(infoMetaClass==Simulink.metamodel.arplatform.port.NvDataSenderPortInfo.MetaClass)||...
                (infoMetaClass==Simulink.metamodel.arplatform.port.NvDataReceiverPortInfo.MetaClass)
                infoPropName='Info';
                comSpecPropName='ComSpec';
            else
                infoPropName='info';
                comSpecPropName='comSpec';
            end

            m3iComSpec=M3I.ClassObject;
            m3iInfo=M3I.ClassObject;
            for infoIdx=1:m3iPort.(infoPropName).size()
                portInfo=m3iPort.(infoPropName).at(infoIdx);
                if portInfo.MetaClass==infoMetaClass&&...
                    portInfo.DataElements.isvalid()
                    if strcmp(dataElementName,portInfo.DataElements.Name)
                        m3iInfo=portInfo;
                        m3iComSpec=m3iInfo.(comSpecPropName);
                        break
                    end
                end
            end
        end

        function slDesc=getDescriptionFromDataObj(dataObj)
            if isa(dataObj,'Simulink.LookupTable')
                slDesc=dataObj.Table.Description;
            elseif isa(dataObj,'Simulink.Breakpoint')
                slDesc=dataObj.Breakpoints.Description;
            else
                slDesc=dataObj.Description;
            end
        end

        function createOrUpdateM3IDescription(m3iData,m3iModel,slDesc)
            oldM3iDesc=m3iData.desc;
            m3iDesc=autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescription(m3iModel,...
            oldM3iDesc,slDesc);
            if~isempty(m3iDesc)
                m3iData.desc=m3iDesc;
            end
        end



        function[slAppTypeAttributes,slDesc]=getArgBlockProperties(serverFcnBlock,arg)
            if strcmp(arg.IOType,'INPUT')||strcmp(arg.IOType,'INPUT_OUTPUT')


                slArgBlock=find_system(serverFcnBlock,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','BlockType','ArgIn','ArgumentName',arg.Name);
            elseif strcmp(arg.IOType,'OUTPUT')


                slArgBlock=find_system(serverFcnBlock,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','BlockType','ArgOut','ArgumentName',arg.Name);
            else
                assert(false,'Invalid arg type');
            end
            slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributesGetter.fromBlock(slArgBlock{1});
            slDesc=get_param(slArgBlock{1},'Description');
        end




        function dataTypeObj=getArgDataTypeObj(arg)
            dataTypeObj=arg.Type;

            if dataTypeObj.isPointer

                if strcmp(arg.IOType,'INPUT')
                    if~dataTypeObj.BaseType.isScalar

                        dataTypeObj=dataTypeObj.BaseType;
                    end
                elseif strcmp(arg.IOType,'INPUT_OUTPUT')||strcmp(arg.IOType,'OUTPUT')
                    if~dataTypeObj.BaseType.isVoid

                        dataTypeObj=dataTypeObj.BaseType;
                    end
                else
                    assert(false,'Invalid arg type');
                end
            end
        end


        function setInvalidValueInType(m3iType,idLength,symbolicDefinitions)



            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                autosar.mm.sl2mm.ModelBuilder.setInvalidValueInType(...
                m3iType.BaseType,idLength,symbolicDefinitions);
            elseif isa(m3iType,'Simulink.metamodel.types.Structure')
                busElements=m3iType.Elements;
                for i=1:m3iType.Elements.size()
                    currElement=busElements.at(i);
                    elemType=currElement.ReferencedType;
                    autosar.mm.sl2mm.ModelBuilder.setInvalidValueInType(...
                    elemType,idLength,symbolicDefinitions);
                end
            else
                if isempty(m3iType.InvalidValue)


                    invalidValueName=autosar.mm.sl2mm.utils.invalid_value_name_for_datatype(...
                    m3iType.Name,idLength);

                    invalidValue=autosar.mm.sl2mm.ConstantBuilder.updateOrCreateValueSpecification(...
                    m3iType.rootModel,[],[],m3iType,...
                    idLength,invalidValueName,...
                    [],symbolicDefinitions);
                    m3iType.InvalidValue=invalidValue;
                end
            end
        end

        function queuedDataInterfaces=getQueuedDataInterfaces(dataInterfaces)
            queuedDataInterfaces=[];
            for i=1:numel(dataInterfaces)
                if(dataInterfaces(i).isMessageDataInterface&&dataInterfaces(i).isQueued)
                    queuedDataInterfaces=[queuedDataInterfaces,dataInterfaces(i)];%#ok
                end
            end
        end

        function[m3iComSpecReq,m3iInfoReq,m3iComSpecProv,m3iInfoProv]=...
            findOrCreatePersistencyPortComSpec(m3iPort,dataElementName)



            infoMetaClassReq=Simulink.metamodel.arplatform.port.PersistencyReceiverPortInfo.MetaClass;
            comSpecMetaClassReq=Simulink.metamodel.arplatform.port.PersistencyReceiverPortComSpec.MetaClass;
            infoMetaClassProv=Simulink.metamodel.arplatform.port.PersistencyProvidedPortInfo.MetaClass;
            comSpecMetaClassProv=Simulink.metamodel.arplatform.port.PersistencyProvidedPortComSpec.MetaClass;


            [m3iComSpecReq,m3iInfoReq]=autosar.mm.sl2mm.ModelBuilder.findPortComSpecAndInfo(m3iPort,dataElementName,infoMetaClassReq);
            if m3iInfoReq.MetaClass~=infoMetaClassReq
                if m3iInfoReq.isvalid()
                    m3iInfoReq.destroy();
                end
                m3iInfoReq=feval(infoMetaClassReq.qualifiedName,m3iPort.rootModel);
                m3iPort.info.append(m3iInfoReq);
            end

            if m3iComSpecReq.MetaClass~=comSpecMetaClassReq
                if m3iComSpecReq.isvalid()
                    m3iComSpecReq.destroy();
                end
                m3iComSpecReq=feval(comSpecMetaClassReq.qualifiedName,m3iPort.rootModel);
                m3iInfoReq.comSpec=m3iComSpecReq;
            end


            [m3iComSpecProv,m3iInfoProv]=autosar.mm.sl2mm.ModelBuilder.findPortComSpecAndInfo(m3iPort,dataElementName,infoMetaClassProv);
            if m3iInfoProv.MetaClass~=infoMetaClassProv
                if m3iInfoProv.isvalid()
                    m3iInfoProv.destroy();
                end
                m3iInfoProv=feval(infoMetaClassProv.qualifiedName,m3iPort.rootModel);
                m3iPort.info.append(m3iInfoProv);
            end

            if m3iComSpecProv.MetaClass~=comSpecMetaClassProv
                if m3iComSpecProv.isvalid()
                    m3iComSpecProv.destroy();
                end
                m3iComSpecProv=feval(comSpecMetaClassProv.qualifiedName,m3iPort.rootModel);
                m3iInfoProv.comSpec=m3iComSpecProv;
            end
        end
        function shouldSkip=shouldSkipSubmodelParameter(paramMap,path,implementation,name)
            shouldSkip=false;
            if isempty(path)
                shouldSkip=true;
            end
            if paramMap.isKey(name)
                shouldSkip=true;
            end
            if isa(implementation,'coder.descriptor.AutosarCalibration')




                shouldSkip=true;
            end
        end

        function argumentName=escapeArgumentPrefix(prefixedArgName)



            argumentName=regexprep(prefixedArgName,'^(rtu_|rty_|rtuy_)','');
        end
    end
end















