classdef AllocationSetWrapper<systemcomposer.internal.propertyInspector.wrappers.ElementWrapper



    properties
        allocCatalog;
        schemaType;
    end

    methods
        function obj=AllocationSetWrapper(varargin)

            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ElementWrapper(varargin{:});
            obj.schemaType='AllocationSet';
        end

        function setPropElement(obj)
            obj.allocCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            allocationSet=obj.allocCatalog.getAllocationSet(obj.archName);
            obj.element=mf.zero.getModel(allocationSet).findElement(obj.uuid);
        end

        function name=getName(obj)

            name=obj.element.getName;
        end

        function error=setName(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try
                obj.element.setName(newValue);
            catch
                error=DAStudio.message('SystemArchitecture:PropertyInspector:FailedToSetName');
            end
        end

        function tooltip=getDescriptionTooltip(obj)

            tooltip=obj.getDescription;
        end

        function error=setDescription(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try
                obj.element.p_Description=newValue;
            catch
                error=DAStudio.message('SystemArchitecture:PropertyInspector:FailedToSetDescription');
            end
        end

        function description=getDescription(obj)

            description=obj.element.p_Description;
        end

        function name=getNameTooltip(obj)

            name=obj.element.getName;
        end

        function status=isNameEditable(~)

            status=false;
        end

        function sourceName=getSourceModelName(obj)

            sourceName=obj.element.p_SourceModel.p_ModelURI;
        end

        function targetName=getTargetModelName(obj)

            targetName=obj.element.p_TargetModel.p_ModelURI;
        end

    end
end

