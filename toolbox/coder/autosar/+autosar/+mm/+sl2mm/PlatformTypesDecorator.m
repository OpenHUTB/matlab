classdef PlatformTypesDecorator<handle





    properties(Access=private)
        NativeDeclarationBuilder autosar.mm.sl2mm.NativeDeclarationBuilder;
        M3IModel;
        M3IDataTypePkg;
        TypeBuilder autosar.mm.sl2mm.TypeBuilder;
    end

    methods(Access=public)
        function this=PlatformTypesDecorator(modelName,m3iModel,typeBuilder)
            this.TypeBuilder=typeBuilder;
            this.NativeDeclarationBuilder=autosar.mm.sl2mm.NativeDeclarationBuilder(modelName);
            this.M3IModel=m3iModel;
            arRoot=this.M3IModel.RootPackage.front;
            this.M3IDataTypePkg=autosar.mm.Model.getOrAddPackage(this.M3IModel,arRoot.DataTypePackage);
        end

        function updatePlatformType(this,embeddedObj,m3iAppType,m3iImplType)



            if~slfeature('AUTOSARPlatformTypesRefAndNativeDecl')
                return;
            end

            assert(~isempty(embeddedObj),'CodeDescriptor object must be provided');

            if isa(m3iImplType,'Simulink.metamodel.types.Enumeration')||...
                isa(m3iImplType,'Simulink.metamodel.types.FixedPoint')


                m3iPrimitiveType=m3iImplType;


                baseType=m3iPrimitiveType.SwBaseType;
                if~isempty(baseType)
                    baseType.NativeDeclaration=this.NativeDeclarationBuilder.getNativeDeclaration(m3iPrimitiveType);
                end
                return;
            elseif isa(m3iImplType,'Simulink.metamodel.types.PrimitiveType')
                m3iPrimitiveType=m3iImplType;
            elseif isa(m3iImplType,'Simulink.metamodel.types.Matrix')
                m3iPrimitiveType=m3iImplType.BaseType;
                this.updatePlatformType(embeddedObj,m3iAppType,m3iPrimitiveType);
                return;
            elseif isa(m3iImplType,'Simulink.metamodel.types.Structure')
                for i=1:m3iImplType.Elements.size()
                    m3iPrimitiveType=m3iImplType.Elements.at(1).Type;
                    this.updatePlatformType(embeddedObj,m3iAppType,m3iPrimitiveType);
                end
                return;
            else
                return;
            end


            m3iPrimitiveType=this.updatePlatformTypeReference(m3iPrimitiveType,embeddedObj);



            if isa(m3iAppType,'Simulink.metamodel.types.PrimitiveType')
                this.updatePlatformTypeNames(embeddedObj,m3iAppType);
            end

            this.updatePlatformTypeNames(embeddedObj,m3iPrimitiveType);


            baseType=m3iPrimitiveType.SwBaseType;
            if~isempty(baseType)
                baseType.NativeDeclaration=this.NativeDeclarationBuilder.getNativeDeclaration(m3iPrimitiveType);
            end
        end
    end

    methods(Static,Access=public)


        function moveToPlatformTypesPackage(m3iModel)
            import autosar.mm.util.XmlOptionsAdapter;

            arRoot=m3iModel.RootPackage.front;
            platformTypesPackageName=XmlOptionsAdapter.get(arRoot,'PlatformDataTypePackage');
            if~isempty(platformTypesPackageName)
                autosar.mm.util.XMLOptionsPlatformTypesUtils.movePlatformDataTypes(arRoot,platformTypesPackageName);
            end
        end
    end

    methods(Access=private)


        function updatePlatformTypeNames(this,embeddedObj,m3iType)
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.mm.Model;


            if~isempty(m3iType.getExternalToolInfo('ARXML_ArxmlFileInfo').externalId)
                return;
            end



            isPlatformTypeName=autosar.mm.util.BuiltInTypeMapper.isAUTOSARPlatformType(isAdaptive=false,implType=m3iType);

            arRoot=this.M3IModel.RootPackage.front;
            platformTypeReference=XmlOptionsAdapter.get(arRoot,'UsePlatformTypeReferences');
            platformTypesPackageName=XmlOptionsAdapter.get(arRoot,'PlatformDataTypePackage');

            if isPlatformTypeName&&(~isempty(platformTypesPackageName)||strcmp(platformTypeReference,'PlatformTypeReference'))



                platformTypeNames=autosar.mm.util.BuiltInTypeMapper.getAUTOSARPlatformTypeNames(isAdaptive=false);




                if~any(strcmp(platformTypeNames,m3iType.Name))&&(embeddedObj.isNumeric||embeddedObj.isEnum)



                    oldImplTypeName=m3iType.Name;
                    oldImplTypeQName=autosar.api.Utils.getQualifiedName(m3iType);
                    m3iType.Name=autosar.mm.util.BuiltInTypeMapper.convertToAutosarBuiltInTypeName(embeddedObj.Identifier);



                    if~m3iType.IsApplication
                        this.TypeBuilder.ApplicationTypeMapper.updateApplToImplTypesMappings(oldImplTypeName,m3iType.Name,...
                        oldImplTypeQName,autosar.api.Utils.getQualifiedName(m3iType));
                    end

                end
            end
        end


        function m3iImpType=updatePlatformTypeReference(this,m3iImpType,embeddedObj)
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.mm.Model;


            if~isempty(m3iImpType.getExternalToolInfo('ARXML_ArxmlFileInfo').externalId)
                return;
            end


            isPlatformTypeName=autosar.mm.util.BuiltInTypeMapper.isAUTOSARPlatformType(isAdaptive=false,implType=m3iImpType);

            arRoot=this.M3IModel.RootPackage.front;
            platformTypeReference=XmlOptionsAdapter.get(arRoot,'UsePlatformTypeReferences');

            if~isPlatformTypeName

                switch(platformTypeReference)
                case 'PlatformTypeReference'
                    if~isempty(m3iImpType.SwBaseType)

                        this.TypeBuilder.addImplementationTypeReference(embeddedObj,m3iImpType,...
                        m3iImpType.SwBaseType.Name,m3iImpType.MetaClass);
                    end
                case 'BaseTypeReference'

                    m3iImpType.Reference=Simulink.metamodel.types.ImmutablePrimitiveType;
                otherwise
                    assert(false,sprintf('Enumeration "%s" is not valid.',platformTypeReference));
                end
            end
        end

    end
end


