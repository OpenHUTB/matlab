classdef ArchitectureModelXmlOptionsModifier<autosar.ui.xmlOptions.SLModelXmlOptionsModifier





    properties(Constant,Access=protected)


        MoveElementsMode='None';
    end

    methods(Access=protected)
        function[status,errMsg]=performConsistencyChecks(this)


            internalBehaviorName=this.getXmlOptionValue('InternalBehaviorQualifiedName');
            implName=this.getXmlOptionValue('ImplementationQualifiedName');



            compPackage=this.Dialog.getWidgetValue('ComponentPackage');

            newValues={compPackage,internalBehaviorName,implName};
            [status,errMsg]=this.checkPackageNames(newValues);
            if~status

                return;
            end
        end
    end
end
