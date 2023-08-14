classdef ClassPropertySchema<classdiagram.app.core.inspector.PropertySchemaInterface
    properties(Access=public)
ClassMeta
PropertyClassList
MethodClassList
EventClassList
InfoMap
    end

    methods(Access=public)
        function obj=ClassPropertySchema(element)
            obj.ClassMeta=meta.class.fromName(element.getName());
            obj.PropertyClassList=obj.getClassPropertyHierarchy();
            obj.MethodClassList=obj.getClassMethodHierarchy();
            obj.EventClassList=obj.getClassEventHierarchy();
            obj.InfoMap=containers.Map;
        end

        function label=getDisplayLabel(~)
            label=message('classdiagram_editor:messages:PI_Class').string;
        end

        function subprops=subProperties(obj,prop)
            prop=string(prop);
            if prop==classdiagram.app.core.inspector.InspectorProvider.RootID
                if isempty(obj.ClassMeta.SuperclassList)
                    subprops="Class|GeneralGroup";
                else
                    subprops=["Class|GeneralGroup","Class|SuperclassList"];
                end

                if~isempty(obj.ClassMeta.PropertyList)
                    subprops=[subprops,"Class|Properties"];
                end

                if~isempty(obj.ClassMeta.MethodList)
                    subprops=[subprops,"Class|Methods"];
                end

                if~isempty(obj.ClassMeta.EventList)
                    subprops=[subprops,"Class|Events"];
                end
            else
                if prop=="Class|GeneralGroup"
                    subprops=["Class|Name","Class|Package","Class|Handle","Class|Abstract","Class|Sealed","Class|Hidden"];
                elseif prop=="Class|SuperclassList"
                    len=length(obj.ClassMeta.SuperclassList);
                    if len>1
                        subprops=string({obj.ClassMeta.SuperclassList.Name});
                    else
                        subprops=[];
                    end
                elseif prop=="Class|Properties"
                    subprops=obj.PropertyClassList;
                elseif prop=="Class|Methods"
                    subprops=obj.MethodClassList;
                elseif prop=="Class|Events"
                    subprops=obj.EventClassList;
                else
                    if~isempty(obj.PropertyClassList)&&ismember(prop,obj.PropertyClassList)
                        s=prop.split("|");
                        subprops=obj.getClassProperties(s(2));
                    elseif~isempty(obj.MethodClassList)&&ismember(prop,obj.MethodClassList)
                        s=prop.split("|");
                        subprops=obj.getClassMethods(s(2));
                    elseif~isempty(obj.EventClassList)&&ismember(prop,obj.EventClassList)
                        s=prop.split("|");
                        subprops=obj.getClassEvents(s(2));
                    else
                        subprops=[];
                    end
                end
            end
        end

        function hasSubProp=hasSubProperties(obj,prop)
            switch prop
            case "Class|GeneralGroup"
                hasSubProp=true;
            case "Class|SuperclassList"
                if length(obj.ClassMeta.SuperclassList)>1
                    hasSubProp=true;
                else
                    hasSubProp=false;
                end
            case "Class|Properties"
                if~isempty(obj.PropertyClassList)
                    hasSubProp=true;
                else
                    hasSubProp=false;
                end
            case "Class|Methods"
                if~isempty(obj.MethodClassList)
                    hasSubProp=true;
                else
                    hasSubProp=false;
                end
            case "Class|Events"
                if~isempty(obj.EventClassList)
                    hasSubProp=true;
                else
                    hasSubProp=false;
                end
            otherwise
                if~isempty(obj.MethodClassList)&&ismember(prop,obj.MethodClassList)
                    hasSubProp=true;
                elseif~isempty(obj.PropertyClassList)&&ismember(prop,obj.PropertyClassList)
                    hasSubProp=true;
                elseif~isempty(obj.EventClassList)&&ismember(prop,obj.EventClassList)
                    hasSubProp=true;
                else
                    hasSubProp=false;
                end
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
                    case "Class|GeneralGroup"
                        info.Label=message('classdiagram_editor:messages:PI_GeneralGroup').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Class|Name"
                        info.Label=message('classdiagram_editor:messages:PI_Name').string;
                        info.Tooltip=obj.ClassMeta.Name;
                        nameParts=string(obj.ClassMeta.Name).split('.');
                        info.Value=nameParts(end);
                        info.Renderer="IconLabelRenderer";
                    case "Class|Package"
                        info.Label=message('classdiagram_editor:messages:PI_Package').string;
                        if isempty(obj.ClassMeta.ContainingPackage)
                            info.Value="";
                        else
                            info.Tooltip=obj.ClassMeta.ContainingPackage.Name;
                            nameParts=string(obj.ClassMeta.ContainingPackage.Name).split('.');
                            info.Value=nameParts(end);
                        end
                        info.Renderer="IconLabelRenderer";
                    case "Class|Handle"
                        info.Label=message('classdiagram_editor:messages:PI_Handle').string;
                        hMeta=?handle;
                        info.Value=obj.ClassMeta<hMeta||obj.ClassMeta.Name=="handle";
                        info.Renderer="IconLabelRenderer";
                    case "Class|Abstract"
                        info.Label=message('classdiagram_editor:messages:PI_Abstract').string;
                        info.Value=obj.ClassMeta.Abstract;
                        info.Renderer="IconLabelRenderer";
                    case "Class|Sealed"
                        info.Label=message('classdiagram_editor:messages:PI_Sealed').string;
                        info.Value=obj.ClassMeta.Sealed;
                        info.Renderer="IconLabelRenderer";
                    case "Class|Hidden"
                        info.Label=message('classdiagram_editor:messages:PI_Hidden').string;
                        info.Value=obj.ClassMeta.Hidden;
                        info.Renderer="IconLabelRenderer";
                    case "Class|SuperclassList"
                        if~obj.hasSubProperties(prop)
                            info.Label=message('classdiagram_editor:messages:PI_Superclass').string;
                            info.Value=obj.getSuperClass();
                        else
                            info.Label=message('classdiagram_editor:messages:PI_Superclasses').string;
                            info.Value="";
                        end
                        info.Renderer="IconLabelRenderer";
                    case "Class|Properties"
                        info.Label=message('classdiagram_editor:messages:PI_Properties').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Class|Methods"
                        info.Label=message('classdiagram_editor:messages:PI_Methods').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Class|Events"
                        info.Label=message('classdiagram_editor:messages:PI_Events').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    otherwise
                        if(~isempty(obj.MethodClassList)&&ismember(prop,obj.MethodClassList))||...
                            (~isempty(obj.PropertyClassList)&&ismember(prop,obj.PropertyClassList))||...
                            (~isempty(obj.EventClassList)&&ismember(prop,obj.EventClassList))
                            nameParts=prop.split("|");
                            fqn=nameParts(end).split(".");
                            info.Label=fqn(end);
                            info.Tooltip=nameParts(end);
                        else
                            info.Label=prop;
                        end
                        info.Value="";
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

    methods(Access=public)
        function superclass=getSuperClass(obj)

            superclass="";
            if~isempty(obj.ClassMeta.SuperclassList)
                superclass=string(obj.ClassMeta.SuperclassList.Name);
            end
        end

        function hierarchy=getHierarchy(obj)
            hierarchy=string(obj.ClassMeta.Name);
            if isempty(obj.ClassMeta.SuperclassList)
                return;
            end

            for i=1:length(obj.ClassMeta.SuperclassList)
                hierarchy=[hierarchy,obj.getClassHierarchy(obj.ClassMeta.SuperclassList(i))];
            end
        end

        function hierarchy=getClassHierarchy(obj,classMeta)
            hierarchy=string(classMeta.Name);
            if isempty(obj.ClassMeta.SuperclassList)
                return;
            end
            for i=1:length(classMeta.SuperclassList)
                hierarchy=[hierarchy,obj.getClassHierarchy(classMeta.SuperclassList(i))];
            end
        end

        function mHierarchy=getClassMethodHierarchy(obj)
            if isempty(obj.ClassMeta)||isempty(obj.ClassMeta.MethodList)
                mHierarchy=[];
            else
                nonEmptyList=obj.ClassMeta.MethodList(~strcmp({obj.ClassMeta.MethodList.Name},"empty"));
                if isempty(nonEmptyList)
                    mHierarchy=[];
                    return;
                end

                definingClass=[nonEmptyList.DefiningClass];
                definingClassName=unique(string({definingClass.Name}),'stable');
                mHierarchy=arrayfun(@(x)"Method|"+x,definingClassName);
            end
        end

        function pHierarchy=getClassPropertyHierarchy(obj)

            if isempty(obj.ClassMeta)||isempty(obj.ClassMeta.PropertyList)
                pHierarchy=[];
            else
                definingClass=[obj.ClassMeta.PropertyList.DefiningClass];
                definingClassName=unique(string({definingClass.Name}),'stable');
                pHierarchy=arrayfun(@(x)"Property|"+x,definingClassName);
            end
        end

        function eHierarchy=getClassEventHierarchy(obj)

            if isempty(obj.ClassMeta.EventList)
                eHierarchy=[];
            else
                definingClass=[obj.ClassMeta.EventList.DefiningClass];
                definingClassName=unique(string({definingClass.Name}),'stable');
                eHierarchy=arrayfun(@(x)"Event|"+x,definingClassName);
            end
        end

        function methodNames=getClassMethods(obj,className)

            if isempty(obj.ClassMeta.MethodList)
                methodNames=[];
            else
                nonEmptyList=obj.ClassMeta.MethodList(~strcmp({obj.ClassMeta.MethodList.Name},"empty"));
                if isempty(nonEmptyList)
                    methodNames=[];
                    return;
                end
                definingClass=[nonEmptyList.DefiningClass];
                definingClassName=string({definingClass.Name});
                methods=nonEmptyList(strcmp(className,definingClassName));
                methods(ismember({methods.Name},...
                classdiagram.app.mcos.MCOSConstants.FilteredMethods))=[];

                [~,idx]=unique({methods.Name},'stable');
                methods=methods(idx);
                methodNames=arrayfun(@(e)string(e.Name),methods)';
            end
        end

        function propNames=getClassProperties(obj,className)

            if isempty(obj.ClassMeta.PropertyList)
                propNames=[];
            else
                definingClass=[obj.ClassMeta.PropertyList.DefiningClass];
                definingClassName=string({definingClass.Name});
                props=obj.ClassMeta.PropertyList(strcmp(className,definingClassName));
                propNames=arrayfun(@(e)string(e.Name),props)';
            end
        end

        function eventNames=getClassEvents(obj,className)

            if isempty(obj.ClassMeta.EventList)
                eventNames=[];
            else
                definingClass=[obj.ClassMeta.EventList.DefiningClass];
                definingClassName=string({definingClass.Name});
                events=obj.ClassMeta.EventList(strcmp(className,definingClassName));
                eventNames=arrayfun(@(e)string(e.Name),events)';
            end
        end
    end
end

