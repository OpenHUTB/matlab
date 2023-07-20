classdef ReportWindow<handle&comparisons.internal.highlight.HighlightWindow

    properties(Access=private)
WindowView
    end



    methods(Access=public)
        function obj=ReportWindow(windowView)
            obj.WindowView=windowView;
        end

        function setPosition(obj,position)
            obj.WindowView.setPosition(position);
        end

        function bool=canDisplay(~,~)
            bool=true;
        end

        function applyAttentionStyle(~,~)

        end

        function clearAttentionStyle(~)

        end

        function zoomToShow(~,~)

        end

        function show(~)

        end

        function hide(~)

        end

        function bool=isVisible(~)

            bool=true;
        end
    end

end
