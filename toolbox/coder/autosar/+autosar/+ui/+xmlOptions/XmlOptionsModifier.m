classdef XmlOptionsModifier<handle





    properties(Access=protected)
        MaxShortNameLength;
        M3IModel;
        Dialog;
    end

    properties(Constant,Abstract,Access=protected)
        MoveElementsMode;
    end

    methods(Abstract,Access=protected)
        [status,errMsg]=setXmlOption(this,optionName,newVal);
        value=getXmlOptionValue(this,optionName);
        [status,errMsg]=performConsistencyChecks(this);
    end

    methods(Access=public)
        function this=XmlOptionsModifier(dialog,m3iModel)
            this.Dialog=dialog;
            this.M3IModel=m3iModel;
            this.MaxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(this.M3IModel);
        end
    end

    methods(Static,Access=public)
        function[status,errmsg]=applyChanges(dialog,m3iRoot)





            isSharedM3IModel=autosar.dictionary.Utils.isSharedM3IModel(m3iRoot.rootModel);
            modifier=[];
            if isSharedM3IModel
                dialogSource=dialog.getDialogSource();
                if isa(dialogSource,...
                    'autosar.internal.dictionaryApp.xmlOptions.XmlOptionsDialog')

                    modifier=...
                    autosar.ui.xmlOptions.SharedDictionaryXmlOptionsModifier(dialog,m3iRoot.modelM3I);
                else

                    m3iModel=dialogSource.ParentM3I.ParentM3I.M3iObject;
                end
            else
                m3iModel=m3iRoot.modelM3I;
            end
            if isempty(modifier)
                modelName=...
                autosar.mm.observer.ObserversDispatcher.findModelFromMetaModel(m3iModel);
                modifier=autosar.ui.xmlOptions.SLModelXmlOptionsModifier.getModifier(modelName,dialog,m3iModel);
            end
            [status,errmsg]=modifier.apply();

            dialog.setFocus('ExportedXMLFilePackaging');
        end
    end

    methods(Static,Access=protected)
        function newValue=getEnumNewValue(dlg,name)

            widgetValue=dlg.getWidgetValue(name);
            if isempty(widgetValue)
                newValue=[];
                return
            end
            newValues=autosar.mm.util.XmlOptionsAdapter.getEnumPropertyValues(name);
            newValue=newValues{widgetValue+1};
        end
    end

    methods(Access=protected)
        function[status,errMsg]=checkPackageNames(this,packages)
            status=1;
            errMsg='';
            for i=1:length(packages)
                idcheckmessage=autosar.ui.utils.isValidARIdentifier(packages{i},'absPath',...
                this.MaxShortNameLength);
                if~isempty(idcheckmessage)
                    errMsg=idcheckmessage;
                    status=0;
                    return;
                end
            end
        end
    end

    methods(Access=private)
        function[status,errMsg]=apply(this)


            [status,errMsg]=this.performConsistencyChecks();
            if~status

                return;
            end


            xmlOptions=this.getNewXmlOptionValues();

            [status,errMsg]=this.setNewValues(xmlOptions);
        end

        function xmlOptions=getNewXmlOptionValues(this)
            xmlOptions={...
            'XmlOptionsSource',this.getEnumNewValue(this.Dialog,'XmlOptionsSource'),'XmlOptionsSource';...
            'DataTypePackage',this.Dialog.getWidgetValue('DatatypePackage'),'DatatypePackage';...
            'InterfacePackage',this.Dialog.getWidgetValue('InterfacePackage'),'InterfacePackage';
            'ComponentPackage',this.Dialog.getWidgetValue('ComponentPackage'),'ComponentPackage';...
            'ImplementationTypeReference',this.getEnumNewValue(this.Dialog,'ImplementationTypeReference'),'ImplementationTypeReference';...
            'SwCalibrationAccessDefault',this.getEnumNewValue(this.Dialog,'SwCalibrationAccessDefault'),'SwCalibrationAccessDefault';...
            'CompuMethodDirection',this.getEnumNewValue(this.Dialog,'CompuMethodDirection'),'CompuMethodDirection';...
            'ApplicationDataTypePackage',this.Dialog.getWidgetValue('ApplDTPackage'),'ApplDTPackage';...
            'SwBaseTypePackage',this.Dialog.getWidgetValue('BaseTypePackage'),'BaseTypePackage';...
            'DataTypeMappingPackage',this.Dialog.getWidgetValue('DataTypeMapPackage'),'DataTypeMapPackage';...
            'ConstantSpecificationPackage',this.Dialog.getWidgetValue('ConstantPackage'),'ConstantPackage';...
            'DataConstraintPackage',this.Dialog.getWidgetValue('DataConstrPackage'),'DataConstrPackage';...
            'InternalDataConstraintPackage',this.Dialog.getWidgetValue('InternalDataConstrPackage'),'InternalDataConstrPackage';...
            'SystemConstantPackage',this.Dialog.getWidgetValue('SysConstantPackage'),'SysConstantPackage';...
            'SwAddressMethodPackage',this.Dialog.getWidgetValue('SwAddrPackage'),'SwAddrPackage';...
            'ModeDeclarationGroupPackage',this.Dialog.getWidgetValue('MDGPackage'),'MDGPackage';...
            'CompuMethodPackage',this.Dialog.getWidgetValue('CompuPackage'),'CompuPackage';...
            'UnitPackage',this.Dialog.getWidgetValue('UnitPackage'),'UnitPackage';...
            'SwRecordLayoutPackage',this.Dialog.getWidgetValue('SwRecordLayoutPackage'),'SwRecordLayoutPackage';...
            'InternalDataConstraintExport',this.Dialog.getWidgetValue('InternalDataConstraintExport'),'InternalDataConstraintExport';...
            'IdentifyServiceInstance',this.getEnumNewValue(this.Dialog,'IdentifyServiceInstance'),'IdentifyServiceInstance';...
            'SchemaVersion',this.getEnumNewValue(this.Dialog,'SchemaVersion'),'SchemaVersion';...
            };

            arxmlfilePackaging=this.Dialog.getWidgetValue('ExportedXMLFilePackaging');
            if arxmlfilePackaging==0
                arxmlPackaging='Modular';
            else
                arxmlPackaging='SingleFile';
            end
            xmlOptions=[xmlOptions;{'ArxmlFilePackaging',arxmlPackaging,...
            'ExportedXMLFilePackaging'}];

            if slfeature('AUTOSARPostBuildVariant')
                xmlOptions=[xmlOptions;{'PostBuildCriterionPackage',...
                this.Dialog.getWidgetValue('PostBuildCriterionPackage'),...
                'PostBuildCriterionPackage'}];
            end

            if slfeature('AUTOSAREcuExtract')
                xmlOptions=[xmlOptions;{'SystemPackage',...
                this.Dialog.getWidgetValue('SystemPackage'),'SystemPackage'}];
            end

            if slfeature('AUTOSARPlatformTypesRefAndNativeDecl')
                xmlOptions=[xmlOptions;{...
                'PlatformDataTypePackage',this.Dialog.getWidgetValue('PlatformDTPackage'),'PlatformDTPackage';...
                'UsePlatformTypeReferences',this.getEnumNewValue(this.Dialog,'UsePlatformTypeReferences'),'UsePlatformTypeReferences';...
                'NativeDeclaration',this.getEnumNewValue(this.Dialog,'NativeDeclaration'),'NativeDeclaration';...
                }];
            end

            if slfeature('AUTOSARLUTRecordValueSpec')
                lutApplValueSpecXmlOption='ExportLookupTableApplicationValueSpecification';
                xmlOptions=[xmlOptions;{lutApplValueSpecXmlOption,this.Dialog.getWidgetValue(lutApplValueSpecXmlOption),lutApplValueSpecXmlOption;}];
            end
        end

        function[status,errMsg]=setNewValues(this,xmlOptions)
            status=1;
            errMsg='';
            for option=xmlOptions'
                if~this.Dialog.isWidgetValid(option{3,1})

                    continue;
                end
                optionName=option{1,1};
                newVal=option{2,1};
                curVal=this.getXmlOptionValue(optionName);
                if~isequal(curVal,newVal)
                    try
                        this.setXmlOption(optionName,newVal);
                    catch ME
                        errMsg=ME.message;
                        status=0;
                        return
                    end
                end
            end
        end
    end
end


