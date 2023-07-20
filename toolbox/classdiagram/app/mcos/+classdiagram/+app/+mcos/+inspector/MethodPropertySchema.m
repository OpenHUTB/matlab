classdef MethodPropertySchema<classdiagram.app.core.inspector.PropertySchemaInterface
    properties(Access=public)
MethodMeta
InfoMap
    end

    methods(Access=public)
        function obj=MethodPropertySchema(element)
            metaClass=meta.class.fromName(element.getOwningClass().getName());
            metas=findobj(metaClass.MethodList,"Name",element.getName());
            obj.MethodMeta=metas(1);
            obj.InfoMap=containers.Map;
        end

        function label=getDisplayLabel(~)
            label=message('classdiagram_editor:messages:PI_Method').string;
        end

        function subprops=subProperties(~,prop)
            if prop==classdiagram.app.core.inspector.InspectorProvider.RootID
                subprops=["Method|GeneralGroup","Method|AccessGroup"];
            else
                if prop=="Method|GeneralGroup"
                    subprops=["Method|Name","Method|DefiningClass"];
                elseif prop=="Method|AccessGroup"
                    subprops=["Method|Static","Method|Abstract","Method|Access",...
                    "Method|Sealed","Method|Hidden"];
                else
                    subprops=[];
                end
            end
        end

        function hasSubProp=hasSubProperties(~,prop)
            switch prop
            case{"Method|GeneralGroup","Method|AccessGroup"}
                hasSubProp=true;
            otherwise
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
                    case "Method|GeneralGroup"
                        info.Label=message('classdiagram_editor:messages:PI_GeneralGroup').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Method|AccessGroup"
                        info.Label=message('classdiagram_editor:messages:PI_AccessGroup').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Method|Name"
                        info.Label=message('classdiagram_editor:messages:PI_Name').string;
                        info.Value=obj.MethodMeta.Name;
                        info.Renderer="IconLabelRenderer";
                    case "Method|DefiningClass"
                        info.Label=message('classdiagram_editor:messages:PI_DefiningClass').string;
                        nameParts=string(obj.MethodMeta.DefiningClass.Name).split('.');
                        info.Value=nameParts(end);
                        info.Tooltip=obj.MethodMeta.DefiningClass.Name;
                        info.Renderer="IconLabelRenderer";
                    case "Method|Static"
                        info.Label="Static";
                        info.Value=obj.MethodMeta.Static;
                        info.Renderer="IconLabelRenderer";
                    case "Method|Abstract"
                        info.Label="Abstract";
                        info.Value=obj.MethodMeta.Abstract;
                        info.Renderer="IconLabelRenderer";
                    case "Method|Access"
                        info.Label=message('classdiagram_editor:messages:PI_AccessGroup').string;
                        info.Value=obj.getAccessList();
                        info.Renderer="IconLabelRenderer";
                    case "Method|Sealed"
                        info.Label=message('classdiagram_editor:messages:PI_Sealed').string;
                        info.Value=obj.MethodMeta.Sealed;
                        info.Renderer="IconLabelRenderer";
                    case "Method|Hidden"
                        info.Label=message('classdiagram_editor:messages:PI_Hidden').string;
                        info.Value=obj.MethodMeta.Hidden;
                        info.Renderer="IconLabelRenderer";
                    end

                    obj.InfoMap(prop)=info;
                end
            end
        end

        function support=supportTabs(~)
            support=false;
        end

        function expandGroups=defaultExpandGroups(obj)
            expandGroups=obj.subProperties(classdiagram.app.core.inspector.InspectorProvider.RootID);
        end
    end

    methods(Access=private)
        function accessList=getAccessList(obj)
            if ischar(obj.MethodMeta.Access)
                accessList=string(obj.MethodMeta.Access);
            else

                accessClassName=string(cellfun(@(x)x.Name,obj.MethodMeta.Access,'UniformOutput',false));
                accessList=accessClassName.join(", ");
            end
        end
    end
end

