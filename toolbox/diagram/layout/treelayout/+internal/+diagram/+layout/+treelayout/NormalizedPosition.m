classdef NormalizedPosition<handle



    properties(Access='private')
        x_relativeToRoot;
        y_relativeToRoot;
        treeLayout;
    end

    methods
        function obj=NormalizedPosition(treeLayout,x_relativeToRoot,y_relativeToRoot)
            obj.treeLayout=treeLayout;
            obj.setLocation(x_relativeToRoot,y_relativeToRoot);
        end

        function x=getX(obj)
            x=obj.x_relativeToRoot-obj.treeLayout.boundsLeft;
        end

        function y=getY(obj)
            y=obj.y_relativeToRoot-obj.treeLayout.boundsTop;
        end

        function setLocation(obj,x_relativeToRoot,y_relativeToRoot)
            obj.x_relativeToRoot=x_relativeToRoot;
            obj.y_relativeToRoot=y_relativeToRoot;
        end
    end
end