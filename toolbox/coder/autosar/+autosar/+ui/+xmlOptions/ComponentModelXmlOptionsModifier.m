classdef ComponentModelXmlOptionsModifier<autosar.ui.xmlOptions.SLModelXmlOptionsModifier





    properties(Constant,Access=protected)
        MoveElementsMode='Alert';
    end

    methods(Access=protected)
        function[status,errMsg]=performConsistencyChecks(this)


            internalBehaviorName=this.getXmlOptionValue('InternalBehaviorQualifiedName');
            implName=this.getXmlOptionValue('ImplementationQualifiedName');


            compPackage=fileparts(this.getXmlOptionValue('ComponentQualifiedName'));
            newValues={compPackage,internalBehaviorName,implName};
            [status,errMsg]=this.checkPackageNames(newValues);
            if~status

                return;
            end
            dataTypePackage=this.Dialog.getWidgetValue('DatatypePackage');
            interfacePackage=this.Dialog.getWidgetValue('InterfacePackage');
            [foundDuplicate,msg]=autosar.mm.util.checkAmbigousXmlOptions(...
            this.M3IModel,compPackage,dataTypePackage,interfacePackage,implName);
            if foundDuplicate
                errMsg=msg;
                status=0;
                return;
            end
        end
    end
end


