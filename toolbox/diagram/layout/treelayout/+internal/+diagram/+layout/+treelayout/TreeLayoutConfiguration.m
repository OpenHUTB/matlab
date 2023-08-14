classdef TreeLayoutConfiguration



    properties
        RootLocation=internal.diagram.layout.treelayout.Location.Top;
        AlignmentInLevel=internal.diagram.layout.treelayout.AlignmentInLevel.TowardsRoot;
    end

    methods

        function gap=getGapBetweenLevels(~,level)
            gap=100;
        end

        function gap=getGapBetweenNodes(~,n1,n2)
            gap=15;
        end

    end

end

