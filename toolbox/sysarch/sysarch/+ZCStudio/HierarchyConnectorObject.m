classdef HierarchyConnectorObject<handle

    properties
        connectorData;

    end

    methods
        function obj=HierarchyConnectorObject(data)
            obj.connectorData=data;
        end

        function out=getPropertySchema(obj)
            out=obj;
        end

        function type=getObjectType(~)
            type=DAStudio.message('SystemArchitecture:PropertyInspector:HierarchyConnector');
        end

        function boolValue=supportTabView(~)
            boolValue=false;
        end

        function mode=rootNodeViewMode(~,~)
            mode='TreeView';
        end

        function boolValue=hasSubProperties(obj,prop)
            if(strcmp(prop,'portSelection'))
                boolValue=isstruct(obj.connectorData.(prop));
            else
                boolValue=isstruct(obj.connectorData.portSelection.(prop));
            end
        end

        function props=subProperties(obj,prop)
            props={};
            if isempty(prop)
                props=fieldnames(obj.connectorData);
            elseif strcmp(prop,'portSelection')
                props=fieldnames(obj.connectorData.(prop));
            end
        end

        function value=propertyValue(obj,prop)
            value='';
            if ismember(prop,fieldnames(obj.connectorData.portSelection))
                value=obj.connectorData.portSelection.(prop);
            end
        end

        function label=propertyDisplayLabel(obj,prop)
            label=obj.getLocalizedString(prop);
        end

        function tooltip=propertyTooltip(obj,prop)
            tooltip=obj.getLocalizedString(prop);
        end

        function mode=propertyRenderMode(~,~)
            mode='RenderAsText';
        end

        function boolValue=isPropertyEditable(~,~)
            boolValue=false;
        end
    end

    methods(Access=private)
        function localStr=getLocalizedString(~,prop)
            localStr='';%#ok<NASGU>
            switch prop
            case 'portSelection'
                localStr=DAStudio.message('SystemArchitecture:PropertyInspector:PortSelection');
            case 'source'
                localStr=DAStudio.message('SystemArchitecture:PropertyInspector:Source');
            case 'destination'
                localStr=DAStudio.message('SystemArchitecture:PropertyInspector:Destination');
            otherwise
                localStr=prop;
            end
        end
    end

end

