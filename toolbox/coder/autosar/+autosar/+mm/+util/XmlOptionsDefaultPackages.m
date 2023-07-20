classdef XmlOptionsDefaultPackages<handle




    properties(Constant)

        ComponentsPackage='/Components';
        DataTypesPackage='/DataTypes';
        InterfacesPackage='/Interfaces';
        TimingPackage='/Timing';
        SystemPackage='/System';


        ApplicationDataTypes='ApplDataTypes';
        SwBaseTypes=autosarcore.mm.sl2mm.SwBaseTypeBuilder.DefaultPackage;
        CompuMethods='CompuMethods';
        Units='Units';
        SwAddressMethods='SwAddrMethods';
        ModeDeclarationGroups='ModeDeclarationGroups';
        SwRecordLayouts='SwRecordLayouts';
        DataTypeMappingSets='DataTypeMappings';
        ConstantSpecifications='Constants';
        SystemConstants='SystemConstants';
        DataConstrs='DataConstrs';
        PostBuildCriterions='PostBuildCriterions';
    end

    properties(Constant,Access=private)
        SwcInternalBehaviors=[autosar.mm.util.XmlOptionsDefaultPackages.ComponentsPackage,'/InternalBehaviors'];
        SwcImplementations=[autosar.mm.util.XmlOptionsDefaultPackages.ComponentsPackage,'/SwcImplementations'];
    end

    methods(Static)
        function impQName=getImplementationQualifiedName(swcName,maxShortNameLength)
            impName=[swcName,'_Impl'];
            impName=arxml.arxml_private('p_create_aridentifier',...
            impName,maxShortNameLength);
            impQName=[autosar.mm.util.XmlOptionsDefaultPackages.SwcImplementations,'/',impName];
        end

        function ibQName=getInternalBehaviorQualifiedName(swcName,maxShortNameLength)
            ibName=[swcName,'_IB'];
            ibName=arxml.arxml_private('p_create_aridentifier',...
            ibName,maxShortNameLength);
            ibQName=[autosar.mm.util.XmlOptionsDefaultPackages.SwcInternalBehaviors,'/',ibName];
        end




        function pkg=getXmlOptionsPackage(modelOrInterfaceDictName,packageName)
            import autosar.mm.util.XmlOptionsDefaultPackages

            arProps=autosar.api.getAUTOSARProperties(modelOrInterfaceDictName);
            pkg=arProps.get('XmlOptions',packageName);
            if isempty(pkg)

                pkg=XmlOptionsDefaultPackages.getXmlOptionsDefaultPackage(...
                modelOrInterfaceDictName,packageName);
            end
        end


        function setAllEmptyXmlOptionsToDefault(modelOrInterfaceDictName)
            import autosar.mm.util.XmlOptionsAdapter
            import autosar.mm.util.XmlOptionsDefaultPackages

            m3iModel=autosar.api.Utils.m3iModel(modelOrInterfaceDictName);

            arRoot=m3iModel.RootPackage.front();


            rootXmlOptionsPropNames={'DataTypePackage','InterfacePackage'};
            for propIdx=1:length(rootXmlOptionsPropNames)
                propertyName=rootXmlOptionsPropNames{propIdx};
                currentValue=arRoot.(propertyName);
                if isempty(currentValue)
                    newValue=XmlOptionsDefaultPackages.getXmlOptionsPackage(...
                    modelOrInterfaceDictName,propertyName);
                    arRoot.(propertyName)=newValue;
                end
            end


            m3iModelContext=autosar.api.internal.M3IModelContext.createContext(...
            modelOrInterfaceDictName);
            propertyNames=XmlOptionsAdapter.getXmlOptionNamesForPackages(m3iModelContext);
            for propIdx=1:length(propertyNames)
                propertyName=propertyNames{propIdx};
                currentValue=XmlOptionsAdapter.get(arRoot,propertyName);
                if isempty(currentValue)
                    if strcmp(propertyName,'PostBuildCriterionPackage')&&...
                        ~slfeature('AUTOSARPostBuildVariant')

                    elseif(strcmp(propertyName,'PlatformDataTypePackage')||...
                        strcmp(propertyName,'UsePlatformTypeReferences')||...
                        strcmp(propertyName,'NativeDeclaration'))&&...
                        ~slfeature('AUTOSARPlatformTypesRefAndNativeDecl')

                    else
                        newValue=XmlOptionsDefaultPackages.getXmlOptionsPackage(...
                        modelOrInterfaceDictName,propertyName);
                        XmlOptionsAdapter.set(arRoot,propertyName,newValue);
                    end
                end
            end
        end
    end

    methods(Static,Access=private)


        function pkg=getXmlOptionsDefaultPackage(modelOrInterfaceDictName,packageName)
            import autosar.mm.util.XmlOptionsDefaultPackages
            switch(packageName)
            case 'ComponentPackage'
                pkg=XmlOptionsDefaultPackages.ComponentsPackage;
            case 'InterfacePackage'
                pkg=XmlOptionsDefaultPackages.InterfacesPackage;
            case 'DataTypePackage'
                pkg=XmlOptionsDefaultPackages.DataTypesPackage;
            case 'ApplicationDataTypePackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.ApplicationDataTypes];
            case 'PlatformDataTypePackage'
                pkg='';
            case 'CompuMethodPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.CompuMethods];
            case 'ConstantSpecificationPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.ConstantSpecifications];
            case 'DataTypeMappingPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.DataTypeMappingSets];
            case 'ModeDeclarationGroupPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.ModeDeclarationGroups];
            case 'SwAddressMethodPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.SwAddressMethods];
            case 'SwBaseTypePackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.SwBaseTypes];
            case 'SwRecordLayoutPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.SwRecordLayouts];
            case 'SystemConstantPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.SystemConstants];
            case 'PostBuildCriterionPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.PostBuildCriterions];
            case 'UnitPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.Units];
            case 'InternalDataConstraintPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'DataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.DataConstrs];
            case 'DataConstraintPackage'
                dtPkg=XmlOptionsDefaultPackages.getXmlOptionsPackage(modelOrInterfaceDictName,'ApplicationDataTypePackage');
                pkg=[dtPkg,'/',XmlOptionsDefaultPackages.DataConstrs];
            case 'TimingPackage'
                pkg=XmlOptionsDefaultPackages.TimingPackage;
            case 'SystemPackage'
                pkg=XmlOptionsDefaultPackages.SystemPackage;
            otherwise
                assert(false,'invalid package name: %s',packageName);
            end
        end
    end
end


