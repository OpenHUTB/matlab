classdef NewSystemObjectAction<handle




    properties(Access=private)
        DisplayLabel;
        Tag;
    end

    methods
        function obj=NewSystemObjectAction(label,tag)
            obj.DisplayLabel=label;
            obj.Tag=tag;
        end

        function txt=getDisplayLabel(obj)
            txt=obj.DisplayLabel;
        end

        function icon=getDisplayIcon(~)
            icon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','New_class_ts_16.png');
        end

        function enabled=getEnabled(~)
            enabled=true;
        end

        function tag=getTag(obj)
            tag=obj.Tag;
        end
    end
end
