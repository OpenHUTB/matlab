classdef DiagramPropertySchema<classdiagram.app.core.inspector.PropertySchemaInterface
    properties(Access=public)
Factory
        InfoMap containers.Map
    end

    methods(Access=public)
        function obj=DiagramPropertySchema(factory)
            obj.Factory=factory;
            obj.InfoMap=containers.Map;
        end

        function label=getDisplayLabel(~)
            label=message('classdiagram_editor:messages:PI_Diagram').string;
        end

        function subprops=subProperties(~,prop)
            if prop==classdiagram.app.core.inspector.InspectorProvider.RootID
                subprops=["Name","ClassCount"];
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
                    if prop=="Name"
                        info.Label=message('classdiagram_editor:messages:PI_Name').string;
                        if isempty(obj.Factory.App.getFilePath)
                            info.Value="Untitled";
                        else
                            [~,name,~]=fileparts(obj.Factory.App.getFilePath);
                            info.Value=string(name);
                        end
                    elseif prop=="ClassCount"
                        info.Label=message('classdiagram_editor:messages:PI_NumofClasses').string;
                        packageElements=obj.Factory.getDiagramedEntities();
                        info.Value=num2str(length(packageElements));
                    end

                    info.Renderer="IconLabelRenderer";
                    info.Tooltip='';

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

