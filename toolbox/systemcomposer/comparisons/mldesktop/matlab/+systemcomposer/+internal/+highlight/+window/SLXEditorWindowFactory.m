classdef SLXEditorWindowFactory<comparisons.internal.highlight.WindowFactory




    properties(Access=private)
ContentId
    end

    methods(Access=public)
        function obj=SLXEditorWindowFactory(contentId)
            obj.ContentId=contentId;
        end

        function canHandle=canDisplay(~,location)
            import systemcomposer.internal.highlight.window.isSupportedBySLXEditor
            canHandle=isSupportedBySLXEditor(location.Type);
        end

        function window=create(obj,location)
            window=systemcomposer.internal.highlight.window.SLXEditorHighlightWindow(...
            location,...
            obj.ContentId...
            );
        end

    end

end
