classdef EnumPropertySchema<classdiagram.app.core.inspector.PropertySchemaInterface

    properties(Access=public)
EnumMeta
EnumMembers
InfoMap
    end

    methods(Access=public)
        function obj=EnumPropertySchema(element)
            obj.EnumMeta=meta.class.fromName(element.getName());
            obj.EnumMembers="EnumValue|"+string({obj.EnumMeta.EnumerationMemberList.Name});
            obj.InfoMap=containers.Map;
        end

        function label=getDisplayLabel(~)
            label=message('classdiagram_editor:messages:PI_Enum').string;
        end

        function subprops=subProperties(obj,prop)
            if prop==classdiagram.app.core.inspector.InspectorProvider.RootID
                if isempty(obj.EnumMeta.SuperclassList)
                    subprops="Enum|GeneralGroup";
                else
                    subprops=["Enum|GeneralGroup","Enum|SuperclassList"];
                end
            else
                if prop=="Enum|GeneralGroup"
                    subprops=["Enum|Name","Enum|Package","Enum|EnumerationMemberList","Enum|Handle","Enum|Abstract","Enum|Sealed","Enum|Hidden"];
                elseif prop=="Enum|EnumerationMemberList"
                    subprops=obj.EnumMembers;
                elseif prop=="Enum|SuperclassList"
                    len=length(obj.EnumMeta.SuperclassList);
                    if len>1
                        subprops=string({obj.EnumMeta.SuperclassList.Name});
                    else
                        subprops=[];
                    end
                else
                    subprops=[];
                end
            end
        end

        function hasSubProp=hasSubProperties(obj,prop)
            switch prop
            case{"Enum|GeneralGroup","Enum|EnumerationMemberList"}
                hasSubProp=true;
            case "Enum|SuperclassList"
                if length(obj.EnumMeta.SuperclassList)>1
                    hasSubProp=true;
                else
                    hasSubProp=false;
                end
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
                    case "Enum|GeneralGroup"
                        info.Label=message('classdiagram_editor:messages:PI_GeneralGroup').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Enum|EnumerationMemberList"
                        info.Label=message('classdiagram_editor:messages:PI_EnumerationMemberList').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Enum|Name"
                        info.Label=message('classdiagram_editor:messages:PI_Name').string;
                        info.Tooltip=obj.EnumMeta.Name;
                        nameParts=string(obj.EnumMeta.Name).split('.');
                        info.Value=nameParts(end);
                        info.Renderer="IconLabelRenderer";
                    case "Enum|Package"
                        info.Label=message('classdiagram_editor:messages:PI_Package').string;
                        if isempty(obj.EnumMeta.ContainingPackage)
                            info.Value="";
                        else
                            nameParts=string(obj.EnumMeta.ContainingPackage.Name).split('.');
                            info.Value=nameParts(end);
                            info.Tooltip=obj.EnumMeta.ContainingPackage.Name;
                        end
                        info.Renderer="IconLabelRenderer";
                    case "Enum|Handle"
                        info.Label=message('classdiagram_editor:messages:PI_Handle').string;
                        hMeta=?handle;
                        info.Value=obj.EnumMeta<hMeta;
                        info.Renderer="IconLabelRenderer";
                    case "Enum|Abstract"
                        info.Label=message('classdiagram_editor:messages:PI_Abstract').string;
                        info.Value=obj.EnumMeta.Abstract;
                        info.Renderer="IconLabelRenderer";
                    case "Enum|Sealed"
                        info.Label=message('classdiagram_editor:messages:PI_Sealed').string;
                        info.Value=obj.EnumMeta.Sealed;
                        info.Renderer="IconLabelRenderer";
                    case "Enum|Hidden"
                        info.Label=message('classdiagram_editor:messages:PI_Hidden').string;
                        info.Value=obj.EnumMeta.Hidden;
                        info.Renderer="IconLabelRenderer";
                    case "Enum|SuperclassList"
                        if~obj.hasSubProperties(prop)
                            info.Label=message('classdiagram_editor:messages:PI_Superclass').string;
                            info.Value=obj.getSuperClass();
                        else
                            info.Label=message('classdiagram_editor:messages:PI_Superclasses').string;
                            info.Value="";
                        end
                        info.Renderer="IconLabelRenderer";
                    otherwise


                        if ismember(prop,obj.EnumMembers)
                            s=prop.split("|");
                            info.Label=s(2);
                            info.Value=obj.getEnumValue(prop);
                        else

                            info.Label=prop;
                            info.Value="";
                        end
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
        function superclass=getSuperClass(obj)

            superclass="";
            if~isempty(obj.EnumMeta.SuperclassList)
                superclass=string(obj.EnumMeta.SuperclassList.Name);
            end
        end

        function value=getEnumValue(obj,prop)
            value="";
            if ismember(prop,obj.EnumMembers)&&~isempty(obj.EnumMeta.SuperclassList)
                s=prop.split("|");
                evalcString=string(obj.EnumMeta.SuperclassList(1).Name)+"("+obj.EnumMeta.Name+"."+s(2)+")";
                try
                    value=string(eval(evalcString));
                catch

                end

                if value==s(2)
                    value="";
                end
            end
        end
    end
end

