classdef InheritancePropertySchema<classdiagram.app.core.inspector.PropertySchemaInterface
    properties(Access=public)
Relationship
        InfoMap containers.Map
    end

    methods(Access=public)
        function obj=InheritancePropertySchema(relationship)
            obj.Relationship=relationship;
            obj.InfoMap=containers.Map;
        end

        function label=getDisplayLabel(~)
            label=message('classdiagram_editor:messages:PI_Connection').string;
        end

        function subprops=subProperties(~,prop)
            if prop==classdiagram.app.core.inspector.InspectorProvider.RootID
                subprops=["Type","Super","Derived"];
            else
                subprops=[];
            end
        end

        function hasSubProp=hasSubProperties(~,prop)
            if isempty(prop)
                hasSubProp=true;
            else
                hasSubProp=false;
            end
        end

        function info=propertyInfo(obj,prop)
            info=[];
            if~isempty(prop)
                if obj.InfoMap.isKey(prop)
                    info=obj.InfoMap(prop);
                else
                    info=classdiagram.app.core.inspector.PropertyInfo;
                    if prop=="Type"
                        info.Label=message('classdiagram_editor:messages:PI_Type').string;
                        info.Value=obj.Relationship.getRelationshipType();
                        info.Tooltip="";
                    elseif prop=="Super"
                        info.Label=message('classdiagram_editor:messages:PI_Superclass').string;
                        nameParts=string(obj.Relationship.getDstClass().getName()).split('.');
                        info.Value=nameParts(end);
                        info.Tooltip=obj.Relationship.getDstClass().getName();
                    elseif prop=="Derived"
                        info.Label=message('classdiagram_editor:messages:PI_DerivedClass').string;
                        nameParts=string(obj.Relationship.getSrcClass().getName()).split('.');
                        info.Value=nameParts(end);
                        info.Tooltip=obj.Relationship.getSrcClass().getName();
                    end
                    info.Renderer="IconLabelRenderer";
                    obj.InfoMap(prop)=info;
                end
            end
        end

        function support=supportTabs(~)
            support=false;
        end

        function expandGroups=defaultExpandGroups(~)
            expandGroups=[];
        end
    end
end

