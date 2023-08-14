classdef SplitButtonAction<handle




    properties(Access=private)
        DisplayLabel;
        Tag;
        Icon;
    end

    methods
        function obj=SplitButtonAction(label,tag,icon)
            obj.DisplayLabel=label;
            obj.Tag=tag;
            obj.Icon=icon;
        end

        function txt=getDisplayLabel(obj)
            txt=obj.DisplayLabel;
        end

        function icon=getDisplayIcon(obj)
            icon=obj.Icon;
        end

        function tag=getTag(obj)
            tag=obj.Tag;
        end

        function enabled=getEnabled(~)
            enabled=true;
        end
    end
end
