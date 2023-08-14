classdef XmlOptionsSetter<handle




    methods(Static)
        function setCommonXmlOpts(arRoot,xmlOpts)

            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(arRoot.rootModel)
                sharedM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(arRoot.rootModel);
                arRootShared=sharedM3IModel.RootPackage.front();
            else
                arRootShared=arRoot;
            end


            arRootShared.DataTypePackage=xmlOpts.DataTypePackage;
            arRootShared.InterfacePackage=xmlOpts.InterfacePackage;

            import autosar.mm.util.XmlOptionsAdapter;
            XmlOptionsAdapter.set(arRootShared,'ComponentPackage',...
            xmlOpts.ComponentPackage);
            XmlOptionsAdapter.set(arRootShared,'ApplicationDataTypePackage',...
            xmlOpts.AppDataTypePackage);
            if slfeature('AUTOSARPlatformTypesRefAndNativeDecl')
                XmlOptionsAdapter.set(arRootShared,'PlatformDataTypePackage',...
                xmlOpts.PlatformDataTypePackage);
                XmlOptionsAdapter.set(arRootShared,'UsePlatformTypeReferences',...
                xmlOpts.UsePlatformTypeReferences);
                XmlOptionsAdapter.set(arRootShared,'NativeDeclaration',...
                xmlOpts.NativeDeclaration);
            end
            XmlOptionsAdapter.set(arRootShared,'DataTypeMappingPackage',...
            xmlOpts.DataTypeMappingPackage);
            XmlOptionsAdapter.set(arRootShared,'ConstantSpecificationPackage',...
            xmlOpts.ConstantSpecificationPackage);
            XmlOptionsAdapter.set(arRootShared,'SystemConstantPackage',...
            xmlOpts.SystemConstantPackage);
            XmlOptionsAdapter.set(arRootShared,'SwAddressMethodPackage',...
            xmlOpts.SwAddressMethodPackage);
            XmlOptionsAdapter.set(arRootShared,'ModeDeclarationGroupPackage',...
            xmlOpts.MDGPackage);
            XmlOptionsAdapter.set(arRootShared,'InternalDataConstraintPackage',...
            xmlOpts.InternalDataConstraintPackage);
            XmlOptionsAdapter.set(arRootShared,'DataConstraintPackage',...
            xmlOpts.DataConstraintPackage);
            XmlOptionsAdapter.set(arRootShared,'CompuMethodPackage',...
            xmlOpts.CompuMethodPackage);
            XmlOptionsAdapter.set(arRootShared,'UnitPackage',...
            xmlOpts.UnitPackage);
            XmlOptionsAdapter.set(arRootShared,'SwRecordLayoutPackage',...
            xmlOpts.SwRecordLayoutPackage);
            XmlOptionsAdapter.set(arRootShared,'SwBaseTypePackage',...
            xmlOpts.SwBaseTypePackage);
            XmlOptionsAdapter.set(arRootShared,'InternalDataConstraintExport',...
            xmlOpts.InternalDataConstraintExport);
            XmlOptionsAdapter.set(arRootShared,'ImplementationTypeReference',...
            xmlOpts.ImplementationTypeReference);
            XmlOptionsAdapter.set(arRootShared,'ExportLookupTableApplicationValueSpecification',...
            xmlOpts.ExportLookupTableApplicationValueSpecification);


            XmlOptionsAdapter.set(arRoot,'TimingPackage',...
            xmlOpts.TimingPackage);

            XmlOptionsAdapter.set(arRoot,'SystemPackage',...
            xmlOpts.SystemPackage);
        end
    end
end


