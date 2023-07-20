classdef FixedPositionLayout<comparisons.internal.highlight.ComparisonLayout




    properties(GetAccess=public,SetAccess=private,Dependent)
ContentIds
    end

    properties(Access=private)
Windows
Positions
    end

    methods(Access=public)

        function obj=FixedPositionLayout(positions)
            obj.Positions=positions;
            obj.Windows=struct();
        end

        function window=getWindow(obj,contentId)
            window=obj.Windows.(contentId);
        end

        function addWindow(obj,window,contentId)
            obj.Windows.(contentId)=window;
        end

        function layout(obj)
            for contentIdCell=fields(obj.Windows)'
                contentId=contentIdCell{1};
                window=obj.Windows.(contentId);
                window.setPosition(obj.Positions.(contentId));
            end
        end

        function areEqual=eq(obj,other)
            areEqual=isequal(obj.Positions,other.Positions);
        end

    end

    methods
        function ids=get.ContentIds(obj)
            ids=string(fields(obj.Positions))';
        end
    end

end
