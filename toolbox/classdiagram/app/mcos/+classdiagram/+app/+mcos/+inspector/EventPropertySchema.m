classdef EventPropertySchema<classdiagram.app.core.inspector.PropertySchemaInterface
    properties(Access=public)
EventMeta
        InfoMap containers.Map
    end

    methods(Access=public)
        function obj=EventPropertySchema(eventElement)
            metaClass=meta.class.fromName(eventElement.getOwningClass().getName());
            obj.EventMeta=findobj(metaClass.EventList,"Name",eventElement.getName());
            obj.InfoMap=containers.Map;
        end

        function label=getDisplayLabel(~)
            label=message('classdiagram_editor:messages:PI_Event').string;
        end

        function subprops=subProperties(~,prop)
            if prop==classdiagram.app.core.inspector.InspectorProvider.RootID
                subprops=["Event|Name","Event|NotifyAccess","Event|ListenAccess",...
                "Event|Hidden"];
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
                    info.Tooltip="";
                    switch prop
                    case "Event|Name"
                        info.Label=message('classdiagram_editor:messages:PI_Name').string;
                        info.Value=obj.EventMeta.Name;
                        info.Renderer="IconLabelRenderer";
                    case "Event|NotifyAccess"
                        info.Label=message('classdiagram_editor:messages:PI_NotifyAccess').string;
                        info.Value=obj.getAccessList(true);
                        info.Renderer="IconLabelRenderer";
                    case "Event|ListenAccess"
                        info.Label=message('classdiagram_editor:messages:PI_ListenAccess').string;
                        info.Value=obj.getAccessList(false);
                        info.Renderer="IconLabelRenderer";
                    case "Event|Hidden"
                        info.Label=message('classdiagram_editor:messages:PI_Hidden').string;
                        info.Value=obj.EventMeta.Hidden;
                        info.Renderer="CheckboxRenderer";
                    end

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

    methods(Access=private)
        function accessList=getAccessList(obj,isNotify)
            if isNotify
                if ischar(obj.EventMeta.NotifyAccess)
                    accessList=string(obj.EventMeta.NotifyAccess);
                else

                    notifyClassName=string(cellfun(@(x)x.Name,obj.EventMeta.NotifyAccess,'UniformOutput',false));
                    accessList=notifyClassName.join(", ");
                end
            else
                if ischar(obj.EventMeta.ListenAccess)
                    accessList=string(obj.EventMeta.ListenAccess);
                else

                    listenClassName=string(cellfun(@(x)x.Name,obj.EventMeta.ListenAccess,'UniformOutput',false));
                    accessList=listenClassName.join(", ");
                end
            end
        end
    end
end

