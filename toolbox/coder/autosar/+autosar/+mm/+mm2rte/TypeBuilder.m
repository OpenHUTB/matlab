classdef TypeBuilder<autosar.mm.mm2rte.RTEBuilder




    properties(Access='private')
        RefTypesQNameToM3iTypeMap;
        App2ImpTypeQNameMap;
        ImpTypeQNameToM3iTypeMap;
        Mdg2ImpTypeQNameMap;
        LiteralPrefixHelper;
        SystemConstantUsed;
        IsAdaptive;
    end

    methods(Access='public')
        function this=TypeBuilder(rteGenerator,m3iComponent)
            this=this@autosar.mm.mm2rte.RTEBuilder(rteGenerator,m3iComponent);
            this.RefTypesQNameToM3iTypeMap=containers.Map;
            this.App2ImpTypeQNameMap=containers.Map();
            this.ImpTypeQNameToM3iTypeMap=containers.Map();
            this.Mdg2ImpTypeQNameMap=containers.Map;
            this.RTEData=autosar.mm.mm2rte.TypeData;



            m3iModel=m3iComponent.rootModel;
            m3iDataTypeMappingSeq=M3I.SequenceOfClassObject.make(m3iModel);
            autosar.mm.arxml.Exporter.findByBaseType(...
            m3iDataTypeMappingSeq,m3iModel,...
            'Simulink.metamodel.arplatform.common.DataTypeMappingSet');
            for mIdx=1:m3iDataTypeMappingSeq.size()
                dtMapVec=m3iDataTypeMappingSeq.at(mIdx).dataTypeMap;


                for idx=1:dtMapVec.size
                    dtMap=dtMapVec.at(idx);
                    appTypeQName=dtMap.ApplicationType.qualifiedName;
                    impTypeQName=dtMap.ImplementationType.qualifiedName;
                    this.App2ImpTypeQNameMap(appTypeQName)=impTypeQName;
                    this.ImpTypeQNameToM3iTypeMap(impTypeQName)=dtMap.ImplementationType;
                end


                modeTypeMap=m3iDataTypeMappingSeq.at(mIdx).ModeRequestTypeMap;
                for idx=1:modeTypeMap.size()
                    dtMap=modeTypeMap.at(idx);
                    mdgTypeQName=dtMap.ModeGroupType.qualifiedName;
                    impTypeQName=dtMap.ImplementationType.qualifiedName;
                    this.Mdg2ImpTypeQNameMap(mdgTypeQName)=impTypeQName;
                    this.ImpTypeQNameToM3iTypeMap(impTypeQName)=dtMap.ImplementationType;
                end
            end

            this.LiteralPrefixHelper=autosar.mm.util.LiteralPrefixHelper(m3iComponent);
            this.SystemConstantUsed=false;

            adaptiveComponents=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.component.AdaptiveApplication.MetaClass,true,true);
            this.IsAdaptive=adaptiveComponents.size~=0;
        end

        function[isAppType,impType]=isAppType(this,qName)
            autosar.mm.util.validateArg(qName,'char');
            impType=[];
            isAppType=this.App2ImpTypeQNameMap.isKey(qName);
            if isAppType
                impTypeQName=this.App2ImpTypeQNameMap(qName);
                impType=this.ImpTypeQNameToM3iTypeMap(impTypeQName);
            end
        end

        function addReferencedType(this,m3iType)
            assert(isa(m3iType,'Simulink.metamodel.foundation.ValueType')||...
            isa(m3iType,'Simulink.metamodel.arplatform.common.ModeDeclarationGroup'),...
            'Unsupported m3iType class %s for addReferencedType.',class(m3iType));

            qname=m3iType.qualifiedName;
            if~this.RefTypesQNameToM3iTypeMap.isKey(qname)
                this.RefTypesQNameToM3iTypeMap(qname)=m3iType;
                switch(class(m3iType))
                case 'Simulink.metamodel.types.Matrix'
                    if m3iType.Reference.isvalid

                        this.addReferencedType(m3iType.Reference);
                    else
                        this.addReferencedType(m3iType.BaseType);
                    end
                case 'Simulink.metamodel.types.Structure'
                    busElements=m3iType.Elements;
                    for i=1:busElements.size
                        busElement=busElements.at(i);
                        if~busElement.InlineType.isvalid()
                            this.addReferencedType(busElement.ReferencedType);
                        end
                    end
                case{'Simulink.metamodel.types.SharedAxisType',...
                    'Simulink.metamodel.types.LookupTableType'}
                    [isAppType,impType]=this.isAppType(m3iType.qualifiedName);
                    assert(isAppType,'%s should be an application type.',m3iType.qualifiedName);
                    this.addReferencedType(impType);
                case{'Simulink.metamodel.types.FixedPoint',...
                    'Simulink.metamodel.types.Integer',...
                    'Simulink.metamodel.types.FloatingPoint',...
                    'Simulink.metamodel.types.Enumeration',...
                    'Simulink.metamodel.types.Boolean',...
                    'Simulink.metamodel.arplatform.common.ModeDeclarationGroup',...
                    'Simulink.metamodel.types.VoidPointer',...
                    'Simulink.metamodel.types.String'}

                otherwise
                    assert(false,'Unknown m3iType "%s".',class(m3iType));
                end
            end
        end

        function typeInfo=getTypeInfo(this,m3iType)

            if isa(m3iType,'Simulink.metamodel.arplatform.common.ModeDeclarationGroup')


                typeInfo=this.getModeDeclGroupTypeInfo(m3iType);
            else
                autosar.mm.util.validateM3iArg(m3iType,...
                'Simulink.metamodel.foundation.ValueType');

                if this.IsMultiInstantiable
                    RteInstanceArg=[AUTOSAR.CSC.getRTEInstanceType,' ',...
                    AUTOSAR.CSC.getRTEInstanceName];
                else
                    RteInstanceArg='void';
                end


                [isApp,implType]=this.isAppType(m3iType.qualifiedName);
                if isApp
                    m3iType=implType;
                end


                typeInfo=struct(...
                'IsBus',false,...
                'IsArray',false,...
                'IsVoidPointer',false,...
                'UsePointerIO',false,...
                'BaseRteType',m3iType.Name,...
                'RteType',m3iType.Name,...
                'RteInstanceArg',RteInstanceArg,...
                'IsMultiInstantiable',this.IsMultiInstantiable);


                switch class(m3iType)
                case 'Simulink.metamodel.types.Matrix'
                    typeInfo.IsArray=true;
                    typeInfo.UsePointerIO=true;
                    m3iBaseType=autosar.mm.mm2sl.TypeBuilder.getUnderlyingType(m3iType);
                    typeInfo.BaseRteType=m3iBaseType.Name;
                    typeInfo.WidthStr=string(this.getWidth(m3iType));
                    typeInfo.DimensionsStr=string(this.getDimensions(m3iType));
                case 'Simulink.metamodel.types.Structure'
                    typeInfo.IsBus=true;
                    typeInfo.UsePointerIO=true;
                case 'Simulink.metamodel.types.VoidPointer'
                    typeInfo.IsVoidPointer=true;
                    typeInfo.UsePointerIO=true;
                    typeInfo.BaseRteType='void';
                otherwise

                end
            end
        end

        function needsSCDefs=needsSystemConstantDefs(this)
            needsSCDefs=this.SystemConstantUsed;
        end

        function RTEData=build(this)
            m3iTypes=this.RefTypesQNameToM3iTypeMap.values;

            for i=1:length(m3iTypes)
                m3iType=m3iTypes{i};
                this.addType(m3iType);
            end


            this.RTEData.reorderStructures;
            RTEData=this.RTEData;
        end
    end

    methods(Access='private')

        function addType(this,m3iType)
            qName=m3iType.qualifiedName;




            if~isa(m3iType,'Simulink.metamodel.types.Enumeration')
                [isAppType,impType]=this.isAppType(qName);
                if isAppType

                    m3iType=impType;
                end
            end

            if isa(m3iType,'Simulink.metamodel.types.Enumeration')
                addEnumerationType(this,m3iType);
            elseif isa(m3iType,'Simulink.metamodel.types.PrimitiveType')
                addPrimitiveType(this,m3iType);
            elseif isa(m3iType,'Simulink.metamodel.types.Matrix')

                if m3iType.Reference.isvalid
                    addMatrixType(this,m3iType.Reference);
                else
                    addMatrixType(this,m3iType);
                end
            elseif isa(m3iType,'Simulink.metamodel.types.Structure')
                addStructureType(this,m3iType);
            elseif isa(m3iType,'Simulink.metamodel.types.VoidPointer')
                addVoidPtrType(this,m3iType);
            elseif isa(m3iType,'Simulink.metamodel.arplatform.common.ModeDeclarationGroup')
                addModeDeclarationGroupType(this,m3iType);
            else
                assert(false,'Unsupported m3iType class: %s.',class(m3iType));
            end
        end

        function typeInfo=getModeDeclGroupTypeInfo(this,m3iMdg)
            autosar.mm.util.validateM3iArg(m3iMdg,...
            'Simulink.metamodel.arplatform.common.ModeDeclarationGroup');


            if this.IsMultiInstantiable
                RteInstanceArg=[AUTOSAR.CSC.getRTEInstanceType,' ',...
                AUTOSAR.CSC.getRTEInstanceName];
            else
                RteInstanceArg='void';
            end
            m3iImpType=this.ImpTypeQNameToM3iTypeMap(this.Mdg2ImpTypeQNameMap(m3iMdg.qualifiedName));
            implTypeName=m3iImpType.Name;
            typeInfo=struct(...
            'EnumName',m3iMdg.Name,...
            'ImpTypeName',implTypeName,...
            'StorageType','',...
            'EnumLiteralNames','',...
            'EnumLiteralValues','',...
            'OnTransitionName','',...
            'OnTransitionValue','',...
            'RteInstanceArg',RteInstanceArg);

            typeInfo.StorageType=this.getBaseTypeNameForEnumOrMdg(m3iMdg);

            enumLiteralNames=cell(1,m3iMdg.Mode.size());
            enumLiteralValues=zeros(1,m3iMdg.Mode.size());
            explicitOrder=false;
            for ii=1:m3iMdg.Mode.size()
                enumLiteralNames{ii}=['RTE_MODE_',m3iMdg.Name,'_',m3iMdg.Mode.at(ii).Name];
                if~isempty(m3iMdg.Mode.at(ii).Value)
                    enumLiteralValues(ii)=m3iMdg.Mode.at(ii).Value;
                    explicitOrder=true;
                end
            end




            if strcmp(m3iMdg.category,'EXPLICIT_ORDER')
                if~isempty(m3iMdg.OnTransitionValue)
                    typeInfo.OnTransitionName=['RTE_TRANSITION_',m3iMdg.Name];
                    typeInfo.OnTransitionValue=m3iMdg.OnTransitionValue;
                end
            elseif strcmp(m3iMdg.category,'ALPHABETIC_ORDER')
                typeInfo.OnTransitionName=['RTE_TRANSITION_',m3iMdg.Name];
                typeInfo.OnTransitionValue=m3iMdg.Mode.size();
            end
            if~explicitOrder
                sortedLiteralNames=sort(enumLiteralNames);
                [~,enumLiteralValues]=ismember(enumLiteralNames,sortedLiteralNames);
                enumLiteralValues=enumLiteralValues-1;
            end
            typeInfo.EnumLiteralNames=enumLiteralNames;
            typeInfo.EnumLiteralValues=enumLiteralValues;
        end

        function type=getBaseTypeNameForEnumOrMdg(this,m3iType)


            m3iImpType=[];
            if isa(m3iType,'Simulink.metamodel.types.Enumeration')
                if this.App2ImpTypeQNameMap.isKey(m3iType.qualifiedName)
                    m3iImpType=this.ImpTypeQNameToM3iTypeMap(...
                    this.App2ImpTypeQNameMap(m3iType.qualifiedName));
                end
            elseif isa(m3iType,'Simulink.metamodel.arplatform.common.ModeDeclarationGroup')
                if this.Mdg2ImpTypeQNameMap.isKey(m3iType.qualifiedName)
                    m3iImpType=this.ImpTypeQNameToM3iTypeMap(...
                    this.Mdg2ImpTypeQNameMap(m3iType.qualifiedName));
                end
            end
            enumStorageType=autosar.mm.util.getStorageTypeForEnumOrMdg(...
            m3iType,m3iImpType);
            type=autosar.mm.mm2rte.TypeBuilder.enumStorageTypeToPlatformType(enumStorageType);
        end

        function addPrimitiveType(this,m3iPrimitiveType)

            assert(~this.isAppType(m3iPrimitiveType.qualifiedName),...
            'should not process application types!');

            baseTypeName=autosarcore.mm.sl2mm.SwBaseTypeBuilder.getSwBaseTypeNameFromImpType(m3iPrimitiveType,this.IsAdaptive);

            dataItem=struct(...
            'Kind',...
            'Primitive',...
            'ImpTypeName',...
            m3iPrimitiveType.Name,...
            'BaseTypeName',...
            baseTypeName);
            this.RTEData.insertItem(dataItem);
        end

        function width=getWidth(this,m3iType)
            dimensions=this.getDimensions(m3iType);
            if m3iType.SymbolicDimensions.isEmpty()
                width=prod(dimensions);
            else
                width=strjoin(dimensions,'*');
            end
        end

        function dimensions=getDimensions(this,m3iType)
            dimensions=this.getInitDimensions(m3iType);
            dimensions=this.getDimensionsRecurseDimensions(m3iType,dimensions);
        end

        function initDimensions=getInitDimensions(~,m3iType)
            if m3iType.SymbolicDimensions.isEmpty()
                initDimensions=[];
            else
                initDimensions={};
            end
        end

        function dimensions=getDimensionsRecurseDimensions(this,m3iType,dimensions)
            if m3iType.SymbolicDimensions.isEmpty()
                for ii=1:m3iType.Dimensions.size()
                    dimensions=[dimensions,m3iType.Dimensions.at(ii)];%#ok<AGROW>
                end
            else
                this.SystemConstantUsed=true;
                for ii=1:m3iType.SymbolicDimensions.size()
                    val=autosar.mm.util.extractSystemConstantExpressionFromM3I(...
                    m3iType.SymbolicDimensions.at(ii));
                    dimensions=[dimensions,val];%#ok<AGROW>
                end
            end

            m3iBaseType=m3iType.BaseType;
            if isa(m3iBaseType,'Simulink.metamodel.types.Matrix')
                dimensions=this.getDimensionsRecurseDimensions(m3iBaseType,dimensions);
            end

        end

        function addMatrixType(this,m3iMatrixType)

            assert(~this.isAppType(m3iMatrixType.qualifiedName),...
            'should not process application types!');
            dimensions=string(this.getDimensions(m3iMatrixType));
            m3iBaseType=m3iMatrixType.BaseType;

            while isa(m3iBaseType,'Simulink.metamodel.types.Matrix')
                m3iBaseType=m3iBaseType.BaseType;
            end

            if isa(m3iBaseType,'Simulink.metamodel.types.Enumeration')
                baseTypeName=this.getBaseTypeNameForEnumOrMdg(m3iBaseType);
            elseif isa(m3iBaseType,'Simulink.metamodel.types.PrimitiveType')
                baseTypeName=autosarcore.mm.sl2mm.SwBaseTypeBuilder.getSwBaseTypeNameFromImpType(m3iBaseType,this.IsAdaptive);
            elseif isa(m3iBaseType,'Simulink.metamodel.types.Structure')
                baseTypeName=m3iBaseType.Name;
            else
                assert(false,'Unsupported m3iBaseType class %s for array type.',class(m3iBaseType));
            end


            this.addType(m3iBaseType);

            dataItem=struct(...
            'Kind',...
            'Array',...
            'ArrayTypeName',...
            m3iMatrixType.Name,...
            'ImpTypeName',...
            m3iBaseType.Name,...
            'BaseTypeName',...
            baseTypeName,...
            'Dimensions',...
            {dimensions});
            this.RTEData.insertItem(dataItem);
        end

        function addEnumerationType(this,m3iType)


            storageType=this.getBaseTypeNameForEnumOrMdg(m3iType);
            literalPrefix=this.LiteralPrefixHelper.getLiteralPrefix(m3iType);


            [isAppType,impType]=this.isAppType(m3iType.qualifiedName);
            m3iTypeForLiterals=m3iType;
            if isAppType
                if isa(impType,'Simulink.metamodel.types.Enumeration')
                    m3iTypeForLiterals=impType;
                end
                m3iType=impType;
                impTypeName=impType.Name;
            else
                impTypeName=m3iType.Name;
            end

            literals=m3iTypeForLiterals.OwnedLiteral;
            len=literals.size();
            nameValuePairs=cell(1,2*len);
            for ii=1:len
                nameValuePairs{2*ii-1}=[literalPrefix,literals.at(ii).Name];
                nameValuePairs{2*ii}=literals.at(ii).Value;
            end

            dataItem=autosar.mm.mm2rte.TypeData.createEnumDataItem(...
            m3iType.Name,impTypeName,storageType,nameValuePairs,'','');
            this.RTEData.insertItem(dataItem);
        end

        function addStructureType(this,m3iStructureType)

            assert(~this.isAppType(m3iStructureType.qualifiedName),...
            'should not process application types!');

            elems=m3iStructureType.Elements;
            elemStruct=struct(...
            'Name','',...
            'Type','',...
            'Dimensions','',...
            'IsBus',false,...
            'IsArray',false);

            elemsLength=elems.size;
            elemStructs=repmat(elemStruct,1,elemsLength);
            for ii=1:elemsLength
                elem=elems.at(ii);
                elemStructs(ii).Name=elem.Name;
                elemType=elem.ReferencedType();
                if isa(elemType,'Simulink.metamodel.types.Matrix')
                    m3iBottomType=autosar.mm.mm2sl.TypeBuilder.getUnderlyingType(elemType);


                    this.addType(m3iBottomType);

                    elemStructs(ii).Type=m3iBottomType.Name;
                    dims=string(this.getDimensions(elemType));
                    elemStructs(ii).Dimensions=dims;
                    elemStructs(ii).IsBus=isa(m3iBottomType,'Simulink.metamodel.types.Structure');
                    elemStructs(ii).IsArray=true;
                else

                    this.addType(elemType);

                    elemStructs(ii).Type=elemType.Name;
                    elemStructs(ii).Dimensions='';
                    elemStructs(ii).IsBus=isa(elemType,'Simulink.metamodel.types.Structure');
                    elemStructs(ii).IsArray=false;
                end
            end
            dataItem=struct(...
            'Kind',...
            'Structure',...
            'name',...
            m3iStructureType.Name,...
            'Elements',...
            elemStructs);
            this.RTEData.insertItem(dataItem);
        end

        function addVoidPtrType(this,m3iVoidPtrType)
            dataItem=struct(...
            'Kind',...
            'VoidPointer',...
            'ImpTypeName',...
            m3iVoidPtrType.Name,...
            'BaseTypeName',...
            'void');
            this.RTEData.insertItem(dataItem);
        end

        function addModeDeclarationGroupType(this,m3iMdgType)
            typeInfo=this.getTypeInfo(m3iMdgType);
            len=length(typeInfo.EnumLiteralNames);
            nameValuePairs=cell(1,2*len);
            for ii=1:len
                nameValuePairs{2*ii-1}=typeInfo.EnumLiteralNames{ii};
                nameValuePairs{2*ii}=typeInfo.EnumLiteralValues(ii);
            end
            m3iImpType=this.ImpTypeQNameToM3iTypeMap(...
            this.Mdg2ImpTypeQNameMap(m3iMdgType.qualifiedName));
            impTypeName=m3iImpType.Name;
            dataItem=autosar.mm.mm2rte.TypeData.createEnumDataItem(...
            typeInfo.EnumName,impTypeName,typeInfo.StorageType,nameValuePairs,...
            typeInfo.OnTransitionName,typeInfo.OnTransitionValue);
            this.RTEData.insertItem(dataItem);
        end
    end

    methods(Static)


        function typeStr=getAutosarType(usePointerIO,...
            isArray,isVoidPtr,rteType,baseRteType,addConstIfNeeded)
            if usePointerIO
                if isArray||isVoidPtr
                    typeStr=[baseRteType,'*'];
                else
                    typeStr=[rteType,'*'];
                end

                if addConstIfNeeded
                    typeStr=['const ',typeStr];
                end
            else
                typeStr=rteType;
            end
        end
    end

    methods(Static,Access='private')
        function type=enumStorageTypeToPlatformType(enumStorageType)

            type='sint32';
            if~isempty(enumStorageType)
                switch(enumStorageType)
                case 'int32'
                    type='sint32';
                case 'int16'
                    type='sint16';
                case 'int8'
                    type='sint8';
                case 'uint16'
                    type='uint16';
                case 'uint8'
                    type='uint8';
                otherwise
                    assert(false,'Unexpected storage type %s for enum.',enumStorageType);
                end
            end
        end
    end
end



