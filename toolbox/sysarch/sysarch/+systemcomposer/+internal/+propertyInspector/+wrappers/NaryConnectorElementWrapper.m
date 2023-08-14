classdef NaryConnectorElementWrapper<systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper

    properties
        schemaType;
    end

    methods
        function obj=NaryConnectorElementWrapper(varargin)
            obj=obj@systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper(varargin{:});
            obj.schemaType='NaryConnector';
        end

        function setPropElement(obj)
            obj.element=obj.getZCElement();
            if isempty(obj.sourceHandle)
                obj.sourceHandle=systemcomposer.utils.getSimulinkPeer(obj.element);
            end
        end

        function name=getName(obj)
            name=obj.element.getName;
        end

        function name=getNameTooltip(~)
            name=DAStudio.message('SystemArchitecture:PropertyInspector:Connector');
        end

        function status=isNameEditable(~)
            status=true;
        end

        function error=setName(obj,changeSet,~)
            error='';
            newValue=changeSet.newValue;
            try
                txn=mf.zero.getModel(obj.element).beginTransaction;
                obj.element.setName(newValue);
                txn.commit;
            catch
                error='Failed to set Name';
            end
        end
    end

    methods(Access=private)
        function elem=getElemToSetPropFor(obj)
            elem=obj.element;
            elem=systemcomposer.internal.getWrapperForImpl(elem);
        end
    end
end
