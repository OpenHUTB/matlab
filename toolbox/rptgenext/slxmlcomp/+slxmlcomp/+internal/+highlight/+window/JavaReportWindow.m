classdef JavaReportWindow<handle&slxmlcomp.internal.highlight.HighlightWindow

    properties(Access=private)
JReport
    end



    methods(Access=public)
        function obj=JavaReportWindow(jReport)
            obj.JReport=jReport;
        end

        function setPosition(obj,position)
            slxmlcomp.internal.highlight.setReportWindowPosition(...
            obj.JReport,...
position...
            );
        end

        function bool=canDisplay(~,~)
            bool=true;
        end




        function applyAttentionStyle(~,~)

        end

        function clearAttentionStyle(~)

        end

        function applyDiffStyles(~,~)

        end

        function clearDiffStyles(~)

        end

        function zoomToShow(~,~)

        end

        function show(~)

        end

        function hide(~)

        end
    end

end
