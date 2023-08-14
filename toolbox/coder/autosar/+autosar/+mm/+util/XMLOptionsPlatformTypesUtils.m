classdef XMLOptionsPlatformTypesUtils<handle




    methods(Static,Access=public)


        function verifyXmlOptionsPackage(newValue,~,m3iModel,~)
            arRoot=m3iModel.RootPackage.front;
            dataTypesPkg=arRoot.DataTypePackage;

            if~isempty(dataTypesPkg)&&strcmp(dataTypesPkg,newValue)
                DAStudio.error('RTW:autosar:wrongPlatformTypesPackageName');
            end
        end




        function movePlatformDataTypes(arRoot,platformPkg)
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.mm.Model;
            import autosar.api.Utils;

            m3iModel=arRoot.rootModel;

            if isempty(platformPkg)
                return;
            end

            autosar.mm.util.XMLOptionsPlatformTypesUtils.verifyXmlOptionsPackage(platformPkg,'',m3iModel,'');

            dataTypesPkg=arRoot.DataTypePackage;
            baseTypesPkg=XmlOptionsAdapter.get(arRoot,'SwBaseTypePackage');



            if(contains(dataTypesPkg,'AUTOSAR_PlatformTypes')||contains(baseTypesPkg,'AUTOSAR_PlatformTypes'))
                return;
            end

            platformPkg=strip(platformPkg,'right','/');
            destDataTypesPkg=[platformPkg,'/ImplementationDataTypes'];
            destBaseTypesPkg=[platformPkg,'/BaseTypes'];
            destCompuMethodsPkg=[platformPkg,'/CompuMethods'];
            destDataConstraintsPkg=[platformPkg,'/DataConstraints'];

            platformTypeNames=autosar.mm.util.BuiltInTypeMapper.getAUTOSARPlatformTypeNames(isAdaptive=false);


            for i=1:length(platformTypeNames)
                elementName=platformTypeNames{i};

                filter=@(x)~x.IsApplication;

                autosar.composition.utils.M3IElementMover.moveElementsByNameAndMetaClass(elementName,...
                Simulink.metamodel.types.PrimitiveType.MetaClass,destDataTypesPkg,m3iModel,...
                CaseSensitive=false,UserFilter=filter);
                autosar.composition.utils.M3IElementMover.moveElementsByNameAndMetaClass(elementName,...
                Simulink.metamodel.types.SwBaseType.MetaClass,destBaseTypesPkg,m3iModel,...
                CaseSensitive=false);
            end


            autosar.mm.util.XMLOptionsPlatformTypesUtils.movePlatformTypeRelatedElement(m3iModel,Simulink.metamodel.types.CompuMethod.MetaClass,...
            destCompuMethodsPkg,platformTypeNames);


            autosar.mm.util.XMLOptionsPlatformTypesUtils.movePlatformTypeRelatedElement(m3iModel,Simulink.metamodel.types.DataConstr.MetaClass,...
            destDataConstraintsPkg,platformTypeNames);
        end

        function[UsePlatformTypeReferences,NativeDeclaration,PlatformDataTypePackage]=inferImportedDefaults(m3iModel)
            cIntegralNames={};
            platformNames={};




            UsePlatformTypeReferences='BaseTypeReference';
            PlatformDataTypePackage='';

            baseTypes=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,Simulink.metamodel.types.SwBaseType.MetaClass,true,true);
            for i=1:baseTypes.size()
                baseType=baseTypes.at(i);
                platformTypeNames=autosar.mm.util.BuiltInTypeMapper.getAUTOSARPlatformTypeNames(isAdaptive=false);
                nativeDeclaration=baseType.NativeDeclaration;

                isPlatformTypeName=~isempty(nativeDeclaration)&&any(strcmpi(platformTypeNames,nativeDeclaration));

                if isPlatformTypeName
                    platformNames=[platformNames,nativeDeclaration];%#ok<AGROW>
                else
                    cIntegralNames=[cIntegralNames,nativeDeclaration];%#ok<AGROW>
                end
            end











            if length(unique(cIntegralNames))>=length(unique(platformNames))
                NativeDeclaration="CIntegralTypeName";
            else
                NativeDeclaration="PlatformTypeName";
            end
        end

    end

    methods(Static,Access=private)


        function movePlatformTypeRelatedElement(m3iModel,metaClass,packageName,platformTypeNames)
            elements=autosar.mm.Model.findObjectByMetaClass(m3iModel,metaClass,true,true);
            for i=1:elements.size()
                element=elements.at(i);
                isPlatformTypeRelated=true;

                for ii=1:element.PrimitiveType.size()
                    type=element.PrimitiveType.at(ii);
                    if~any(strcmpi(platformTypeNames,type.Name))||type.IsApplication
                        isPlatformTypeRelated=false;
                        break;
                    end
                end

                if isPlatformTypeRelated
                    autosar.composition.utils.M3IElementMover.moveElementsByNameAndMetaClass(element.Name,...
                    metaClass,packageName,m3iModel,CaseSensitive=true);
                end
            end
        end
    end
end


