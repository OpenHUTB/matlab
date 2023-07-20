classdef ParameterStaticInfo<configset.ParameterInfoBase








    properties(Hidden)
ParamInfo
    end

    properties(Dependent)
DefaultValue
DependsOn
    end

    methods
        function obj=ParameterStaticInfo(info)
            if isa(info,'configset.ParameterStaticInfo')
                obj.ParamInfo=info.ParamInfo;
            else
                obj.ParamInfo=info;
            end
        end

        function out=get.DefaultValue(obj)
            out=obj.ParamInfo.DefaultValue;
        end

        function out=get.DependsOn(obj)
            out=obj.getDependsOn;
        end




        function out=getName(obj)
            out=obj.ParamInfo.Name;
        end

        function out=getComponent(obj)
            out=obj.ParamInfo.Component;
        end

        function out=getType(obj)
            out=obj.ParamInfo.Type;
        end

        function out=getDescription(obj)
            out=obj.ParamInfo.getPrompt();
            if isempty(out)

                out=obj.ParamInfo.getDescription();
            end
        end

        function out=getDependsOn(obj)
            out=obj.ParamInfo.FullParent;
        end

        function out=getAllowedValues(obj)
            out=obj.ParamInfo.getAllowedValues;
            if isempty(out)&&length(obj.ParamInfo.WidgetList)==1
                out=obj.ParamInfo.WidgetList{1}.getAllowedValues;
            end
        end

        function out=getAllowedDisplayValues(obj)
            out=obj.ParamInfo.getDisplayedValues;
            if isempty(out)&&length(obj.ParamInfo.WidgetList)==1
                out=obj.ParamInfo.WidgetList{1}.getDisplayedValues;
            end
        end

        function out=getLongDescription(obj)
            out=obj.ParamInfo.getToolTip();
        end

        function out=getIsUI(obj)
            out=~obj.ParamInfo.Hidden;
        end

        function out=getIsDynamic(obj)
            out=obj.ParamInfo.isCustom();
        end

    end

end

