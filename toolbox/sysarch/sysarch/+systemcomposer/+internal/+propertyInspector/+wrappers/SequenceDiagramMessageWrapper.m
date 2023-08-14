classdef SequenceDiagramMessageWrapper<systemcomposer.internal.propertyInspector.wrappers.ConnectorElementWrapper





    properties
        selectedConnDest char='';
        destPortEditable;
        destPortRenderMode;
        nameTooltip;
    end

    methods
        function obj=SequenceDiagramMessageWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ConnectorElementWrapper(varargin{:});
            obj.schemaType='SequenceDiagramMessage';
        end

        function type=getObjectType(~)
            type='SequenceDiagramMessage';
        end

        function value=getDestPortRenderMode(obj)
            value=obj.destPortRenderMode;
        end

        function value=getDestPortEditable(obj)
            value=false;
        end

        function value=getNameTooltip(obj)
            value=obj.nameTooltip;
            if isempty(value)
                value='';
            end
        end

        function status=isNameEditable(~)

            status=false;
        end
    end
end

