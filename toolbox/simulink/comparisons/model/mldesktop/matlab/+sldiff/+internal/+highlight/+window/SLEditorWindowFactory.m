classdef SLEditorWindowFactory<comparisons.internal.highlight.WindowFactory




    properties(Access=private)
ContentId
    end

    methods(Access=public)
        function obj=SLEditorWindowFactory(contentId)
            obj.ContentId=contentId;
        end

        function canHandle=canDisplay(~,location)
            import sldiff.internal.highlight.window.isSupportedBySLEditor
            canHandle=isSupportedBySLEditor(location.Type);
        end

        function window=create(obj,location)
            window=sldiff.internal.highlight.window.SLEditorHighlightWindow(...
            location,...
            obj.ContentId...
            );
        end

    end

end