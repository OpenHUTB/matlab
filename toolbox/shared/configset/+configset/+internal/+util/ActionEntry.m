classdef ActionEntry<handle




    properties
DisplayLabel
        DisplayIcon=''
        Enabled=true
Tag
        ToolTip=''
    end

    methods
        function obj=ActionEntry(label,tag,icon,enabled,tooltip)

            obj.DisplayLabel=message(label).getString;
            obj.Tag=tag;
            if nargin>=3
                obj.DisplayIcon=icon;
            end
            if nargin>=4
                obj.Enabled=enabled;
            end
            if nargin>=5
                obj.ToolTip=message(tooltip).getString;
            end
        end

        function out=getDisplayLabel(obj)
            out=obj.DisplayLabel;
        end

        function out=getDisplayIcon(obj)
            out=obj.DisplayIcon;
        end

        function out=getEnabled(obj)
            out=obj.Enabled;
        end

        function out=getTag(obj)
            out=obj.Tag;
        end
    end
end
