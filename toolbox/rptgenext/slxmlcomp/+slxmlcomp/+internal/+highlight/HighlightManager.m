classdef HighlightManager<handle




    properties(Access=private)
WindowManager
CurrentComparison
    end

    methods
        function obj=HighlightManager(windowManager)
            obj.WindowManager=windowManager;
        end

        function layoutChanged(obj,newLayout)
            obj.WindowManager.changeLayout(newLayout);
        end

        function comparisonChanged(obj,newComparison)
            for window=obj.WindowManager.getActiveWindows()
                window.applyDiffStyles(newComparison);
            end
            obj.CurrentComparison=newComparison;
        end

        function highlight(obj,location,contentId)
            window=obj.WindowManager.getWindow(contentId);

            window.applyAttentionStyle(location);
            window.zoomToShow(location);

            if~isempty(obj.CurrentComparison)
                window.applyDiffStyles(obj.CurrentComparison);
            end
        end

        function delete(obj)
            delete(obj.WindowManager)
        end

    end
end
