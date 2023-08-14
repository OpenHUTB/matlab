classdef IncludedTypeSetBuilder<handle





    properties(Access=private)
        CodeDescriptorCache;
        ModelName;
        M3iBehavior;
        M3iTypesToBeIncludedMap;
        TypeBuilder;
        AutosarUtilsValidator autosar.validation.AutosarUtils;
    end

    methods(Access=public)
        function this=IncludedTypeSetBuilder(modelName,m3iBehavior,typeBuilder,codeDescriptorCache)
            this.ModelName=modelName;
            this.M3iBehavior=m3iBehavior;
            this.TypeBuilder=typeBuilder;
            this.M3iTypesToBeIncludedMap=containers.Map;
            this.CodeDescriptorCache=codeDescriptorCache;
            this.AutosarUtilsValidator=autosar.validation.AutosarUtils(modelName);
        end

        function buildOrUpdateIncludedDataTypeSets(this,codeDescObj)



            this.buildInternalDataTypes(codeDescObj);
            this.addBuiltM3iTypesToIncludedDataTypeSets();
        end
    end

    methods(Access=private)



        function buildInternalDataTypes(this,codeDescObj)


            codeDescInternalDataSeq=codeDescObj.getDataInterfaces('InternalData');
            this.buildInternalDataSeq(codeDescInternalDataSeq);

            referencedModelNames=unique(codeDescObj.getReferencedModelNames());
            for modelIndex=1:numel(referencedModelNames)
                modelName=referencedModelNames{modelIndex};
                refModelCodeDescObj=...
                this.CodeDescriptorCache.getRefModelCodeDescriptor(modelName,codeDescObj);
                this.buildInternalDataTypes(refModelCodeDescObj);
            end
        end

        function buildInternalDataSeq(this,codeDescInternalDataSeq)


            for dataIdx=1:numel(codeDescInternalDataSeq)
                if this.hasValidInternalDataType(codeDescInternalDataSeq(dataIdx))
                    implementation=codeDescInternalDataSeq(dataIdx).Implementation;
                    m3iType=this.createM3iType(implementation.Type,implementation.CodeType);
                    this.M3iTypesToBeIncludedMap(m3iType.Name)=m3iType;
                end
            end
        end

        function isValid=hasValidInternalDataType(this,codeDescInternalData)
            if this.hasNonEmptyImplementationTypeName(codeDescInternalData)&&...
                this.isValidImplementation(codeDescInternalData.Implementation)
                isValid=true;
            else
                isValid=false;
            end
        end

        function isValid=isValidImplementation(this,implementation)


            baseType=this.getBaseType(implementation.Type);
            if this.hasDefaultHeader(baseType)&&...
                ~this.isTypeBuiltIn(baseType,this.ModelName)&&...
                ~this.containsPreBuiltType(implementation)
                isValid=true;
            else
                isValid=false;
            end
        end

        function hasDefault=hasDefaultHeader(this,codeDescType)

            hasDefault=true;

            skipInterfaceDictionaryHeaderCheck=...
            this.AutosarUtilsValidator.skipHeaderFileCheck(codeDescType.Name);

            if~skipInterfaceDictionaryHeaderCheck
                headerFile=this.getHeaderFile(codeDescType);
                hasDefault=strcmp(headerFile,'Rte_Type.h');
            end
        end

        function headerFile=getHeaderFile(this,codeDescType)
            [typeExists,workspaceTypeObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,codeDescType.Name);
            headerFile='';
            if typeExists
                headerFile=get(workspaceTypeObj,'HeaderFile');
            end
            if Simulink.data.isSupportedEnumClass(codeDescType.Name)
                headerFile=Simulink.data.getEnumTypeInfo(codeDescType.Name,'HeaderFile');
            end
        end

        function isBuilt=containsPreBuiltType(this,codeDescImplementation)

            m3iTypeName=this.getM3iTypeNameFromImplementation(codeDescImplementation);

            m3iBuiltTypeNames=this.TypeBuilder.M3iBuiltTypeNames.getTypeNames();
            isBuilt=any(strcmp(m3iBuiltTypeNames,m3iTypeName));
        end

        function m3iTypeName=getM3iTypeNameFromImplementation(this,codeDescImplementation)

            codeDescType=codeDescImplementation.Type;
            if codeDescType.isMatrix||codeDescType.isPointer
                m3iTypeName=this.getMatrixM3iTypeNameFromImplementation(codeDescImplementation);
            else
                m3iTypeName=codeDescType.Name;
            end
        end

        function m3iTypeName=getMatrixM3iTypeNameFromImplementation(this,codeDescImplementation)


            codeDescType=codeDescImplementation.Type;
            dimensionArray=...
            autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.getDimensionArray(codeDescType,...
            codeDescImplementation.CodeType);
            dimid=autosar.mm.sl2mm.variant.Utils.getDimensionsIdentifier(codeDescType,dimensionArray);
            baseType=this.getBaseType(codeDescType);
            m3iTypeName=this.TypeBuilder.getMatrixIdentifier(baseType.Name,dimid);
        end



        function m3iType=createM3iType(this,codeDescType,codeDescCodeType)



            [datatypeObjExists,datatypeObj]=...
            autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,codeDescType.Name);
            if datatypeObjExists
                slAppTypeAttributes=...
                autosar.mm.util.SlAppTypeAttributesGetter.fromDataObj(datatypeObj);
            else
                slAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;
            end

            m3iType=this.TypeBuilder.createOrUpdateM3IType([],...
            codeDescType,codeDescCodeType,slAppTypeAttributes);
        end



        function addBuiltM3iTypesToIncludedDataTypeSets(this)




            this.updateOrDestroyInternalDataTypeSets();

            if~isempty(this.M3iTypesToBeIncludedMap)
                m3iIncludedDataSet=this.findOrCreateIncludedTypeSetWithLiteralPrefix('');
                for value=values(this.M3iTypesToBeIncludedMap)
                    m3iType=value{1};
                    m3iIncludedDataSet.DataTypes.append(m3iType);
                end
            end
        end

        function updateOrDestroyInternalDataTypeSets(this)


            includedDataTypeSets=this.M3iBehavior.IncludedDataTypeSets;
            for idx=includedDataTypeSets.size():-1:1
                includedDataTypes=this.updateOrEraseIncludedDataTypes(includedDataTypeSets.at(idx));
                if includedDataTypes.isEmpty()
                    includedDataTypeSets.at(idx).destroy;
                end
            end
        end

        function includedDataTypes=updateOrEraseIncludedDataTypes(this,m3iIncludedTypeSet)



            includedDataTypes=m3iIncludedTypeSet.DataTypes;
            literalPrefix=m3iIncludedTypeSet.LiteralPrefix;

            for typeIdx=includedDataTypes.size():-1:1
                m3iType=includedDataTypes.at(typeIdx);
                if isa(m3iType,'Simulink.metamodel.types.Enumeration')&&~isempty(literalPrefix)


                elseif isKey(this.M3iTypesToBeIncludedMap,m3iType.Name)
                    includedDataTypes.replace(typeIdx,this.M3iTypesToBeIncludedMap(m3iType.Name));
                    this.removeElementsFromMap(this.M3iTypesToBeIncludedMap,{m3iType.Name});
                else
                    includedDataTypes.erase(typeIdx);
                end
            end
        end

        function m3iIncludedData=findOrCreateIncludedTypeSetWithLiteralPrefix(this,literalPrefix)


            m3iIncludedData=[];
            includedDataTypeSets=this.M3iBehavior.IncludedDataTypeSets;
            for idx=1:includedDataTypeSets.size()
                m3iObj=includedDataTypeSets.at(idx);
                if strcmp(m3iObj.LiteralPrefix,literalPrefix)
                    m3iIncludedData=m3iObj;
                end
            end
            if isempty(m3iIncludedData)
                m3iIncludedData=Simulink.metamodel.arplatform.ModelFinder.createNamedItemInSequence(this.M3iBehavior,...
                includedDataTypeSets,'',...
                'Simulink.metamodel.arplatform.behavior.IncludedDataTypeSet');
            end
        end

    end

    methods(Static,Access=private)
        function isNotEmpty=hasNonEmptyImplementationTypeName(codeDescriptorObj)
            isNotEmpty=~isempty(codeDescriptorObj.Implementation)...
            &&~isempty(codeDescriptorObj.Implementation.Type.Name);
        end
    end

    methods(Static,Access=public)
        function isBuiltIn=isTypeBuiltIn(codeDescType,modelName)

            isBuiltIn=autosar.mm.util.BuiltInTypeMapper.isMATLABTypeName(codeDescType.Name)||...
            autosar.mm.util.BuiltInTypeMapper.isRTWBuiltIn(codeDescType.Name,modelName);
        end

        function baseType=getBaseType(codeDescType)
            if codeDescType.isMatrix||codeDescType.isPointer
                baseType=autosar.mm.sl2mm.IncludedTypeSetBuilder.getBaseType(codeDescType.BaseType);
            else
                baseType=codeDescType;
            end
        end

        function removeElementsFromMap(map,elements)
            removalElements=elements(isKey(map,elements));
            remove(map,removalElements);
        end
    end

end


