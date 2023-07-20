classdef PropPropertySchema<classdiagram.app.core.inspector.PropertySchemaInterface
    properties(Access=public)
PropertyMeta
InfoMap
    end

    methods(Access=public)
        function obj=PropPropertySchema(element)
            metaClass=meta.class.fromName(element.getOwningClass().getName());
            obj.PropertyMeta=findobj(metaClass.PropertyList,"Name",element.getName());
            obj.InfoMap=containers.Map;
        end

        function label=getDisplayLabel(~)
            label=message('classdiagram_editor:messages:PI_Property').string;
        end

        function subprops=subProperties(obj,prop)
            if prop==classdiagram.app.core.inspector.InspectorProvider.RootID
                subprops=["Property|GeneralGroup","Property|AccessGroup","Property|AdvancedGroup"];
            else
                if prop=="Property|GeneralGroup"
                    if isempty(obj.PropertyMeta.Validation)
                        subprops=["Property|Name","Property|DefaultValue"];
                    else
                        subprops=["Property|Name","Property|DefaultValue","Property|Validation"];
                    end

                elseif prop=="Property|AccessGroup"
                    subprops=["Property|GetAccess","Property|SetAccess","Property|Constant","Property|Abstract","Property|Hidden"];
                elseif prop=="Property|AdvancedGroup"
                    subprops=["Property|NonCopyable","Property|Transient","Property|PartialMatchPriority","Property|AbortSet",...
                    "Property|GetObservable","Property|SetObservable","Property|Dependent"];
                elseif prop=="Property|Validation"
                    if isempty(obj.PropertyMeta.Validation)
                        subprops=[];
                    else
                        subprops=["Property|Size","Property|Class","Property|Function"];
                    end
                else
                    subprops=[];
                end
            end
        end

        function hasSubProp=hasSubProperties(obj,prop)
            switch prop
            case{"Property|GeneralGroup","Property|AccessGroup","Property|AdvancedGroup"}
                hasSubProp=true;
            case "Property|Validation"
                if isempty(obj.PropertyMeta.Validation)
                    hasSubProp=false;
                else
                    hasSubProp=true;
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
                    case "Property|GeneralGroup"
                        info.Label=message('classdiagram_editor:messages:PI_GeneralGroup').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Property|AccessGroup"
                        info.Label=message('classdiagram_editor:messages:PI_AccessGroup').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Property|AdvancedGroup"
                        info.Label=message('classdiagram_editor:messages:PI_AdvancedGroup').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Property|Validation"
                        info.Label=message('classdiagram_editor:messages:PI_Validation').string;
                        info.Value="";
                        info.Renderer="IconLabelRenderer";
                    case "Property|Name"
                        info.Label=message('classdiagram_editor:messages:PI_Name').string;
                        info.Value=obj.PropertyMeta.Name;
                        info.Renderer="IconLabelRenderer";
                    case "Property|DefaultValue"
                        info.Label=message('classdiagram_editor:messages:PI_DefaultValue').string;
                        info.Value=obj.getDefaultValue();
                        info.Renderer="IconLabelRenderer";
                    case "Property|Size"
                        info.Label=message('classdiagram_editor:messages:PI_Size').string;
                        info.Value=obj.getValidationSize();
                        info.Renderer="IconLabelRenderer";
                    case "Property|Class"
                        info.Label=message('classdiagram_editor:messages:PI_Class').string;
                        info.Value=obj.getValidationClass();
                        info.Renderer="IconLabelRenderer";
                    case "Property|Function"
                        info.Label=message('classdiagram_editor:messages:PI_Function').string;
                        info.Value=obj.getValidationFunctions();
                        info.Renderer="IconLabelRenderer";
                    case "Property|GetAccess"
                        info.Label=message('classdiagram_editor:messages:PI_GetAccess').string;
                        info.Value=obj.getAccessList(true);
                        info.Renderer="IconLabelRenderer";
                    case "Property|SetAccess"
                        info.Label=message('classdiagram_editor:messages:PI_SetAccess').string;
                        info.Value=obj.getAccessList(false);
                        info.Renderer="IconLabelRenderer";
                    case "Property|Constant"
                        info.Label="Constant";
                        info.Value=obj.PropertyMeta.Constant;
                        info.Renderer="IconLabelRenderer";
                    case "Property|Abstract"
                        info.Label="Abstract";
                        info.Value=obj.PropertyMeta.Abstract;
                        info.Renderer="IconLabelRenderer";
                    case "Property|Hidden"
                        info.Label=message('classdiagram_editor:messages:PI_Hidden').string;
                        info.Value=obj.PropertyMeta.Hidden;
                        info.Renderer="IconLabelRenderer";
                    case "Property|NonCopyable"
                        info.Label=message('classdiagram_editor:messages:PI_NonCopyable').string;
                        info.Value=obj.PropertyMeta.NonCopyable;
                        info.Renderer="IconLabelRenderer";
                    case "Property|Transient"
                        info.Label=message('classdiagram_editor:messages:PI_Transient').string;
                        info.Value=obj.PropertyMeta.Transient;
                        info.Renderer="IconLabelRenderer";
                    case "Property|PartialMatchPriority"
                        info.Label=message('classdiagram_editor:messages:PI_PartialMatchPriority').string;
                        info.Value=string(obj.PropertyMeta.PartialMatchPriority);
                        info.Renderer="IconLabelRenderer";
                    case "Property|AbortSet"
                        info.Label=message('classdiagram_editor:messages:PI_AbortSet').string;
                        info.Value=obj.PropertyMeta.AbortSet;
                        info.Renderer="IconLabelRenderer";
                    case "Property|GetObservable"
                        info.Label=message('classdiagram_editor:messages:PI_GetObservable').string;
                        info.Value=obj.PropertyMeta.GetObservable;
                        info.Renderer="IconLabelRenderer";
                    case "Property|SetObservable"
                        info.Label=message('classdiagram_editor:messages:PI_SetObservable').string;
                        info.Value=obj.PropertyMeta.SetObservable;
                        info.Renderer="IconLabelRenderer";
                    case "Property|Dependent"
                        info.Label=message('classdiagram_editor:messages:PI_Dependent').string;
                        info.Value=obj.PropertyMeta.Dependent;
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
        function value=getDefaultValue(obj)
            value="";
            if obj.PropertyMeta.HasDefault
                value=string(evalc('disp(obj.PropertyMeta.DefaultValue)')).strip;
            end
        end

        function class=getValidationClass(obj)
            class="";
            if~isempty(obj.PropertyMeta.Validation)&&~isempty(obj.PropertyMeta.Validation.Class)
                class=obj.PropertyMeta.Validation.Class.Name;
            end
        end

        function func=getValidationFunctions(obj)
            func="";
            if~isempty(obj.PropertyMeta.Validation)&&~isempty(obj.PropertyMeta.Validation.ValidatorFunctions)
                for i=1:length(obj.PropertyMeta.Validation.ValidatorFunctions)
                    funcStr=string(func2str(obj.PropertyMeta.Validation.ValidatorFunctions{i}));
                    if func==""
                        func=funcStr;
                    else
                        func=func+", "+funcStr;
                    end
                end
            end
        end

        function size=getValidationSize(obj)
            size="";
            if~isempty(obj.PropertyMeta.Validation)&&~isempty(obj.PropertyMeta.Validation.Size)
                size="(";
                len=length(obj.PropertyMeta.Validation.Size);
                for i=1:len
                    s=obj.PropertyMeta.Validation.Size(i);
                    switch class(s)
                    case 'meta.FixedDimension'
                        size=size+s.Length;
                    case 'meta.UnrestrictedDimension'
                        size=size+":";
                    end

                    if i~=len
                        size=size+",";
                    else
                        size=size+")";
                    end
                end
            end
        end

        function accessList=getAccessList(obj,getAccess)
            if getAccess
                if ischar(obj.PropertyMeta.GetAccess)
                    accessList=string(obj.PropertyMeta.GetAccess);
                else

                    getClassName=string(cellfun(@(x)x.Name,obj.PropertyMeta.GetAccess,'UniformOutput',false));
                    accessList=getClassName.join(", ");
                end
            else
                if ischar(obj.PropertyMeta.SetAccess)
                    accessList=string(obj.PropertyMeta.SetAccess);
                else

                    setClassName=string(cellfun(@(x)x.Name,obj.PropertyMeta.SetAccess,'UniformOutput',false));
                    accessList=setClassName.join(", ");
                end
            end
        end
    end
end

