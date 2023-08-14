classdef DeleteSplitButtonActionBuilder<handle




    properties
ID
DisplayIcon
DisplayLabel
Enabled
Tag

    end
    methods
        function obj=DeleteSplitButtonActionBuilder(name,icon,tag)
            assert(nargin>=1&&ischar(name));
            obj.DisplayLabel=name;
            obj.Enabled=true;
            obj.DisplayIcon='';
            obj.Tag='';

            if(nargin>=2)
                assert(ischar(icon));
                obj.DisplayIcon=icon;
            end
            if(nargin>=3)
                assert(ischar(tag));
                obj.Tag=tag;
            end
        end


        function txt=getDisplayLabel(obj)
            txt=obj.DisplayLabel;
        end
        function setDisplayLabel(obj,txt)
            obj.DisplayLabel=txt;
        end


        function icon=getDisplayIcon(obj)
            icon=obj.DisplayIcon;
        end
        function setDisplayIcon(obj,icon)
            obj.DisplayIcon=icon;
        end


        function enabled=getEnabled(obj)
            enabled=obj.Enabled;
        end
        function setEnabled(obj,enabled)
            obj.Enabled=enabled;
        end


        function tag=getTag(obj)
            tag=obj.Tag;
        end
        function setTag(obj,tag)
            obj.Tag=tag;
        end

    end
end
