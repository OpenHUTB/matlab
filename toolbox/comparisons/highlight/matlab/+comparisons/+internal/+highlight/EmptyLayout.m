classdef EmptyLayout<comparisons.internal.highlight.ComparisonLayout




    properties(GetAccess=public,SetAccess=private)
        ContentIds=string.empty;
    end


    methods(Access=public)

        function addWindow(~,~,~)

        end

        function window=getWindow(~,~)
            window=[];
        end

        function layout(~)

        end

    end

end
