classdef TypeBuilder<handle





    properties(Access=public)
        M3iBuiltTypeNames;
ApplicationTypeMapper
    end
    properties(Access=private)
m3iModel
m3iBehavior
m3iDataTypePkg
m3iAppDataTypePkg
m3iSwBaseTypePkg
MaxShortNameLength
ArrayLayout
AppTypeChecker
NeedToCreateAppType
msgStream
CompuMethodBuilder
DataConstrBuilder
LookupTableBuilder
SwBaseTypeBuilder
ModelName
MappedM3IComponent
SlType2RefImpTypeMap
SlType2RefAppTypeMap
LiteralPrefixHelper
ApplicationTypeTracker
IsAdaptive
        SwRecordLayoutBuilder autosar.mm.sl2mm.SwRecordLayoutBuilder;
        PlatformTypesDecorator autosar.mm.sl2mm.PlatformTypesDecorator;


        ArchitectureDictionaryAPI Simulink.interface.Dictionary
        ARClassicPlatformMappingSyncer autosar.dictionary.internal.ARClassicPlatformMappingSyncer
    end

    methods(Access=public)
        function this=TypeBuilder(m3iModel,m3iBehavior,maxShortNameLength,...
            modelName,~,~,...
            applicationTypeTracker)

            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.mm.util.ExternalToolInfoAdapter;

            this.m3iModel=m3iModel;
            this.m3iBehavior=m3iBehavior;
            arRoot=this.m3iModel.RootPackage.front;
            this.m3iDataTypePkg=...
            autosar.mm.Model.getOrAddPackage(m3iModel,arRoot.DataTypePackage);

            swBaseTypePkg=XmlOptionsAdapter.get(arRoot,'SwBaseTypePackage');
            if isempty(swBaseTypePkg)
                swBaseTypePkg=[arRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.SwBaseTypes];
            end
            this.m3iSwBaseTypePkg=autosar.mm.Model.getOrAddARPackage(m3iModel,swBaseTypePkg);

            this.MaxShortNameLength=maxShortNameLength;
            this.ModelName=modelName;
            this.MappedM3IComponent=m3iBehavior.containerM3I;

            this.IsAdaptive=isa(this.MappedM3IComponent,...
            'Simulink.metamodel.arplatform.component.AdaptiveApplication');

            this.ArrayLayout=get_param(this.ModelName,'ArrayLayout');

            this.ApplicationTypeMapper=autosar.mm.sl2mm.ApplicationTypeMapper(modelName);

            this.SlType2RefImpTypeMap=containers.Map();
            this.SlType2RefAppTypeMap=containers.Map();
            this.CompuMethodBuilder=autosar.mm.sl2mm.CompuMethodBuilder(...
            m3iModel,maxShortNameLength);
            this.DataConstrBuilder=autosar.mm.sl2mm.DataConstrBuilder(...
            m3iModel,maxShortNameLength);
            this.LookupTableBuilder=autosar.mm.sl2mm.LookupTableBuilder(m3iModel,modelName);
            this.SwRecordLayoutBuilder=autosar.mm.sl2mm.SwRecordLayoutBuilder(...
            m3iModel,this.ModelName,this.ArrayLayout);
            this.SwBaseTypeBuilder=autosarcore.mm.sl2mm.SwBaseTypeBuilder(...
            this.m3iSwBaseTypePkg,this.IsAdaptive);

            applDataTypeNames=this.CompuMethodBuilder.getApplDataTypeNames();
            this.AppTypeChecker=autosar.mm.sl2mm.ApplicationTypeChecker(m3iBehavior,...
            [],applDataTypeNames);
            if autosar.mm.arxml.Exporter.hasExternalReference(arRoot)
                m3iSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
                Simulink.metamodel.foundation.ValueType.MetaClass,true,true);
                for ii=1:m3iSeq.size()
                    m3iSeqElem=m3iSeq.at(ii);
                    slDataTypes=ExternalToolInfoAdapter.get(m3iSeqElem,...
                    autosar.ui.metamodel.PackageString.SlDataTypes);
                    for jj=1:numel(slDataTypes)
                        if m3iSeqElem.IsApplication
                            this.SlType2RefAppTypeMap(slDataTypes{jj})=m3iSeqElem;


                            m3iImpSeqElem=this.ApplicationTypeMapper.mappedTo(m3iSeqElem);
                        else
                            m3iImpSeqElem=m3iSeqElem;
                        end
                        this.SlType2RefImpTypeMap(slDataTypes{jj})=m3iImpSeqElem;
                    end
                end
            end

            this.msgStream=autosar.mm.util.MessageStreamHandler.instance();

            this.ApplicationTypeTracker=applicationTypeTracker;
            this.LiteralPrefixHelper=autosar.mm.util.LiteralPrefixHelper(this.MappedM3IComponent);

            this.M3iBuiltTypeNames=autosar.mm.sl2mm.utils.M3iBuiltTypeNamesSet();

            if~this.IsAdaptive
                this.PlatformTypesDecorator=autosar.mm.sl2mm.PlatformTypesDecorator(this.ModelName,m3iModel,this);
            end



            [isLinkedToInterfaceDict,dictFileNames]=...
            autosar.dictionary.internal.DictionaryLinkUtils.isModelLinkedToAUTOSARInterfaceDictionary(modelName);
            if isLinkedToInterfaceDict
                assert(numel(dictFileNames)==1,'Expected model to be linked to a single interface dictionary.');
                dictFileName=dictFileNames{1};
                this.ArchitectureDictionaryAPI=Simulink.interface.dictionary.open(dictFileName);
                dictImpl=this.ArchitectureDictionaryAPI.DictImpl;
                this.ARClassicPlatformMappingSyncer=autosar.dictionary.internal.ARClassicPlatformMappingSyncer(dictImpl);
            end
        end

        function m3iCompuMethod=createRatFuncCompuMethod(this,name,obj,implType)
            m3iCompuMethod=this.CompuMethodBuilder.createRatFuncCompuMethod(name,obj,implType);
        end

        function[m3iType,isEquivalentToSLType]=createOrUpdateM3IType(this,oldM3IType,slDataTypeObj,codeType,slAppTypeAttributes)






            [isEquivalentToSLType,isAppType]=this.isTypeEquivalent(oldM3IType,slDataTypeObj,codeType,slAppTypeAttributes,'');

            if isEquivalentToSLType
                if~isAppType
                    this.SwBaseTypeBuilder.addSwBaseType(oldM3IType);
                end
                this.addCompuMethodAndDataConstr(oldM3IType,slAppTypeAttributes);
                m3iType=oldM3IType;
            else
                try
                    m3iType=this.findOrCreateType(slDataTypeObj,codeType,slAppTypeAttributes);
                catch ME





                    if strcmp(ME.identifier,'RTW:autosar:errorDuplicateTypeInPackage')
                        this.destroyObsoleteType(oldM3IType);


                        m3iType=this.findOrCreateType(slDataTypeObj,codeType,slAppTypeAttributes);
                    else
                        rethrow(ME)
                    end
                end
            end

            if~this.IsAdaptive

                if m3iType.IsApplication&&this.ApplicationTypeMapper.isMapped(m3iType)
                    m3iAppType=m3iType;
                    m3iImpType=this.findImpTypeForAppType(m3iAppType);
                else
                    m3iAppType='';
                    m3iImpType=m3iType;
                end
                this.PlatformTypesDecorator.updatePlatformType(slDataTypeObj,m3iAppType,m3iImpType);
            end

            this.M3iBuiltTypeNames.appendType(m3iType);
        end


        function[isEquivalent,isAppType]=isTypeEquivalent(this,m3iType,embeddedObj,codeType,...
            slAppTypeAttributes,typeName)
            isAppType=[];

            if(~isa(m3iType,'Simulink.metamodel.foundation.ValueType')||...
                ~m3iType.isvalid())
                isEquivalent=false;
                return
            end


            typeChecker=autosar.mm.sl2mm.TypeEquivalencyChecker(m3iType,...
            this.ModelName,this.ApplicationTypeTracker);


            isAppType=m3iType.IsApplication&&this.ApplicationTypeMapper.isMapped(m3iType);
            shouldBeAppType=this.AppTypeChecker.isAppType(embeddedObj,slAppTypeAttributes.IsValueType);
            isEquivalent=typeChecker.isEquivalent(embeddedObj,codeType,...
            slAppTypeAttributes,typeName,isAppType,shouldBeAppType);
            embeddedTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            if isEquivalent&&m3iType.IsApplication&&this.SlType2RefImpTypeMap.isKey(embeddedTypeName)
                m3iImpType=this.SlType2RefImpTypeMap(embeddedTypeName);
                this.NeedToCreateAppType=true;
                this.updateDataTypeMap(m3iType,m3iImpType);
            end
        end

        function addImplementationTypeReference(this,embeddedObj,m3iImpType,referencedTypeName,referencedTypeMetaclass)



            [referencedImplementationType,~]=this.findOrCreateM3IType(referencedTypeName,referencedTypeMetaclass,false,false);



            if isempty(referencedImplementationType.SwBaseType)
                referencedImplementationType.SwBaseType=m3iImpType.SwBaseType;


                this.m3iDataTypePkg.packagedElement.append(referencedImplementationType);
            end

            if embeddedObj.isNumeric
                autosar.mm.sl2mm.TypeBuilder.updateNumericType(referencedImplementationType,embeddedObj,false);
            end


            m3iImpType.Reference=referencedImplementationType;
        end

        function[m3iType,m3iImpType]=findOrCreateType(this,embeddedObj,codeType,slAppTypeAttributes)
            import autosar.mm.Model;
            import autosar.mm.util.XmlOptionsAdapter;
            isValueType=false;
            if numel(slAppTypeAttributes)==1
                isValueType=slAppTypeAttributes.IsValueType;
            end
            if this.AppTypeChecker.isAppType(embeddedObj,isValueType)
                this.NeedToCreateAppType=true;


                this.addDefaultApplicationDataTypePackage();
            else

                this.NeedToCreateAppType=false;
            end


            [m3iImpType,m3iAppType]=this.findOrCreateImpAndAppTypes(embeddedObj,codeType,slAppTypeAttributes);

            if this.NeedToCreateAppType
                m3iType=m3iAppType;
            else
                m3iType=m3iImpType;
            end

            this.M3iBuiltTypeNames.appendType(m3iType);

            if~isempty(this.ArchitectureDictionaryAPI)
                this.mapTypeInInterfaceDictionary(embeddedObj,m3iType);
            end
        end

        function m3iType=findOrCreateLookupTableType(this,codeDescParamInfo,swCalibrationAccess,displayFormat,swAddrMethod)
            if nargin<5
                swCalibrationAccess=[];
                displayFormat=[];
                swAddrMethod=[];
            end
            slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes([],[],[],[],...
            swCalibrationAccess,displayFormat,swAddrMethod,codeDescParamInfo.CodeDescObj,codeDescParamInfo.GraphicalName);
            m3iType=this.findOrCreateLookupTableTypeFromAppTypeAttributes(slAppTypeAttributes,...
            codeDescParamInfo.BreakpointNames);
            this.M3iBuiltTypeNames.appendType(m3iType);
        end

        function[m3iAppType,m3iImpType]=findOrCreateSharedAxisType(this,bpCodeDescObj,calPrmName)
            if isempty(bpCodeDescObj.Implementation)
                m3iAppType=[];
                m3iImpType=[];
                return;
            end
            if isempty(calPrmName)
                calPrmName=bpCodeDescObj.GraphicalName;
            end
            m3iAppType=this.LookupTableBuilder.findOrCreateSharedAxisType(...
            bpCodeDescObj,calPrmName);
            [min,max]=this.getLUTObjMinMaxValues(bpCodeDescObj);
            bpMin=autosar.mm.util.MinMaxHelper.getNumericValue(min,this.ModelName);
            bpMax=autosar.mm.util.MinMaxHelper.getNumericValue(max,this.ModelName);
            [baseTypeObj,bpArrayObj,codeType]=this.LookupTableBuilder.getBreakpointBaseTypeObj(bpCodeDescObj);
            this.findOrCreateLUTBaseType(m3iAppType.Axis,calPrmName,baseTypeObj,codeType,bpMin,bpMax);
            m3iAppType.ValueAxisDataType=this.findOrCreateAppTypeForAxisAttribute(baseTypeObj,codeType,min,max,bpCodeDescObj.Unit);
            m3iAppType.Axis.InputVariableType=m3iAppType.ValueAxisDataType;
            this.addM3iAxisTypeAttributesToM3iLUTBaseType(m3iAppType.ValueAxisDataType,m3iAppType.Axis.BaseType);
            [hasSymbolicDimensions,symbolicWidth]=autosar.mm.sl2mm.LookupTableBuilder.getSymbolicDimensionsForSharedAxis(bpArrayObj);
            if hasSymbolicDimensions
                m3iAppType.Axis.SymbolicDimensions.clear();
                this.addSymbolicDimensions(symbolicWidth,m3iAppType.Axis);
            end
            m3iImpType=this.findOrCreateImpTypeForLookupTableObj(bpCodeDescObj);
            m3iAppType.SwRecordLayout=this.SwRecordLayoutBuilder.buildM3iSwRecordLayout(bpCodeDescObj,m3iImpType);

            this.NeedToCreateAppType=true;
            this.updateDataTypeMap(m3iAppType,m3iImpType);
            this.M3iBuiltTypeNames.appendType(m3iImpType);
        end

        function m3iType=findOrCreateAppType(this,embeddedObj,slAppTypeAttributes)
            import autosar.mm.util.MinMaxHelper;
            this.NeedToCreateAppType=true;

            if isempty(this.m3iAppDataTypePkg)
                defaultApplPkg=autosar.mm.util.XmlOptionsDefaultPackages.ApplicationDataTypes;
                this.m3iAppDataTypePkg=autosar.mm.Model.getOrAddARPackage(this.m3iDataTypePkg,defaultApplPkg);
                defaultDataConstrPkg=autosar.mm.util.XmlOptionsDefaultPackages.DataConstrs;
                autosar.mm.Model.getOrAddARPackage(this.m3iAppDataTypePkg,defaultDataConstrPkg);
            end
            [appTypeName,impTypeName]=this.getAppAndImpTypeNames(embeddedObj);
            m3iImpType=this.findOrCreateM3iNumericType(embeddedObj,impTypeName,...
            this.m3iDataTypePkg,false,false);
            this.DataConstrBuilder.addDataConstr(m3iImpType,...
            false);
            autosar.mm.sl2mm.TypeBuilder.updateNumericType(m3iImpType,embeddedObj,false);
            this.SwBaseTypeBuilder.addSwBaseType(m3iImpType);
            if this.NeedToCreateAppType
                unmangledAppTypeName=appTypeName;
                if slAppTypeAttributes.hasAnyAttributesSet
                    appTypeName=slAppTypeAttributes.getAppTypeName(embeddedObj,this.MaxShortNameLength,slAppTypeAttributes.Min,slAppTypeAttributes.Max,this.ModelName);
                end
                m3iAppType=this.findOrCreateM3iNumericType(embeddedObj,...
                appTypeName,this.m3iAppDataTypePkg,true,false);
                if~strcmp(unmangledAppTypeName,appTypeName)
                    autosar.api.Utils.setUnmangledName(m3iAppType,unmangledAppTypeName);
                end
                this.DataConstrBuilder.addDataConstr(m3iAppType,...
                true);
                autosar.mm.sl2mm.TypeBuilder.updateNumericType(m3iAppType,...
                embeddedObj,true,slAppTypeAttributes.Min,slAppTypeAttributes.Max);
                this.updateDataTypeMap(m3iAppType,m3iImpType);
            end
            if this.NeedToCreateAppType
                m3iType=m3iAppType;
            else
                m3iType=m3iImpType;
            end
            this.M3iBuiltTypeNames.appendType(m3iType);
        end

        function[m3iMdg,m3iImpType]=findOrCreateModeAndImpTypes(this,embeddedObj,codeType)

            if embeddedObj.isMatrix&&...
                autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.isMatrixOfSizeOne(embeddedObj,codeType)


                embeddedObj=embeddedObj.BaseType;
            end
            assert(embeddedObj.isEnum);



            embeddedTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            m3iMdg=this.findOrCreateModeDeclarationGroup(this.m3iModel,...
            embeddedTypeName,embeddedObj.Strings.toArray,embeddedObj.Values.toArray,...
            embeddedObj.DefaultMember+1);
            this.M3iBuiltTypeNames.appendType(m3iMdg);



            this.ApplicationTypeTracker.addModeGroupName(m3iMdg.Name);

            m3iImpType=[];
            m3iImpType_prev=[];
            dataTypeMapSet=this.m3iBehavior.DataTypeMapping;
            for ii=1:dataTypeMapSet.size()
                modeRequestTypeMap=dataTypeMapSet.at(ii).ModeRequestTypeMap;
                for jj=1:modeRequestTypeMap.size()
                    if strcmp(modeRequestTypeMap.at(jj).ModeGroupType.Name,m3iMdg.Name)
                        m3iImpType_prev=modeRequestTypeMap.at(jj).ImplementationType;
                        break;
                    end
                end
            end
            embeddedTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            [~,~,~,storageType,storageTypeSize,storageTypeSign]...
            =autosar.mm.sl2mm.ModelBuilder.getMdgDataFromEnum(...
            this.ModelName,embeddedTypeName);
            mdgSupportedStorageARTypes={'UInt8','UInt16','SInt8','SInt16','SInt32'};
            platformImpTypes={'uint8','uint16','sint8','sint16','sint32'};
            mdgSupportedStorageTypes={'uint8','uint16','int8','int16','int32'};
            autosarTypeName=mdgSupportedStorageARTypes(...
            strcmp(mdgSupportedStorageTypes,storageType));
            platformTypeName=platformImpTypes(strcmp(mdgSupportedStorageTypes,storageType));
            if~isempty(m3iImpType_prev)
                if m3iImpType_prev.Length.value==storageTypeSize...
                    &&m3iImpType_prev.IsSigned==storageTypeSign...
                    &&(isa(m3iImpType_prev,'Simulink.metamodel.types.Integer')||...
                    (isa(m3iImpType_prev,'Simulink.metamodel.types.FixedPoint')...
                    &&m3iImpType_prev.slope==1&&m3iImpType_prev.Bias==0))
                    m3iImpType=m3iImpType_prev;
                end
            end


            [slDesc,descSupported]=autosar.mm.util.DescriptionHelper.getSLDescForEmbeddedObj(...
            this.ModelName,embeddedObj);
            if(descSupported)
                m3iDesc=autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescription(this.m3iModel,...
                m3iMdg.desc,slDesc);
                if~isempty(m3iDesc)
                    m3iMdg.desc=m3iDesc;
                end
            end

            if~isempty(m3iImpType)
                this.DataConstrBuilder.addDataConstr(m3iImpType,...
                false);
                this.SwBaseTypeBuilder.addSwBaseType(m3iImpType);
                this.M3iBuiltTypeNames.appendType(m3iImpType);
                return;
            end
            if this.SlType2RefImpTypeMap.isKey(embeddedTypeName)
                m3iImpType=this.SlType2RefImpTypeMap(embeddedTypeName);
                this.updateModeRequestTypeMap(m3iImpType,m3iMdg);
            else

                m3iMetaClassName=Simulink.metamodel.types.Integer.MetaClass;
                arPkg=this.m3iModel.RootPackage.at(1);
                seq=autosar.mm.Model.findObjectByNameAndMetaClass(this.m3iDataTypePkg,platformTypeName{1},m3iMetaClassName,true);
                [found,m3iImpType]=this.isM3iTypeInSeq(seq,false);
                if~found
                    seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
                    arPkg,autosarTypeName{1},m3iMetaClassName);
                    [found,m3iImpType]=this.isM3iTypeInSeq(seq,false);
                end
                if~found

                    m3iImpType=Simulink.metamodel.types.Integer(this.m3iModel);
                    m3iImpType.Name=autosarTypeName{1};
                    dataSize=Simulink.metamodel.types.DataSize();
                    dataSize.value=storageTypeSize;
                    m3iImpType.Length=dataSize;
                    m3iImpType.IsSigned=storageTypeSign;
                    [m3iImpType.minValue,m3iImpType.maxValue]=...
                    autosar.utils.Math.toLowerAndUpperLimit(m3iImpType.IsSigned,...
                    double(m3iImpType.Length.value));
                    m3iImpType.isMinOpen=false;
                    m3iImpType.isMaxOpen=false;
                    this.m3iDataTypePkg.packagedElement.append(m3iImpType);
                end
                this.DataConstrBuilder.addDataConstr(m3iImpType,...
                false);
                this.SwBaseTypeBuilder.addSwBaseType(m3iImpType);
                this.updateModeRequestTypeMap(m3iImpType,m3iMdg);
            end

            if~this.IsAdaptive

                this.PlatformTypesDecorator.updatePlatformType(embeddedObj,'',m3iImpType);
            end

            this.M3iBuiltTypeNames.appendType(m3iImpType);
        end

        function addDataTypeMappingSetRef(this,m3iParamSWC)
            if~this.m3iBehavior.DataTypeMapping.isEmpty()
                m3iParamSWC.DataTypeMapping.addAll(this.m3iBehavior.DataTypeMapping);
            end
        end

        function addCompuMethodAndDataConstr(this,m3iType,slAppTypeAttributes)
            if isempty(m3iType)
                return;
            end
            if isa(m3iType,'Simulink.metamodel.types.Matrix')
                this.addCompuMethodAndDataConstr(m3iType.BaseType,slAppTypeAttributes);
                return;
            elseif isa(m3iType,'Simulink.metamodel.types.Structure')
                for ii=1:m3iType.Elements.size
                    this.addCompuMethodAndDataConstr(m3iType.Elements.at(ii),slAppTypeAttributes);
                end
                return;
            end
            if~isa(m3iType,'Simulink.metamodel.types.PrimitiveType')
                return;
            end
            isAppType=m3iType.IsApplication;
            if isAppType
                this.CompuMethodBuilder.findOrCreateCompuMethodForAppType(m3iType,...
                'SlUnitName',slAppTypeAttributes.Unit);
                assert(this.ApplicationTypeMapper.isMapped(m3iType),'Expected application type to be mapped');
                m3iImpType=this.ApplicationTypeMapper.mappedTo(m3iType);
                if~m3iImpType.SwBaseType.isvalid()
                    this.SwBaseTypeBuilder.addSwBaseType(m3iImpType);
                end
            else
                this.CompuMethodBuilder.findOrCreateCompuMethodForImpType(m3iType);
                if~m3iType.SwBaseType.isvalid()
                    this.SwBaseTypeBuilder.addSwBaseType(m3iType);
                end
            end
            if isempty(m3iType.DataConstr)
                this.DataConstrBuilder.addDataConstr(m3iType,isAppType);


                dataTypeMapSet=this.m3iBehavior.DataTypeMapping;
                for ii=1:dataTypeMapSet.size()
                    dataTypeMap=dataTypeMapSet.at(ii).dataTypeMap;
                    for jj=1:dataTypeMap.size()
                        appType=dataTypeMap.at(jj).ApplicationType;
                        impType=dataTypeMap.at(jj).ImplementationType;
                        if isAppType&&strcmp(appType.qualifiedName,...
                            m3iType.qualifiedName)
                            this.DataConstrBuilder.addDataConstr(impType,false);
                            return;
                        elseif~isAppType&&strcmp(impType.qualifiedName,...
                            m3iType.qualifiedName)
                            this.DataConstrBuilder.addDataConstr(appType,true);
                            return;
                        end
                    end
                end
            end
        end

        function findOrCreateM3ITypeWithAdditionalNativeTypeQualifier(this,m3iData,typeQualifier,mangledTypeName)






            createAppType=false;
            onlyFind=true;

            isTypedByAppType=m3iData.Type.IsApplication;
            if isTypedByAppType

                m3iImpType=this.ApplicationTypeMapper.mappedTo(m3iData.Type);
                typeMetaClass=m3iImpType.MetaClass;
            else
                typeMetaClass=m3iData.Type.MetaClass;
            end

            try
                [existingM3IImpType,~]=this.findOrCreateM3IType(...
                mangledTypeName,typeMetaClass,createAppType,onlyFind);
            catch ME
                if strcmp(ME.identifier,'RTW:autosar:errorDuplicateTypeInPackage')


                    enforeUnique=true;
                    mangledTypeName=arxml.arxml_private('p_create_aridentifier',...
                    mangledTypeName,min(this.MaxShortNameLength,namelengthmax),enforeUnique);

                    [existingM3IImpType,~]=this.findOrCreateM3IType(...
                    mangledTypeName,m3iData.Type.MetaClass,createAppType,onlyFind);
                else
                    rethrow(ME)
                end
            end

            if~isempty(existingM3IImpType)
                if isTypedByAppType
                    this.updateDataTypeMap(m3iData.Type,existingM3IImpType);
                else
                    m3iData.Type=existingM3IImpType;
                end
            elseif isTypedByAppType
                oldM3IType=m3iData.Type;
                oldM3iImpType=this.ApplicationTypeMapper.mappedTo(oldM3IType);
                newM3iImpType=this.copyM3ITypeAndUpdateAdditionalNativeTypeQualifier(oldM3iImpType,...
                typeQualifier,mangledTypeName);
                this.updateDataTypeMap(m3iData.Type,newM3iImpType);
                this.M3iBuiltTypeNames.appendType(newM3iImpType);
            else
                oldM3IImpType=m3iData.Type;
                newM3IImpType=this.copyM3ITypeAndUpdateAdditionalNativeTypeQualifier(oldM3IImpType,...
                typeQualifier,mangledTypeName);
                m3iData.Type=newM3IImpType;
                this.M3iBuiltTypeNames.appendType(newM3IImpType);
            end
        end

        function m3iImpType=findImpTypeForAppType(this,m3iAppType)


            m3iImpType=this.ApplicationTypeMapper.mappedTo(m3iAppType);
        end


        function trackIfApplicationType(this,embeddedType)
            typeIdentifier=embeddedType.Identifier;
            if this.ApplicationTypeMapper.isMappedByName(typeIdentifier)
                this.ApplicationTypeTracker.addAppTypeName(typeIdentifier);
            end
        end

        function identifier=getMatrixIdentifier(this,objectName,dimID)
            identifier=arxml.arxml_private...
            ('p_create_aridentifier',...
            sprintf('rt_Array_%s_%s',objectName,dimID),...
            this.MaxShortNameLength);
        end

        function addSwRecordLayoutAnnotationsToLookupTableImplType(this,codeDescLUTObj,m3iImpType)
            if isa(m3iImpType,'Simulink.metamodel.types.Structure')
                arRoot=this.m3iModel.RootPackage.front();
                if autosar.mm.util.XmlOptionsAdapter.get(...
                    arRoot,'ExportSwRecordLayoutAnnotationsOnAdminData')
                    autosar.mm.sl2mm.utils.DaVinciLUT.addExternalToolInfoToM3iStructImpType(...
                    codeDescLUTObj,m3iImpType,this.ArrayLayout);
                else
                    autosar.mm.sl2mm.utils.DaVinciLUT.removeExternalToolInfoFromM3iStructImpType(m3iImpType);
                end
            else


            end
        end

    end

    methods(Access=private)

        function destroyObsoleteType(this,oldM3IType)

            oldTypeName=oldM3IType.Name;
            oldTypeQName=autosar.api.Utils.getQualifiedName(oldM3IType);



            if oldM3IType.IsApplication&&this.ApplicationTypeMapper.isMapped(oldM3IType)
                oldM3iImpType=this.ApplicationTypeMapper.mappedTo(oldM3IType);
                oldM3iImpType.destroy();
            end
            oldM3IType.destroy();



            this.ApplicationTypeMapper.removeMapping(oldTypeName,oldTypeQName);


            autosar.mm.sl2mm.ModelBuilder.destroyDTMappingSetsWithInvalidRefs(this.m3iModel);
        end

        function addSymbolicDimensions(this,symbolicWidth,m3iType)
            autosar.mm.sl2mm.variant.Utils.addSymbolicDimensions(symbolicWidth,m3iType,this.ModelName,this.m3iModel);
        end

        function identifier=getMatrixBaseIdentifier(this,objectName)
            identifier=arxml.arxml_private...
            ('p_create_aridentifier',...
            sprintf('%s_BaseType',objectName),...
            this.MaxShortNameLength);
        end

        function addDefaultApplicationDataTypePackage(this)


            import autosar.mm.Model;
            import autosar.mm.util.XmlOptionsAdapter;

            if isempty(this.m3iAppDataTypePkg)
                arRoot=this.m3iModel.RootPackage.at(1);
                applPkg=XmlOptionsAdapter.get(arRoot,...
                'ApplicationDataTypePackage');
                if isempty(applPkg)
                    defaultApplPkg=[arRoot.DataTypePackage,'/'...
                    ,autosar.mm.util.XmlOptionsDefaultPackages.ApplicationDataTypes];
                    XmlOptionsAdapter.set(arRoot,...
                    'ApplicationDataTypePackage',...
                    defaultApplPkg);
                    applPkg=defaultApplPkg;
                end
                this.m3iAppDataTypePkg=Model.getOrAddARPackage(arRoot,applPkg);
            end
        end

        function m3iAppType=findOrCreateAppTypeForAxisAttribute(this,codeDescType,codeType,min,max,unit)


            [min,max]=this.rectifyMinMaxValuesForLookupTableAttributes(min,max);
            slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes(min,max,unit);
            this.NeedToCreateAppType=true;

            this.addDefaultApplicationDataTypePackage();
            [~,m3iAppType]=this.findOrCreateImpAndAppTypes(codeDescType,codeType,slAppTypeAttributes);
            this.CompuMethodBuilder.findOrCreateCompuMethodForAppType(m3iAppType,...
            'SlUnitName',slAppTypeAttributes.Unit);
            this.DataConstrBuilder.addDataConstr(m3iAppType,true);
        end

        function findOrCreateLUTBaseType(this,m3iParent,parentName,embeddedObj,codeType,min,max)
            [min,max]=this.rectifyMinMaxValuesForLookupTableAttributes(min,max);
            slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes(min,max,'');
            baseTypeName=this.getLUTBaseTypeNameFromEmbeddedObj(embeddedObj,parentName,slAppTypeAttributes);
            if~isempty(m3iParent.BaseType)&&m3iParent.BaseType.isvalid()
                if~strcmp(baseTypeName,m3iParent.BaseType.Name)
                    m3iParent.BaseType.destroy();
                    m3iParent.BaseType=this.createLUTBaseType(embeddedObj,baseTypeName,min,max);
                else
                    typeChecker=autosar.mm.sl2mm.TypeEquivalencyChecker(m3iParent.BaseType,...
                    this.ModelName,this.ApplicationTypeTracker);
                    isEquivalent=typeChecker.isEquivalent(embeddedObj,codeType,...
                    slAppTypeAttributes,baseTypeName,true,true);
                    if~isEquivalent&&isa(m3iParent.BaseType,'Simulink.metamodel.types.FixedPoint')&&...
                        isa(embeddedObj,'coder.descriptor.types.Fixed')&&...
                        m3iParent.BaseType.Bias==embeddedObj.Bias&&...
                        m3iParent.BaseType.slope==embeddedObj.Slope
                        isEquivalent=true;
                    end
                    if isEquivalent&&embeddedObj.isNumeric
                        autosar.mm.sl2mm.TypeBuilder.updateNumericType(m3iParent.BaseType,embeddedObj,true,min,max);
                    else
                        m3iParent.BaseType.destroy();
                        m3iParent.BaseType=this.createLUTBaseType(embeddedObj,baseTypeName,min,max);
                    end
                end
            else
                m3iParent.BaseType=this.createLUTBaseType(embeddedObj,baseTypeName,min,max);
            end
        end

        function baseTypeName=getLUTBaseTypeNameFromEmbeddedObj(this,embeddedObj,parentName,slAppTypeAttributes)


            appTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            if embeddedObj.isNumeric
                [shouldMangle,slMinNumeric,slMaxNumeric]=this.shouldMangleAppTypeName([],embeddedObj,...
                this.ModelName,slAppTypeAttributes);
                if shouldMangle
                    appTypeName=slAppTypeAttributes.getAppTypeName(...
                    embeddedObj,this.MaxShortNameLength,...
                    slMinNumeric,slMaxNumeric,this.ModelName);
                else
                    appTypeName=this.getFixedPointTypeName(embeddedObj,this.ModelName);
                end
            end
            baseTypeName=arxml.arxml_private('p_create_aridentifier',...
            ['BaseType_',parentName,'_',appTypeName],this.MaxShortNameLength);
        end



        function m3iType=createLUTBaseType(this,embeddedObj,typeName,min,max)
            if embeddedObj.isEnum
                clsName='Simulink.metamodel.types.EnumerationLiteral';
                m3iMetaClassName='Simulink.metamodel.types.Enumeration';
                m3iType=eval([m3iMetaClassName,'(this.m3iModel)']);%#ok<EVLDOT>
                m3iType.Name=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
                m3iType.IsApplication=true;
                this.SwBaseTypeBuilder.addSwBaseType(m3iType);

                seqMerger=...
                autosar.mm.util.SequenceMerger(this.m3iModel,...
                m3iType.OwnedLiteral,clsName);
                for ii=1:length(embeddedObj.Strings.toArray)
                    m3iLiteral=seqMerger.mergeByName(embeddedObj.Strings.toArray{ii});
                    m3iLiteral.Value=embeddedObj.Values(ii);
                end



                m3iType.DefaultValue=double(embeddedObj.Values(embeddedObj.DefaultMember+1));
                m3iType.Name=typeName;
            else
                if(embeddedObj.isDouble||embeddedObj.isSingle)
                    m3iMetaClassName='Simulink.metamodel.types.FloatingPoint';
                elseif embeddedObj.isBoolean
                    m3iMetaClassName='Simulink.metamodel.types.Boolean';
                elseif embeddedObj.isInteger
                    m3iMetaClassName='Simulink.metamodel.types.Integer';
                elseif embeddedObj.isFixed
                    autosar.mm.sl2mm.TypeBuilder.doWordSizeCheck(this.ModelName,embeddedObj.Name,embeddedObj.WordLength);
                    if embeddedObj.Slope~=1||embeddedObj.Bias~=0
                        m3iMetaClassName='Simulink.metamodel.types.FixedPoint';
                    else
                        m3iMetaClassName='Simulink.metamodel.types.Integer';
                    end
                elseif embeddedObj.isScaledDouble
                    this.msgStream.createError('RTW:autosar:unsupportedExportedDataType',...
                    embeddedObj.DataTypeMode);
                end
                m3iType=eval([m3iMetaClassName,'(this.m3iModel)']);%#ok<EVLDOT>
                m3iType.IsApplication=true;


                m3iType.Name=typeName;
                this.updateNumericType(m3iType,embeddedObj,true,min,max);
                this.SwBaseTypeBuilder.addSwBaseType(m3iType);
            end
        end
        function[m3iImpType,m3iAppType]=findOrCreateImpAndAppTypes(this,embeddedObj,codeType,slAppTypeAttributes)

            if embeddedObj.isEnum


                [m3iImpType,m3iAppType]=this.findOrCreateEnumType(embeddedObj,slAppTypeAttributes);
            elseif embeddedObj.isNumeric
                [m3iImpType,m3iAppType]=this.findOrCreateNumericType(embeddedObj,slAppTypeAttributes);
            elseif embeddedObj.isMatrix
                if embeddedObj.BaseType.isChar
                    [m3iImpType,m3iAppType]=this.findOrCreateStringType(embeddedObj,codeType,slAppTypeAttributes);
                elseif numel(slAppTypeAttributes)==1&&~isempty(slAppTypeAttributes.LookupTableData)
                    [m3iImpType,m3iAppType]=this.findOrCreateLookupOrSharedAxis(slAppTypeAttributes);
                else
                    [m3iImpType,m3iAppType]=this.findOrCreateMatrixType(embeddedObj,codeType,slAppTypeAttributes);
                end
            elseif embeddedObj.isChar
                [m3iImpType,m3iAppType]=this.findOrCreateNumericType(embeddedObj,slAppTypeAttributes);
            elseif embeddedObj.isStructure
                [m3iImpType,m3iAppType]=this.findOrCreateStructType(embeddedObj,codeType,slAppTypeAttributes);
            elseif embeddedObj.isComplex
                m3iImpType=[];
                m3iAppType=[];
                this.msgStream.createError('RTW:autosar:unsupportedExportedDataType','Complex');
            elseif embeddedObj.isOpaque
                m3iImpType=[];
                m3iAppType=[];
                this.msgStream.createError('RTW:autosar:unsupportedExportedDataType','Opaque');
            elseif embeddedObj.isPointer&&embeddedObj.BaseType.isVoid
                [m3iImpType,m3iAppType]=this.findOrCreateVoidPointerType(embeddedObj,slAppTypeAttributes);
            elseif embeddedObj.isPointer
                [m3iImpType,m3iAppType]=this.findOrCreateMatrixType(embeddedObj,codeType,slAppTypeAttributes);
            elseif embeddedObj.isVoid
                assert(false,'Only embedded.pointertype --> embedded.voidtype supported');
            else
                assert(false,DAStudio.message('RTW:autosar:unrecognizedExportedDataType',class(embeddedObj)));
            end

            if~this.IsAdaptive

                this.PlatformTypesDecorator.updatePlatformType(embeddedObj,m3iAppType,m3iImpType);
            end

            if isempty(codeType)
                codeDescriptorType=embeddedObj;
            else
                codeDescriptorType=codeType;
            end
            this.createOrUpdateNamespaces(codeDescriptorType,m3iImpType);
        end

        function[m3iImpType,m3iAppType]=findOrCreateLookupOrSharedAxis(this,slAppTypeAttributes)
            codeDescLUTObj=slAppTypeAttributes.LookupTableData;
            if isa(codeDescLUTObj,'coder.descriptor.BreakpointDataInterface')
                [m3iAppType,m3iImpType]=this.findOrCreateSharedAxisType(slAppTypeAttributes.LookupTableData,{});
            elseif isa(codeDescLUTObj,'coder.descriptor.LookupTableDataInterface')
                [m3iAppType,m3iImpType]=this.findOrCreateLookupTableTypeFromAppTypeAttributes(slAppTypeAttributes,{});
            else
                return;
            end
            if isempty(m3iAppType)
                return;
            end


            if isa(codeDescLUTObj,'coder.descriptor.LookupTableDataInterface')&&...
                ~strcmp(slAppTypeAttributes.Name,codeDescLUTObj.GraphicalName)
                for ii=1:m3iAppType.Axes.size()
                    appTypeName=this.LookupTableBuilder.getApplicationDataTypeName(slAppTypeAttributes.Name,this.MaxShortNameLength);
                    if strcmp(appTypeName,m3iAppType.Axes.at(ii).SharedAxis.Name)
                        m3iAppType=m3iAppType.Axes.at(ii).SharedAxis;
                        break;
                    end
                end
                m3iImpType=this.ApplicationTypeMapper.mappedTo(m3iAppType);
            end
            if~isempty(slAppTypeAttributes.DisplayFormat)
                m3iAppType.DisplayFormat=slAppTypeAttributes.DisplayFormat;
            end
            if~isempty(slAppTypeAttributes.SwCalibrationAccess)
                m3iAppType.SwCalibrationAccess=slAppTypeAttributes.SwCalibrationAccess;
            end
        end

        function[m3iImpType,m3iAppType]=findOrCreateEnumType(this,embeddedObj,slAppTypeAttributes)


            m3iAppType='undefined';

            appTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);

            refImpType=false;
            if~isempty(embeddedObj.StorageType)
                [m3iImpType,refImpType]=...
                this.findOrCreateEnumTypeForStorageType(embeddedObj);
            else
                assert(~this.IsAdaptive,...
                'Always expect StorageType to be populated for adaptive');
                impTypeName=appTypeName;
                m3iImpType=this.createEnumImpTypeForEnum(embeddedObj,impTypeName);
            end
            if~refImpType
                this.DataConstrBuilder.addDataConstr(m3iImpType,...
                false);
                this.SwBaseTypeBuilder.addSwBaseType(m3iImpType);
            end

            if isa(m3iImpType,'Simulink.metamodel.types.Integer')


                this.NeedToCreateAppType=true;


                this.addDefaultApplicationDataTypePackage();
            end

            if this.NeedToCreateAppType
                if this.SlType2RefAppTypeMap.isKey(appTypeName)
                    m3iAppType=this.SlType2RefAppTypeMap(appTypeName);
                    this.updateDataTypeMap(m3iAppType,m3iImpType);
                else
                    m3iAppType=this.createEnumType(embeddedObj,appTypeName,...
                    this.m3iAppDataTypePkg,true);
                    this.updateDataTypeMap(m3iAppType,m3iImpType);
                    this.CompuMethodBuilder.findOrCreateCompuMethodForAppType(m3iAppType,...
                    'SlUnitName',slAppTypeAttributes.Unit);

                    this.setCompuMethodSlDataTypes(m3iAppType,embeddedObj);
                end
            else
                this.setCompuMethodSlDataTypes(m3iImpType,embeddedObj);
            end
        end

        function[m3iImpType,refImpType]=findOrCreateEnumTypeForStorageType(this,embeddedObj)


            refImpType=false;
            m3iImpType=this.findCompatibleEnumImpTypeFromDataTypeMapping(embeddedObj);
            if~isempty(m3iImpType)

                return;
            end

            appTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            if this.SlType2RefImpTypeMap.isKey(appTypeName)
                m3iImpType=this.SlType2RefImpTypeMap(appTypeName);
                refImpType=true;
                return
            end

            arPkg=this.m3iModel.RootPackage.at(1);
            m3iMetaClassName=Simulink.metamodel.types.Integer.MetaClass;
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
            arPkg,appTypeName,m3iMetaClassName);
            [found,m3iImpType]=this.isM3iTypeInSeq(seq,false);
            if~found
                m3iMetaClassName=Simulink.metamodel.types.Enumeration.MetaClass;
                seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(...
                arPkg,appTypeName,m3iMetaClassName);
                [found,m3iImpType]=this.isM3iTypeInSeq(seq,false);
            end
            if~found
                impTypeName=appTypeName;
                if this.IsAdaptive




                    m3iImpType=this.createEnumImpTypeForEnum(embeddedObj,impTypeName);
                else
                    m3iImpType=this.createIntegerImpTypeForEnum(embeddedObj,impTypeName);
                end
            else
                if m3iImpType.MetaClass==Simulink.metamodel.types.Enumeration.MetaClass
                    this.setEnumType(m3iImpType,embeddedObj);
                end
                autosar.mm.sl2mm.TypeBuilder.configureImpTypeForCodeType(...
                m3iImpType,embeddedObj);
            end
        end

        function m3iImpType=findCompatibleEnumImpTypeFromDataTypeMapping(this,embeddedObj)

            embeddedTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            m3iImpType=this.findEnumImpTypeFromDataTypeMapping(embeddedTypeName);

            if isempty(m3iImpType)

                return;
            end

            if~autosar.mm.sl2mm.TypeBuilder.isEnumImpTypeCompatible(...
                m3iImpType,embeddedObj)


                m3iImpType=[];
            end
        end

        function m3iImpType=findEnumImpTypeFromDataTypeMapping(this,appTypeName)
            m3iImpType=[];
            dataTypeMapSet=this.m3iBehavior.DataTypeMapping;
            for ii=1:dataTypeMapSet.size()
                dataTypeMap=dataTypeMapSet.at(ii).dataTypeMap;
                for jj=1:dataTypeMap.size()
                    if isa(dataTypeMap.at(jj).ApplicationType,'Simulink.metamodel.types.Enumeration')...
                        &&strcmp(dataTypeMap.at(jj).ApplicationType.Name,appTypeName)
                        m3iImpType=dataTypeMap.at(jj).ImplementationType;
                        break;
                    end
                end
                if~isempty(m3iImpType)
                    break;
                end
            end
        end

        function m3iImpType=createIntegerImpTypeForEnum(this,embeddedObj,impTypeName)
            assert(embeddedObj.isEnum,'Expected enum type');
            m3iImpType=Simulink.metamodel.types.Integer(this.m3iModel);
            m3iImpType.Name=impTypeName;
            autosar.mm.sl2mm.TypeBuilder.configureImpTypeForCodeType(...
            m3iImpType,embeddedObj);
            this.m3iDataTypePkg.packagedElement.append(m3iImpType);
        end

        function m3iImpType=createEnumImpTypeForEnum(this,embeddedObj,impTypeName)
            assert(embeddedObj.isEnum,'Expected enum type');
            m3iImpType=this.createEnumType(embeddedObj,impTypeName,...
            this.m3iDataTypePkg,false);
            this.CompuMethodBuilder.findOrCreateCompuMethodForImpType(m3iImpType);
        end

        function[m3iImpType,m3iAppType]=findOrCreateStringType(this,embeddedObj,codeType,slAppTypeAttributes)


            import Simulink.metamodel.types.String;



            if slfeature('AUTOSARStringsClassic')==0
                DAStudio.error('autosarstandard:validation:stringNotSupported','string')
            end


            createAppType=true;
            appTypeName=this.getAppAndImpTypeNames(embeddedObj);
            [m3iAppType,isAppTypeInDifferentPkg]=this.findOrCreateM3IType(appTypeName,String.MetaClass,createAppType);


            if~isAppTypeInDifferentPkg
                this.SwBaseTypeBuilder.addSwBaseType(m3iAppType);



                m3iAppType.SwMaxTextSize=...
                autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.getDimensionArray(embeddedObj,codeType);
                m3iAppType.SwFillCharacter=0;
                m3iAppType.IsVariableSize=false;




                m3iAppType.SwRecordLayout=Simulink.metamodel.types.SwRecordLayout(this.m3iModel);
                m3iAppType.SwRecordLayout.Name='StringSwRecordLayout';
                this.m3iDataTypePkg.packagedElement.append(m3iAppType.SwRecordLayout);

                this.m3iDataTypePkg.packagedElement.append(m3iAppType);






                this.NeedToCreateAppType=false;
                m3iImpType=findOrCreateMatrixType(this,embeddedObj,codeType,slAppTypeAttributes);
                this.SwBaseTypeBuilder.addSwBaseType(m3iImpType);


                this.NeedToCreateAppType=true;
                this.updateDataTypeMap(m3iAppType,m3iImpType);
            end
        end


        function[m3iImpType,m3iAppType]=findOrCreateNumericType(this,embeddedObj,slAppTypeAttributes)
            import Simulink.metamodel.types.CompuMethodCategory;

            m3iAppType=[];
            m3iImpType=[];
            [appTypeName,impTypeName]=this.getAppAndImpTypeNames(embeddedObj);
            if~isempty(slAppTypeAttributes.Name)
                appTypeName=slAppTypeAttributes.Name;
            end
            if this.SlType2RefImpTypeMap.isKey(appTypeName)
                m3iImpType=this.SlType2RefImpTypeMap(appTypeName);
                impTypeName=m3iImpType.Name;
            end

            if this.SlType2RefAppTypeMap.isKey(appTypeName)
                m3iAppType=this.SlType2RefAppTypeMap(appTypeName);
                appTypeName=m3iAppType.Name;
            end

            isAppType=false;
            onlyFind=false;
            if isempty(m3iImpType)
                m3iImpType=this.findOrCreateM3iNumericType(embeddedObj,impTypeName,...
                this.m3iDataTypePkg,isAppType,onlyFind);
                autosar.mm.sl2mm.TypeBuilder.updateNumericType(m3iImpType,embeddedObj,isAppType);

                if isa(m3iImpType,'Simulink.metamodel.types.Boolean')
                    this.CompuMethodBuilder.findOrCreateCompuMethodForImpType(m3iImpType);
                end

                this.DataConstrBuilder.addDataConstr(m3iImpType,...
                false);
                this.SwBaseTypeBuilder.addSwBaseType(m3iImpType);
            end

            if this.NeedToCreateAppType
                if~isempty(m3iAppType)
                    this.updateDataTypeMap(m3iAppType,m3iImpType);
                    return;
                end

                onlyFind=true;
                isAppType=true;
                m3iAppType=this.findOrCreateM3iNumericType(embeddedObj,...
                appTypeName,this.m3iAppDataTypePkg,isAppType,onlyFind);
                mangledAppTypeName=appTypeName;



                this.ApplicationTypeTracker.addAppTypeName(appTypeName);

                if~isempty(m3iImpType.CompuMethod)&&m3iImpType.CompuMethod.Category==CompuMethodCategory.TextTable

                    slMinNumeric=[];
                    slMaxNumeric=[];
                elseif embeddedObj.isChar

                else




                    [mangleAppTypeName,slMinNumeric,slMaxNumeric]=...
                    autosar.mm.sl2mm.TypeBuilder.shouldMangleAppTypeName(...
                    m3iAppType,embeddedObj,this.ModelName,slAppTypeAttributes);
                    if mangleAppTypeName

                        mangledAppTypeName=slAppTypeAttributes.getAppTypeName(...
                        embeddedObj,this.MaxShortNameLength,slMinNumeric,slMaxNumeric,this.ModelName);
                    end
                end


                if isempty(m3iAppType)||~strcmp(appTypeName,mangledAppTypeName)
                    onlyFind=false;
                    m3iAppType=this.findOrCreateM3iNumericType(embeddedObj,...
                    mangledAppTypeName,this.m3iAppDataTypePkg,isAppType,onlyFind);
                    if~strcmp(appTypeName,mangledAppTypeName)
                        autosar.api.Utils.setUnmangledName(m3iAppType,appTypeName);
                    end
                end

                autosar.mm.sl2mm.TypeBuilder.updateNumericType(m3iAppType,...
                embeddedObj,isAppType,slMinNumeric,slMaxNumeric);
                this.updateDataTypeMap(m3iAppType,m3iImpType);
                this.CompuMethodBuilder.findOrCreateCompuMethodForAppType(...
                m3iAppType,'UnmangledAppTypeName',appTypeName,...
                'SlUnitName',slAppTypeAttributes.Unit);
                this.DataConstrBuilder.addDataConstr(m3iAppType,true);

                this.setCompuMethodSlDataTypes(m3iAppType,embeddedObj);
            end
        end

        function[m3iImpType,m3iAppType]=findOrCreateMatrixType(this,embeddedObj,codeType,slAppTypeAttributes)

            dimensionArray=...
            autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.getDimensionArray(embeddedObj,codeType);

            slAppTypeAttributesBase=slAppTypeAttributes.clone();
            slAppName=slAppTypeAttributes.Name;
            if~isempty(slAppName)&&~slAppTypeAttributes.ShouldMangle
                slAppTypeAttributesBase.setName(this.getMatrixBaseIdentifier(slAppName));
            end
            baseCodeType=this.getMatrixBaseCodeType(codeType,dimensionArray);

            [m3iImpBaseType,m3iAppBaseType]=this.findOrCreateImpAndAppTypes(embeddedObj.BaseType,baseCodeType,slAppTypeAttributesBase);

            [m3iImpType,m3iAppType]=findOrCreateMatrixTypeRecurseDims(this,embeddedObj,codeType,dimensionArray,slAppTypeAttributes,...
            m3iImpBaseType,m3iAppBaseType);
        end

        function[m3iImpType,m3iAppType]=findOrCreateMatrixTypeRecurseDims(this,embeddedObj,codeType,dimensionArray,slAppTypeAttributes,...
            m3iImpBaseType,m3iAppBaseType)


            m3iAppType='undefined';

            slAppName=slAppTypeAttributes.Name;
            slAppTypeAttributes.setName('');


            if embeddedObj.isMatrix&&~embeddedObj.HasSymbolicDimensions&&~embeddedObj.ArrSizeOne
                if dimensionArray==1
                    m3iImpType=m3iImpBaseType;
                    m3iAppType=m3iAppBaseType;
                    slAppTypeAttributes.setName(slAppName);
                    return
                end
            end


            if this.NeedToCreateAppType
                objectName=m3iAppBaseType.Name;
            else
                objectName=m3iImpBaseType.Name;
            end
            dimid=autosar.mm.sl2mm.variant.Utils.getDimensionsIdentifier(embeddedObj,dimensionArray);
            embeddedObj.Identifier=this.getMatrixIdentifier(objectName,dimid);

            appTypeName=embeddedObj.Identifier;
            if this.NeedToCreateAppType
                impTypeName=this.getMatrixIdentifier(m3iImpBaseType.Name,dimid);
            else
                impTypeName=this.getImplementationTypeName(appTypeName);
            end

            if numel(dimensionArray)>1
                [impBaseType,appBaseType]=this.findOrCreateMatrixTypeRecurseDims(embeddedObj,codeType,dimensionArray(2:end),...
                slAppTypeAttributes,m3iImpBaseType,m3iAppBaseType);
            else
                impBaseType=m3iImpBaseType;
                appBaseType=m3iAppBaseType;
            end

            m3iImpType=this.createMatrixType(embeddedObj,dimensionArray(1),impTypeName,...
            this.m3iDataTypePkg,...
            impBaseType,false);

            if this.NeedToCreateAppType
                if~isempty(slAppName)&&~slAppTypeAttributes.ShouldMangle
                    appTypeName=slAppName;
                end
                m3iAppType=this.createMatrixType(embeddedObj,dimensionArray(1),appTypeName,...
                this.m3iAppDataTypePkg,...
                appBaseType,true);
                this.updateDataTypeMap(m3iAppType,m3iImpType);
            end
            slAppTypeAttributes.setName(slAppName);
        end


        function[m3iImpType,m3iAppType]=findOrCreateVoidPointerType(this,embeddedObj,~,~)
            m3iAppType='undefined';


            objectName='PtrType';

            embeddedObj.Identifier=objectName;

            appTypeName=embeddedObj.Identifier;
            impTypeName=this.getImplementationTypeName(appTypeName);

            m3iImpType=this.createVoidPointerType(embeddedObj,impTypeName,...
            this.m3iDataTypePkg,...
            false);

            assert(~this.NeedToCreateAppType,'[constr_1066] VoidPointer should not be an application type');
        end



        function[m3iImpType,m3iAppType]=findOrCreateStructType(this,embeddedObj,codeType,slAppTypeAttributesArray)


            import Simulink.metamodel.types.Structure;
            import Simulink.metamodel.types.StructElement;

            m3iAppType='undefined';
            appTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            impTypeName=this.getImplementationTypeName(appTypeName);

            elemMetaClassStr='Simulink.metamodel.types.StructElement';

            [m3iImpType,isImpTypeInDifferentPkg]=...
            this.findOrCreateM3IType(impTypeName,...
            Structure.MetaClass,false);
            if~isImpTypeInDifferentPkg
                this.m3iDataTypePkg.packagedElement.append(m3iImpType);
            end


            impSeqMerger=autosar.mm.util.SequenceMerger(this.m3iModel,...
            m3iImpType.Elements,...
            elemMetaClassStr);




            embeddedTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            slObj=autosar.mm.util.getValueFromGlobalScope(this.ModelName,embeddedTypeName);
            isLegacyStructType=any(strcmp(class(slObj),{'Simulink.StructType','Simulink.StructElement'}));
            slAppTypeAttributesSupported=this.NeedToCreateAppType&&...
            ~isempty(slObj)&&~isLegacyStructType;
            slDescriptionSupported=~isempty(slObj)&&~isLegacyStructType;

            needToCreateAppTypeForStructType=this.NeedToCreateAppType;
            if needToCreateAppTypeForStructType
                [m3iAppType,isAppTypeInDifferentPkg]=...
                this.findOrCreateM3IType(appTypeName,...
                Structure.MetaClass,true);
                if slDescriptionSupported
                    autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                    m3iAppType,slObj.Description);
                end

                if~isAppTypeInDifferentPkg
                    this.m3iAppDataTypePkg.packagedElement.append(m3iAppType);
                end

                appSeqMerger=autosar.mm.util.SequenceMerger(this.m3iModel,...
                m3iAppType.Elements,...
                elemMetaClassStr);
            end

            if slDescriptionSupported
                autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                m3iImpType,slObj.Description);
            end

            len=length(embeddedObj.Elements);
            if isa(embeddedObj,'coder.descriptor.types.Struct')
                len=length(embeddedObj.Elements);
            end

            for kk=1:len
                currElement=embeddedObj.Elements(kk);
                slAppTypeAttributesElem=[];
                if isempty(slObj)&&numel(slAppTypeAttributesArray)>0
                    for attribIdx=1:numel(slAppTypeAttributesArray)
                        if strcmp(slAppTypeAttributesArray(attribIdx).Name,currElement.Identifier)
                            slAppTypeAttributesElem=slAppTypeAttributesArray(attribIdx);
                            break;
                        end
                    end
                end
                if isempty(slAppTypeAttributesElem)
                    if slAppTypeAttributesSupported
                        slObjElement=slObj.Elements(kk);
                        slAppTypeAttributesElem=autosar.mm.util.SlAppTypeAttributesGetter.fromBusElementObj(slObjElement,this.ModelName);
                    else
                        slAppTypeAttributesElem=autosar.mm.util.SlAppTypeAttributes([],[],'');
                    end
                elseif~isempty(slAppTypeAttributesElem.LookupTableData)&&...
                    ~this.LookupTableBuilder.hasValidLookupTableDataInterface(...
                    slAppTypeAttributesElem.LookupTableData)

                    slAppTypeAttributesElem.removeLookupTableData();
                end

                codeTypeElem=this.getStructElementCodeType(codeType,kk);

                [m3iImpStructElType,m3iAppStructElType]=...
                this.findOrCreateImpAndAppTypes(currElement.Type,codeTypeElem,slAppTypeAttributesElem);
                assert(~isempty(m3iImpStructElType),'m3iImpStructElType cannot be empty');

                m3iImpStructElName=currElement.Identifier;
                m3iImpStructEl=impSeqMerger.mergeByName(m3iImpStructElName);
                if slDescriptionSupported
                    autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                    m3iImpStructEl,slObj.Elements(kk).Description);
                end

                if m3iImpStructEl.InlineType.isvalid()


                    m3iImpStructEl.InlineType.destroy();
                end

                m3iImpStructEl.Type=m3iImpStructElType;


                if needToCreateAppTypeForStructType
                    assert(~isempty(m3iAppStructElType),'m3iAppStructElType cannot be empty');

                    if isempty(slObj)&&numel(slAppTypeAttributesArray)>0
                        if~isempty(slAppTypeAttributesElem.SwCalibrationAccess)
                            m3iAppStructElType.SwCalibrationAccess=slAppTypeAttributesElem.SwCalibrationAccess;
                        end
                        if~isempty(slAppTypeAttributesElem.DisplayFormat)
                            m3iAppStructElType.DisplayFormat=slAppTypeAttributesElem.DisplayFormat;
                        end
                        if~isempty(slAppTypeAttributesElem.Description)
                            autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                            m3iAppStructElType,slAppTypeAttributesElem.Description);
                        end
                    end
                    m3iAppStructElName=currElement.Identifier;
                    m3iAppStructEl=appSeqMerger.mergeByName(m3iAppStructElName);
                    if slDescriptionSupported
                        autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                        m3iAppStructEl,slObj.Elements(kk).Description);
                    end
                    m3iAppStructEl.Type=m3iAppStructElType;
                end
            end

            if needToCreateAppTypeForStructType
                this.updateDataTypeMap(m3iAppType,m3iImpType);
            end

            if this.NeedToCreateAppType&&~needToCreateAppTypeForStructType





                [m3iImpType,m3iAppType]=this.findOrCreateStructType(embeddedObj,codeType,slAppTypeAttributesArray);
            end

        end

        function[appTypeName,impTypeName]=getAppAndImpTypeNames(this,embeddedObj)
            import autosar.mm.util.XmlOptionsAdapter;

            if embeddedObj.isMatrix&&embeddedObj.BaseType.isChar||embeddedObj.isChar
                appTypeName='MyStringAppType';
                impTypeName='MyStringImpType';
            else
                isAR4PlatformTypeNameStyle=false;




                if slfeature('AUTOSARPlatformTypesRefAndNativeDecl')&&~this.IsAdaptive
                    arRoot=this.m3iModel.RootPackage.at(1);
                    platformTypeReference=XmlOptionsAdapter.get(arRoot,'UsePlatformTypeReferences');
                    platformTypesPackageName=XmlOptionsAdapter.get(arRoot,'PlatformDataTypePackage');

                    isAR4PlatformTypeNameStyle=~isempty(platformTypesPackageName)||strcmp(platformTypeReference,'PlatformTypeReference');
                end

                appTypeName=autosar.mm.sl2mm.TypeBuilder.getFixedPointTypeName(embeddedObj,this.ModelName,isAR4PlatformTypeNameStyle);

                impTypeName=this.getImplementationTypeName(appTypeName);
            end
        end

        function impTypeName=getImplementationTypeName(this,appTypeName)
            if this.NeedToCreateAppType
                if this.ApplicationTypeMapper.isMappedByName(appTypeName)
                    impTypeName=this.ApplicationTypeMapper.mappedToByName(appTypeName);
                else
                    impTypeName=appTypeName;
                end
            else
                impTypeName=appTypeName;
            end

        end

        function updateDataTypeMap(this,m3iAppType,m3iImpType)
            if this.NeedToCreateAppType

                this.ApplicationTypeTracker.addAppTypeName(m3iAppType.Name);
                this.ApplicationTypeMapper.mapInComponent(m3iAppType,m3iImpType);
            end
        end

        function updateModeRequestTypeMap(this,m3iImpType,m3iModeGroup)

            this.ApplicationTypeTracker.addModeGroupName(m3iModeGroup.Name);
            this.ApplicationTypeMapper.mapModeGroupInComponent(m3iModeGroup,m3iImpType);
        end

        function m3iType=createEnumType(this,embeddedObj,name,...
            m3iDataTypePkg,createAppType)


            import Simulink.metamodel.types.Enumeration;
            [m3iType,isTypeInDifferentPkg]=...
            this.findOrCreateM3IType(name,...
            Enumeration.MetaClass,...
            createAppType);
            if~isTypeInDifferentPkg
                m3iDataTypePkg.packagedElement.append(m3iType);
            end

            this.setEnumType(m3iType,embeddedObj);
        end

        function setEnumType(this,m3iType,embeddedObj)
            if isa(embeddedObj,'coder.descriptor.types.Enum')
                enumStrings=embeddedObj.Strings.toArray;
                enumValues=embeddedObj.Values.toArray;
            else
                enumStrings=embeddedObj.Strings;
                enumValues=embeddedObj.Values;
            end


            literalPrefix=this.LiteralPrefixHelper.getLiteralPrefix(m3iType);
            if~isempty(literalPrefix)
                enumStrings=autosar.mm.util.removeEnumClassNamePrefix(literalPrefix,enumStrings);
            end

            if this.IsAdaptive&&matlab.internal.feature("Cpp11ScopedEnumClass")
                enumStrings=autosar.mm.sl2mm.TypeBuilder.convertScopedEnumClassLiterals(enumStrings);
            end

            if m3iType.OwnedLiteral.size()==length(enumStrings)
                for ii=1:length(enumStrings)
                    m3iLiteral=m3iType.OwnedLiteral.at(ii);
                    m3iLiteral.Name=enumStrings{ii};
                    m3iLiteral.Value=enumValues(ii);
                end
            else

                clsName='Simulink.metamodel.types.EnumerationLiteral';
                seqMerger=...
                autosar.mm.util.SequenceMerger(this.m3iModel,...
                m3iType.OwnedLiteral,clsName);
                for ii=1:length(enumStrings)
                    m3iLiteral=seqMerger.mergeByName(enumStrings{ii});
                    m3iLiteral.Value=enumValues(ii);
                end
            end
            m3iType.DefaultValue=double(embeddedObj.getDefaultValue());
            if~isempty(embeddedObj.StorageType)
                m3iType.IsSigned=embeddedObj.StorageType.Signedness;
                m3iType.Length=Simulink.metamodel.types.DataSize();
                m3iType.Length.value=embeddedObj.StorageType.WordLength;
            end


            if~isempty(m3iType)
                [slDesc,descSupported]=autosar.mm.util.DescriptionHelper.getSLDescForEmbeddedObj(...
                this.ModelName,embeddedObj);
                if(descSupported)
                    autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                    m3iType,slDesc);
                end
            end
        end

        function m3iType=findOrCreateM3iNumericType(this,embeddedObj,name,...
            m3iDataTypePkg,createAppType,onlyFind)


            import Simulink.metamodel.types.FloatingPoint;
            import Simulink.metamodel.types.Boolean;
            import Simulink.metamodel.types.FixedPoint;
            import Simulink.metamodel.types.Integer;

            if nargin<6
                onlyFind=false;
            end

            embeddedTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            if~createAppType&&autosar.mm.util.BuiltInTypeMapper.isRTWBuiltIn(embeddedTypeName,this.ModelName)
                if this.IsAdaptive
                    m3iType=this.findAdaptivePlatformType(embeddedTypeName);
                else
                    m3iType=this.findAR4PlatformType(embeddedTypeName);
                end
                if~isempty(m3iType)
                    return
                end
            end
            if embeddedObj.isChar
                [m3iType,isTypeInDifferentPkg]=...
                this.findOrCreateM3IType(name,...
                Integer.MetaClass,...
                createAppType,...
                onlyFind);

            elseif(embeddedObj.isDouble||embeddedObj.isSingle)
                [m3iType,isTypeInDifferentPkg]=...
                this.findOrCreateM3IType(name,...
                FloatingPoint.MetaClass,...
                createAppType,...
                onlyFind);

            elseif embeddedObj.isBoolean
                [m3iType,isTypeInDifferentPkg]=...
                this.findOrCreateM3IType(name,...
                Boolean.MetaClass,...
                createAppType,...
                onlyFind);

            elseif embeddedObj.isInteger
                autosar.mm.sl2mm.TypeBuilder.doWordSizeCheck(this.ModelName,embeddedObj.Name,embeddedObj.WordLength);

                [m3iType,isTypeInDifferentPkg]=...
                this.findOrCreateM3IType(name,...
                Integer.MetaClass,...
                createAppType,...
                onlyFind);
            elseif embeddedObj.isFixed&&~embeddedObj.isScaledDouble
                autosar.mm.sl2mm.TypeBuilder.doWordSizeCheck(this.ModelName,embeddedObj.Name,embeddedObj.WordLength);

                if embeddedObj.Slope~=1||embeddedObj.Bias~=0
                    [m3iType,isTypeInDifferentPkg]=...
                    this.findOrCreateM3IType(name,...
                    FixedPoint.MetaClass,...
                    createAppType,...
                    onlyFind);
                else
                    [m3iType,isTypeInDifferentPkg]=...
                    this.findOrCreateM3IType(name,...
                    Integer.MetaClass,...
                    createAppType,...
                    onlyFind);
                end
            elseif embeddedObj.isScaledDouble
                this.msgStream.createError('RTW:autosar:unsupportedExportedDataType',...
                'ScaledDouble');
            else
                assert(false,DAStudio.message('RTW:autosar:unrecognizedExportedDataType',...
                'Numeric'));
            end

            if~onlyFind
                if~isTypeInDifferentPkg
                    m3iDataTypePkg.packagedElement.append(m3iType);
                end
            end


            if~isempty(m3iType)
                [slDesc,descSupported]=autosar.mm.util.DescriptionHelper.getSLDescForEmbeddedObj(...
                this.ModelName,embeddedObj,ObjName=name);
                if(descSupported)
                    autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                    m3iType,slDesc);
                end
            end
        end

        function m3iType=createMatrixType(this,embeddedObj,dim,name,...
            m3iDataTypePkg,m3iBaseType,...
            createAppType)


            import Simulink.metamodel.types.Matrix;

            [m3iType,isTypeInDifferentPkg]=...
            this.findOrCreateM3IType(name,...
            Matrix.MetaClass,...
            createAppType);

            m3iType.Dimensions.clear();
            m3iType.SymbolicDimensions.clear();
            if embeddedObj.isMatrix
                if embeddedObj.HasSymbolicDimensions
                    this.addSymbolicDimensions(dim{1},m3iType);
                else
                    m3iType.Dimensions.append(dim);
                end
            else
                dims=1;
                m3iType.Dimensions.append(dims);
            end

            m3iType.BaseType=m3iBaseType;
            if~isTypeInDifferentPkg
                m3iDataTypePkg.packagedElement.append(m3iType);
            end

            if~isempty(m3iType)
                [slDesc,descSupported]=autosar.mm.util.DescriptionHelper.getSLDescForEmbeddedObj(...
                this.ModelName,embeddedObj,ObjName=name);
                if(descSupported)
                    autosar.mm.util.DescriptionHelper.createOrUpdateM3IDescriptionForM3iType(...
                    m3iType,slDesc);
                end
            end
        end


        function m3iType=createVoidPointerType(this,embeddedObj,name,...
            m3iDataTypePkg,...
            createAppType)

            assert(embeddedObj.isPointer&&...
            embeddedObj.BaseType.isVoid,'Expected embedded.voidtype');


            import Simulink.metamodel.types.VoidPointer;

            [m3iType,isTypeInDifferentPkg]=...
            this.findOrCreateM3IType(name,...
            VoidPointer.MetaClass,...
            createAppType);

            this.SwBaseTypeBuilder.addSwBaseType(m3iType);
            if~isTypeInDifferentPkg
                m3iDataTypePkg.packagedElement.append(m3iType);
            end
        end

        function[m3iType,isTypeInDifferentPkg]=...
            findOrCreateM3IType(this,typeName,m3iMetaClass,createAppType,onlyFind)

            if nargin<5

                onlyFind=false;
            end

            if onlyFind

                m3iType=[];
            end


            isTypeInDifferentPkg=false;


            if createAppType
                typesPkg=this.m3iAppDataTypePkg;
            else
                typesPkg=this.m3iDataTypePkg;
            end
            seq=autosar.mm.Model.findObjectByNameAndMetaClass(...
            typesPkg,typeName,m3iMetaClass,true);



            found=this.isM3iTypeInSeq(seq,createAppType);
            if~found
                arPkg=this.m3iModel.RootPackage.at(1);
                assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
                seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,typeName,m3iMetaClass);
                found=this.isM3iTypeInSeq(seq,createAppType);
            end
            m3iMetaClassName=m3iMetaClass.qualifiedName;
            if~found&&~createAppType&&...
                strcmp(m3iMetaClassName,'Simulink.metamodel.types.FixedPoint')



                m3iIntMetaClass=Simulink.metamodel.types.Integer.MetaClass;
                seq=autosar.mm.Model.findObjectByNameAndMetaClass(...
                typesPkg,typeName,m3iIntMetaClass,true);

                found=this.isM3iTypeInSeq(seq,createAppType);
                if~found
                    seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,typeName,m3iIntMetaClass);
                    found=this.isM3iTypeInSeq(seq,createAppType);
                end
            end
            if~found

                if~onlyFind
                    m3iType=eval([m3iMetaClassName,'(this.m3iModel)']);
                    m3iType.Name=typeName;
                end
            elseif(seq.size==1)
                if~this.NeedToCreateAppType

                    m3iType=seq.at(1);
                    isTypeInDifferentPkg=true;
                else




                    isAppType=seq.at(1).IsApplication;
                    if(createAppType==isAppType)

                        m3iType=seq.at(1);
                        isTypeInDifferentPkg=true;
                    else

                        if~onlyFind
                            m3iType=eval([m3iMetaClassName,'(this.m3iModel)']);
                            m3iType.Name=typeName;
                        end
                    end
                end
            elseif(seq.size==2)&&...
                seq.at(1).IsApplication||seq.at(2).IsApplication

                isAppType=seq.at(1).IsApplication;
                if(createAppType==isAppType)

                    m3iType=seq.at(1);
                    isTypeInDifferentPkg=true;
                else
                    isAppType=seq.at(2).IsApplication;

                    if(createAppType==isAppType)

                        m3iType=seq.at(2);
                        isTypeInDifferentPkg=true;
                    else
                        assert(false,['Two type objects with name: ',typeName]);
                    end
                end
            else


                if~onlyFind
                    m3iType=eval([m3iMetaClassName,'(this.m3iModel)']);
                    m3iType.Name=typeName;
                end
            end

            if~isTypeInDifferentPkg

                anyObj=autosar.mm.Model.findChildByName(typesPkg,typeName,true);
                if~isempty(anyObj)
                    pkgName=autosar.api.Utils.getQualifiedName(typesPkg);


                    if~onlyFind&&m3iType.isvalid()
                        m3iType.destroy();
                    end




                    DAStudio.error('RTW:autosar:errorDuplicateTypeInPackage',...
                    typeName,regexprep(pkgName,'^AUTOSAR',''));
                end
            end
        end

        function m3iImpType=findAR4PlatformType(this,RTWTypeName)


            platformTypeName=autosar.mm.util.BuiltInTypeMapper.getAR4PlatformTypeName(RTWTypeName);

            switch platformTypeName
            case{'boolean'}
                m3iMetaClass=Simulink.metamodel.types.Boolean.MetaClass;
            case{'uint8','uint16','uint32','uint64',...
                'sint8','sint16','sint32','sint64'}
                m3iMetaClass=Simulink.metamodel.types.Integer.MetaClass;
            case{'float32','float64'}
                m3iMetaClass=Simulink.metamodel.types.FloatingPoint.MetaClass;
            otherwise
                assert(false,'Did not recognize platform type %s',platformTypeName);
            end

            arPkg=this.m3iModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,platformTypeName,m3iMetaClass);
            [~,m3iImpType]=this.isM3iTypeInSeq(seq,false);
        end

        function m3iImpType=findAdaptivePlatformType(this,RTWTypeName)


            platformTypeName=autosar.mm.util.BuiltInTypeMapper.getAdaptivePlatformTypeName(RTWTypeName);

            switch platformTypeName
            case{'bool'}
                m3iMetaClass=Simulink.metamodel.types.Boolean.MetaClass;
            case{'uint8_t','uint16_t','uint32_t','uint64_t',...
                'int8_t','int16_t','int32_t','int64_t'}
                m3iMetaClass=Simulink.metamodel.types.Integer.MetaClass;
            case{'float','double'}
                m3iMetaClass=Simulink.metamodel.types.FloatingPoint.MetaClass;
            otherwise
                assert(false,'Did not recognize platform type %s',platformTypeName);
            end

            arPkg=this.m3iModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,platformTypeName,m3iMetaClass);
            [~,m3iImpType]=this.isM3iTypeInSeq(seq,false);
        end

        function setCompuMethodSlDataTypes(this,m3iType,embeddedObj)

            embeddedTypName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            if~isempty(m3iType.CompuMethod)&&...
                m3iType.CompuMethod.Category~=Simulink.metamodel.types.CompuMethodCategory.RatFunc&&...
                autosar.ui.metamodel.SimulinkDataType.isAllowedSlTypeName(...
                this.ModelName,embeddedTypName)
                slDataTypes=autosar.mm.util.ExternalToolInfoAdapter.get(...
                m3iType.CompuMethod,'SlDataTypes');
                if~ismember(embeddedTypName,slDataTypes)
                    autosar.mm.util.setCompuMethodSlDataType(this.m3iModel,...
                    m3iType.CompuMethod,{embeddedTypName},true);
                end
            end
        end

        function newM3IType=copyM3ITypeAndUpdateAdditionalNativeTypeQualifier(this,oldM3IType,typeQualifier,mangledTypeName)






            newM3IType=autosar.mm.sl2mm.TypeBuilder.copyM3IElementProperties(oldM3IType);


            qualifierFields=fields(typeQualifier);
            for ii=1:length(qualifierFields)
                propName=qualifierFields{ii};

                newM3IType.(propName)=typeQualifier.(propName);
            end

            newM3IType.Name=mangledTypeName;
            this.SwBaseTypeBuilder.addSwBaseType(newM3IType);
            this.m3iDataTypePkg.packagedElement.append(newM3IType);
        end

        function mapTypeInInterfaceDictionary(this,embeddedObj,m3iType)
            dataTypeNames=this.ArchitectureDictionaryAPI.getDataTypeNames();
            if ismember(embeddedObj.Name,dataTypeNames)
                this.ARClassicPlatformMappingSyncer.syncDataType(embeddedObj.Name,PlatformEntryId=M3I.SerializeId(m3iType));
            end
        end

        function[m3iLUT,m3iImpType]=findOrCreateLookupTableTypeFromAppTypeAttributes(this,slAppTypeAttributes,slBreakpointNames)












            import autosar.mm.Model;
            import autosar.mm.util.XmlOptionsAdapter;

            arRoot=this.m3iModel.RootPackage.at(1);
            applPkg=XmlOptionsAdapter.get(arRoot,...
            'ApplicationDataTypePackage');
            if isempty(applPkg)
                defaultApplPkg=[arRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.ApplicationDataTypes];
                XmlOptionsAdapter.set(arRoot,...
                'ApplicationDataTypePackage',...
                defaultApplPkg);
                applPkg=defaultApplPkg;
            end
            this.m3iAppDataTypePkg=Model.getOrAddARPackage(arRoot,applPkg);

            m3iLUT=this.LookupTableBuilder.findOrCreateLookupTableType(slAppTypeAttributes,slBreakpointNames);
            if isempty(m3iLUT)
                m3iImpType=[];
                return;
            end
            codeDescLUTObj=slAppTypeAttributes.LookupTableData;
            [embeddedObj,identifier,codeType]=this.LookupTableBuilder.getEmbeddedObjForTable(codeDescLUTObj);
            [min,max]=this.getLUTObjMinMaxValues(codeDescLUTObj);
            this.findOrCreateLUTBaseType(m3iLUT,identifier,embeddedObj,codeType,min,max);
            m3iLUT.ValueAxisDataType=this.findOrCreateAppTypeForAxisAttribute(embeddedObj,codeType,min,max,codeDescLUTObj.Unit);
            this.addM3iAxisTypeAttributesToM3iLUTBaseType(m3iLUT.ValueAxisDataType,m3iLUT.BaseType);
            axisCount=codeDescLUTObj.Breakpoints.Size();
            for jj=1:axisCount
                bp=codeDescLUTObj.Breakpoints.at(jj);
                [min,max]=this.getLUTObjMinMaxValues(bp);
                swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,jj);
                m3iAxis=m3iLUT.Axes.at(swappedIndex);

                if strcmp(codeDescLUTObj.BreakpointSpecification,'Reference')
                    [embeddedObj,embeddedArrayObj,identifier,codeType]=this.LookupTableBuilder.getEmbeddedObjForBP(codeDescLUTObj,jj);
                    this.findOrCreateLUTBaseType(m3iAxis.SharedAxis.Axis,identifier,embeddedObj,codeType,min,max);
                    m3iAxis.SharedAxis.ValueAxisDataType=this.findOrCreateAppTypeForAxisAttribute(embeddedObj,codeType,min,max,bp.Unit);
                    m3iAxis.SharedAxis.Axis.InputVariableType=m3iAxis.SharedAxis.ValueAxisDataType;
                    this.addM3iAxisTypeAttributesToM3iLUTBaseType(m3iAxis.SharedAxis.ValueAxisDataType,m3iAxis.SharedAxis.Axis.BaseType);
                    [hasSymbolicDimensions,symbolicWidth]=autosar.mm.sl2mm.LookupTableBuilder.getSymbolicDimensionsForSharedAxis(embeddedArrayObj);
                    if hasSymbolicDimensions
                        m3iAxis.SharedAxis.Axis.SymbolicDimensions.clear();
                        this.addSymbolicDimensions(symbolicWidth,m3iAxis.SharedAxis.Axis);
                    end
                else
                    [embeddedObj,embeddedArrayObj,identifier,codeType]=this.LookupTableBuilder.getEmbeddedObjForBP(codeDescLUTObj,swappedIndex);
                    this.findOrCreateLUTBaseType(m3iAxis,identifier,embeddedObj,codeType,min,max);
                    m3iAxis.InputVariableType=this.findOrCreateAppTypeForAxisAttribute(embeddedObj,codeType,min,max,bp.Unit);
                    this.addM3iAxisTypeAttributesToM3iLUTBaseType(m3iAxis.InputVariableType,m3iAxis.BaseType);
                    if~isempty(embeddedArrayObj)&&isa(embeddedArrayObj,'coder.descriptor.types.Matrix')&&embeddedArrayObj.HasSymbolicDimensions
                        m3iAxis.SymbolicDimensions.clear();
                        this.addSymbolicDimensions(embeddedArrayObj.SymbolicWidth,m3iAxis);
                    end
                end
            end

            m3iImpType=this.findOrCreateImpTypeForLookupTableObj(codeDescLUTObj);
            this.NeedToCreateAppType=true;
            this.updateDataTypeMap(m3iLUT,m3iImpType);
            m3iLUT.SwRecordLayout=this.SwRecordLayoutBuilder.buildM3iSwRecordLayout(codeDescLUTObj,m3iImpType);
            axisCount=codeDescLUTObj.Breakpoints.Size();
            for jj=1:axisCount
                swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,jj);
                m3iAxis=m3iLUT.Axes.at(swappedIndex);
                bp=codeDescLUTObj.Breakpoints.at(jj);
                if isa(m3iAxis.SharedAxis,'Simulink.metamodel.types.SharedAxisType')
                    axisM3iImpType=this.findOrCreateImpTypeForLookupTableObj(bp);
                    this.NeedToCreateAppType=true;
                    this.updateDataTypeMap(m3iAxis.SharedAxis,axisM3iImpType);
                    m3iAxis.SharedAxis.SwRecordLayout=this.SwRecordLayoutBuilder.buildM3iSwRecordLayout(bp,axisM3iImpType);
                end
            end
        end

        function m3iImpType=findOrCreateImpTypeForLookupTableObj(this,codeDescLUTObj)
            codeDescImpType=codeDescLUTObj.Implementation.Type;
            this.NeedToCreateAppType=false;
            slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;

            [m3iImpType,~]=this.findOrCreateImpAndAppTypes(codeDescImpType,...
            codeDescLUTObj.Implementation.CodeType,slAppTypeAttributes);
            this.addSwRecordLayoutAnnotationsToLookupTableImplType(codeDescLUTObj,m3iImpType);
        end

        function createOrUpdateNamespaces(this,codeDescriptorType,m3iImpType)



            if~this.IsAdaptive

                return;
            end

            if codeDescriptorType.isMatrix



                return;
            end

            namespaces=autosar.mm.sl2mm.TypeBuilder.getNamespacesFromIdentifier(codeDescriptorType.Identifier);

            if isempty(namespaces)



                numNamespaces=m3iImpType.Namespaces.size();
                for idx=1:numNamespaces
                    m3iImpType.Namespaces.at(1).destroy();
                end
            elseif length(namespaces)==1&&strcmp(namespaces{1},'std')

                assert(slfeature('BoolAndFixedWidthDataTypes')||...
                startsWith(codeDescriptorType.Identifier,'std::array<'),...
                'Expected feature to be on or matrix type');
                numNamespaces=m3iImpType.Namespaces.size();
                for idx=1:numNamespaces
                    m3iImpType.Namespaces.at(1).destroy();
                end
            else


                m3iNamespaceSymbols=m3i.mapcell(@(x)x.Symbol,m3iImpType.Namespaces);
                assert(isequal(namespaces,m3iNamespaceSymbols),...
                'Unexpected namespaces from code descriptor');
            end
        end
    end

    methods(Static,Access=private)
        function newM3IElement=copyM3IElementProperties(oldM3IElement)




            mc=oldM3IElement.MetaClass;

            newM3IElement=eval([mc.qualifiedName,'(oldM3IElement.modelM3I)']);

            m3iOwnedAttributes=mc.ownedAttribute();
            for ii=1:m3iOwnedAttributes.size()
                m3iCurAttr=m3iOwnedAttributes.at(ii);
                if~isprop(oldM3IElement,m3iCurAttr.name)
                    if strcmp(m3iCurAttr.name,'externalToolInfo')
                        m3iSrcValueSeq=oldM3IElement.get('externalToolInfo');
                        for valIdx=1:m3iSrcValueSeq.size()
                            externalToolInfoStr=m3iSrcValueSeq.at(valIdx).toString;
                            externalToolInfoParts=split(externalToolInfoStr,'|');
                            externalToolID=externalToolInfoParts{1};
                            if strcmp(externalToolID,'ARXML')


                            else
                                newM3IElement.setExternalToolInfo(...
                                M3I.ExternalToolInfo.fromString(externalToolInfoStr));
                            end
                        end
                    end
                    continue;
                end
                m3iCurPropValue=oldM3IElement.(m3iCurAttr.name);
                isReadOnly=m3iCurAttr.isReadOnly;
                isDerived=m3iCurAttr.isDerived;
                isValid=true;
                if ismethod(m3iCurPropValue,'isvalid')

                    isValid=m3iCurPropValue.isvalid();
                end
                isEmpty=isempty(m3iCurPropValue);
                if ismethod(m3iCurPropValue,'isEmpty')

                    isEmpty=m3iCurPropValue.isEmpty();
                end
                if isValid&&~isReadOnly&&~isEmpty&&~isDerived
                    if ismethod(m3iCurPropValue,'size')&&isobject(m3iCurPropValue)



                        for itemIdx=1:m3iCurPropValue.size()
                            if isobject(m3iCurPropValue.at(itemIdx))



                                newM3IElement.(m3iCurAttr.name).append(...
                                autosar.mm.sl2mm.TypeBuilder.copyM3IElementProperties(m3iCurPropValue.at(itemIdx)));
                            else
                                newM3IElement.(m3iCurAttr.name).append(m3iCurPropValue.at(itemIdx));
                            end
                        end
                    else
                        newM3IElement.(m3iCurAttr.name)=m3iCurPropValue;
                    end
                end
            end
        end

        function[found,m3iType]=isM3iTypeInSeq(seq,isAppType)
            found=false;
            m3iType=[];
            for ii=1:seq.size()
                seqElem=seq.at(ii);
                if seqElem.IsApplication==isAppType
                    m3iType=seqElem;
                    found=true;
                    break;
                end
            end
        end

        function[mangleAppTypeName,slMinNumeric,slMaxNumeric]=shouldMangleAppTypeName(...
            m3iAppType,embeddedObj,modelName,slAppTypeAttributes)

            [mangleAppTypeName,...
            slMinNumeric,...
            slMaxNumeric]=...
            autosar.mm.util.MinMaxHelper.shouldMangleAppTypeName(...
            m3iAppType,embeddedObj,...
            modelName,slAppTypeAttributes.Min,slAppTypeAttributes.Max);
            if~isempty(slAppTypeAttributes.Name)


                mangleAppTypeName=false;
            end
        end

        function setMinMaxValues(m3iType,embeddedObj,isAppType,minVal,maxVal)

            if isAppType


                [typeLowerVal,typeUpperVal]=...
                autosar.mm.util.MinMaxHelper.getLowerUpperLimitsForNumericType(...
                embeddedObj,'RealWorldValue');
                if isempty(minVal)
                    minVal=typeLowerVal;
                end
                if isempty(maxVal)
                    maxVal=typeUpperVal;
                end
                if isempty(m3iType.minValue)||...
                    ~autosar.mm.util.MinMaxHelper.tolerantIsEqual(m3iType.minValue,minVal)
                    m3iType.minValue=minVal;
                end
                if isempty(m3iType.maxValue)||...
                    ~autosar.mm.util.MinMaxHelper.tolerantIsEqual(m3iType.maxValue,maxVal)
                    m3iType.maxValue=maxVal;
                end
            else
                [typeLowerVal,typeUpperVal]=...
                autosar.mm.util.MinMaxHelper.getLowerUpperLimitsForNumericType(...
                embeddedObj,'StoredInteger');
                m3iType.minValue=typeLowerVal;
                m3iType.maxValue=typeUpperVal;
            end
            m3iType.isMinOpen=false;
            m3iType.isMaxOpen=false;
        end

        function[min,max]=getLUTObjMinMaxValues(codeDescLUTObj)
            min=[];max=[];
            if~isempty(codeDescLUTObj.Range)
                if~isempty(codeDescLUTObj.Range.Min)
                    min=str2double(codeDescLUTObj.Range.Min);
                end
                if~isempty(codeDescLUTObj.Range.Max)
                    max=str2double(codeDescLUTObj.Range.Max);
                end
            end
        end

        function convertedLiterals=convertScopedEnumClassLiterals(enumStrings)



            convertedLiterals=cell(1,length(enumStrings));
            for ii=1:length(enumStrings)
                tokens=strsplit(enumStrings{ii},'::');
                convertedLiterals{ii}=tokens{end};
            end
        end

        function typeName=getTypeNameFromIdentifier(identifier)

            tokens=strsplit(identifier,'::');
            typeName=tokens{end};
        end

        function namespaces=getNamespacesFromIdentifier(identifier)

            tokens=strsplit(identifier,'::');
            namespaces=tokens(1:end-1);
        end
    end


    methods(Static,Access=public)

        function[appTypeName,isOptimized]=getFixedPointTypeName(embeddedObj,modelName,isAR4PlatformTypeNameStyle)

            isOptimized=false;
            if nargin<3
                isAR4PlatformTypeNameStyle=false;
            end

            embeddedTypeName=autosar.mm.sl2mm.TypeBuilder.getTypeNameFromIdentifier(embeddedObj.Identifier);
            if isAR4PlatformTypeNameStyle
                appTypeName=autosar.mm.util.BuiltInTypeMapper.convertToAutosarBuiltInTypeName(embeddedTypeName);
            else
                appTypeName=autosar.mm.util.BuiltInTypeMapper.convertToAutosarBuiltInTypeAR3Name(embeddedTypeName);
            end

            if embeddedObj.isFixed
                isTrueFxpt=(embeddedObj.Slope~=1)||(embeddedObj.Bias~=0);
                isUnSupportedWordsize=~ismember(embeddedObj.WordLength,[8,16,32]);
                isMappedToBuiltinInC=autosar.mm.util.BuiltInTypeMapper.isRTWBuiltIn(embeddedTypeName,modelName);


                if(isTrueFxpt||isUnSupportedWordsize)&&isMappedToBuiltinInC
                    appTypeName=upper(embeddedObj.Name);
                    isOptimized=true;
                end
            end
        end


        function updateNumericType(m3iType,embeddedObj,isAppType,slMin,slMax)

            import Simulink.metamodel.types.FloatingPointKind;
            import Simulink.metamodel.types.FixedPoint;



            if nargin<5
                slMin=[];
                slMax=[];
            end
            if embeddedObj.isChar
                m3iType.IsSigned=embeddedObj.Signed;
                m3iType.Length=Simulink.metamodel.types.DataSize();
                m3iType.Length.value=embeddedObj.WordLength;
            elseif embeddedObj.isSingle
                m3iType.Kind=FloatingPointKind.IEEE_Single;
                autosar.mm.sl2mm.TypeBuilder.setMinMaxValues(m3iType,...
                embeddedObj,isAppType,slMin,slMax);
            elseif embeddedObj.isDouble
                m3iType.Kind=FloatingPointKind.IEEE_Double;
                autosar.mm.sl2mm.TypeBuilder.setMinMaxValues(m3iType,...
                embeddedObj,isAppType,slMin,slMax);
            elseif embeddedObj.isBoolean
                autosar.mm.sl2mm.TypeBuilder.setMinMaxValues(m3iType,...
                embeddedObj,isAppType,slMin,slMax);
            elseif embeddedObj.isInteger
                m3iType.IsSigned=embeddedObj.Signedness;
                m3iType.Length=Simulink.metamodel.types.DataSize();
                m3iType.Length.value=embeddedObj.WordLength;
                autosar.mm.sl2mm.TypeBuilder.setMinMaxValues(m3iType,...
                embeddedObj,isAppType,slMin,slMax);
            elseif embeddedObj.isFixed
                if(embeddedObj.Slope~=1||embeddedObj.Bias~=0)&&...
                    isa(m3iType,'Simulink.metamodel.types.FixedPoint')
                    netSlope=power(2,double(-embeddedObj.FractionLength));
                    if netSlope==0
                        DAStudio.error('RTW:autosar:incorrectExportedSlope',embeddedObj.Name);
                    end

                    m3iType.Bias=embeddedObj.Bias;
                    m3iType.FractionLength=Simulink.metamodel.types.DataSize();
                    m3iType.FractionLength.value=-embeddedObj.FractionLength;
                    m3iType.FractionalSlope=embeddedObj.Slope/netSlope;
                end

                m3iType.IsSigned=embeddedObj.Signedness;
                m3iType.Length=Simulink.metamodel.types.DataSize();
                m3iType.Length.value=embeddedObj.WordLength;
                autosar.mm.sl2mm.TypeBuilder.setMinMaxValues(m3iType,...
                embeddedObj,isAppType,slMin,slMax);

                if m3iType.getMetaClass()==FixedPoint.MetaClass
                    assert(embeddedObj.Slope==m3iType.slope,...
                    'Fixed point slope not correct.');
                end

            end
        end

        function m3iMdg=findOrCreateModeDeclarationGroup(m3iModel,mdgName,...
            modeNames,modeValues,...
            defaultModeIndex)

            import autosar.mm.util.XmlOptionsAdapter;

            metaClsStr='Simulink.metamodel.arplatform.common.ModeDeclarationGroup';
            metaClass=feval(sprintf('%s.MetaClass',metaClsStr));
            m3iRoot=m3iModel.RootPackage.at(1);
            m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(m3iRoot,mdgName,metaClass);

            if(m3iSeq.size==0)

                arRoot=m3iModel.RootPackage.front();
                mdgPkg=XmlOptionsAdapter.get(arRoot,'ModeDeclarationGroupPackage');
                if isempty(mdgPkg)


                    applDtPkg=XmlOptionsAdapter.get(...
                    m3iRoot,'ApplicationDataTypePackage');
                    if isempty(applDtPkg)
                        applDtPkg=[m3iRoot.DataTypePackage,'/'...
                        ,autosar.mm.util.XmlOptionsDefaultPackages.ApplicationDataTypes];
                    end
                    mdgPkg=[applDtPkg,'/'...
                    ,autosar.mm.util.XmlOptionsDefaultPackages.ModeDeclarationGroups];
                    XmlOptionsAdapter.set(arRoot,'ModeDeclarationGroupPackage',mdgPkg);
                end

                m3iMDGPkg=autosar.mm.Model.getOrAddARPackage(m3iModel,mdgPkg);


                m3iMdg=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iMDGPkg,m3iMDGPkg.packagedElement,mdgName,...
                metaClsStr);
            elseif(m3iSeq.size==1)
                m3iMdg=m3iSeq.at(1);
            else
                assert(false,['Multiple MDG with name: ',mdgName]);
            end

            if m3iMdg.Mode.size()==numel(modeValues)


                if~autosar.mm.sl2mm.TypeBuilder.isModeGroupUpToDate(m3iMdg,modeNames,modeValues)

                    for ii=1:m3iMdg.Mode.size()
                        m3iMode=m3iMdg.Mode.at(ii);
                        m3iMode.Name=modeNames{ii};
                        m3iMode.Value=int32(modeValues(ii));
                    end
                end
            else
                clsName='Simulink.metamodel.arplatform.common.ModeDeclaration';
                seqMerger=autosar.mm.util.SequenceMerger(m3iModel,...
                m3iMdg.Mode,clsName);
                for ii=1:length(modeNames)
                    m3iModeDeclaration=seqMerger.mergeByName(modeNames{ii});
                    m3iModeDeclaration.Value=int32(modeValues(ii));
                end
            end
            m3iMdg.InitialMode=m3iMdg.Mode.at(defaultModeIndex);


            if isempty(m3iMdg.category)
                m3iMdg.category='EXPLICIT_ORDER';
            end
        end

        function isUpToDate=isModeGroupUpToDate(m3iMdg,modeNames,modeValues)



            isUpToDate=true;
            modeMetaClassStr='Simulink.metamodel.arplatform.common.ModeDeclaration';
            for ii=1:length(modeNames)
                m3iMode=...
                Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iMdg.modelM3I,m3iMdg.Mode,modeNames{ii},...
                modeMetaClassStr);
                isUpToDate=isUpToDate&&...
                m3iMode.isvalid()&&...
                ~isempty(m3iMode.Value)&&...
                m3iMode.Value==int32(modeValues(ii));
            end
        end

        function doWordSizeCheck(ModelName,ObjectName,WordLength)




            if WordLength<0||WordLength>64
                DAStudio.error('autosarstandard:validation:incorrectExportedWordSize',...
                ObjectName,int2str(WordLength));
            elseif strcmp(get_param(ModelName,'TargetLongLongMode'),'off')&&WordLength>32
                DAStudio.error('autosarstandard:validation:incorrectTargetLongLongMode');
            end
        end

        function embeddedTypeObj=getCodeType(implementationObj)



            embeddedTypeObj=implementationObj.CodeType;
            if isempty(embeddedTypeObj)

                embeddedTypeObj=implementationObj.Type;
            end
        end

        function[min,max]=rectifyMinMaxValuesForLookupTableAttributes(min,max)

            if~isempty(min)&&min==-Inf
                min=[];
            end
            if~isempty(max)&&max==Inf
                max=[];
            end
        end

        function addM3iAxisTypeAttributesToM3iLUTBaseType(m3iAxisAttributeType,m3iLUTBaseType)


            if m3iAxisAttributeType.DataConstr.isvalid()
                m3iLUTBaseType.DataConstr=m3iAxisAttributeType.DataConstr;
            end
            if m3iAxisAttributeType.CompuMethod.isvalid()
                m3iLUTBaseType.CompuMethod=m3iAxisAttributeType.CompuMethod;
            end
        end

        function structElemCodeType=getStructElementCodeType(structCodeType,structElementIdx)
            if isempty(structCodeType)
                structElemCodeType=[];
                return;
            end

            if(isa(structCodeType,'coder.descriptor.types.Struct'))
                structElemCodeType=structCodeType.Elements(structElementIdx).Type;
            elseif isa(structCodeType,'coder.descriptor.types.ContainerClass')&&...
                isprop(structCodeType,'ReferenceType')

                structElemCodeType=autosar.mm.sl2mm.TypeBuilder.getStructElementCodeType(...
                structCodeType.ReferenceType.BaseType,structElementIdx);
            else
                assert(false,'struct element expected to be here');
            end
        end

        function baseCodeType=getMatrixBaseCodeType(codeType,dimensionArray)
            if isempty(codeType)
                baseCodeType=[];
                return;
            end

            if isa(codeType,'coder.descriptor.types.Matrix')
                baseCodeType=codeType.BaseType;
            elseif isa(codeType,'coder.descriptor.types.ContainerClass')&&...
                isprop(codeType,'ReferenceType')

                baseCodeType=autosar.mm.sl2mm.TypeBuilder.getMatrixBaseCodeType(...
                codeType.ReferenceType,dimensionArray);
            else
                assert(prod(dimensionArray)==1,...
                'Expect code Descriptor special case matrices of width 1');
                baseCodeType=codeType;
            end
        end

        function isCompatible=isEnumImpTypeCompatible(m3iImpType,embeddedObj)


            isCompatible=false;

            if m3iImpType.Length.value==embeddedObj.StorageType.WordLength...
                &&m3iImpType.IsSigned==embeddedObj.StorageType.Signedness...
                &&(isa(m3iImpType,'Simulink.metamodel.types.Integer')||...
                isa(m3iImpType,'Simulink.metamodel.types.Enumeration')||...
                (isa(m3iImpType,'Simulink.metamodel.types.FixedPoint')...
                &&m3iImpType.slope==1&&m3iImpType.Bias==0))
                isCompatible=true;

                if isa(m3iImpType,'Simulink.metamodel.types.Enumeration')


                    if isa(embeddedObj,'coder.descriptor.types.Enum')
                        strings=embeddedObj.Strings.toArray;
                    else
                        strings=embeddedObj.Strings;
                    end

                    for elIdx=1:m3iImpType.OwnedLiteral.size()
                        m3iLiteral=m3iImpType.OwnedLiteral.at(elIdx);
                        isEquivalent=isequal(m3iLiteral.Name,strings{elIdx})&&...
                        isequal(m3iLiteral.Value,embeddedObj.Values(elIdx));

                        if~isEquivalent
                            isCompatible=false;
                            break
                        end
                    end
                end
            end
        end

        function m3iImpType=configureImpTypeForCodeType(m3iImpType,embeddedObj)
            dataSize=Simulink.metamodel.types.DataSize();
            dataSize.value=embeddedObj.StorageType.WordLength;
            m3iImpType.Length=dataSize;
            m3iImpType.IsSigned=embeddedObj.StorageType.Signedness;
            [m3iImpType.minValue,m3iImpType.maxValue]=...
            autosar.utils.Math.toLowerAndUpperLimit(m3iImpType.IsSigned,...
            double(m3iImpType.Length.value));
            m3iImpType.isMinOpen=false;
            m3iImpType.isMaxOpen=false;
        end
    end
end







