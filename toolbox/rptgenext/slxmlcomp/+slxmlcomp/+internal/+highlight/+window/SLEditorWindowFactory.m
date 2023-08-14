classdef SLEditorWindowFactory<slxmlcomp.internal.highlight.WindowFactory




    properties(Access=private)
WindowResolver
LocationStyleFactory
StyleChangeAfterMergeNotifier
ContentId
    end

    methods(Access=public)
        function obj=SLEditorWindowFactory(...
            locationStyleFactory,...
            styleChangeAfterMergeNotifier,...
contentId...
            )
            obj.LocationStyleFactory=locationStyleFactory;
            obj.StyleChangeAfterMergeNotifier=styleChangeAfterMergeNotifier;
            obj.ContentId=contentId;
            obj.WindowResolver=slxmlcomp.internal.highlight.window.SLEditorWindowResolver();
        end

        function canHandle=canDisplay(obj,location)
            canHandle=~isempty(...
            obj.WindowResolver.getInfo(location)...
            );
        end

        function window=create(obj,location)
            window=slxmlcomp.internal.highlight.window.SLEditorHighlightWindow.newInstance(...
            location,...
            obj.LocationStyleFactory,...
            obj.StyleChangeAfterMergeNotifier,...
            obj.createTraversalFactory(),...
            obj.ContentId...
            );
        end

    end

    methods(Access=private)
        function factory=createTraversalFactory(obj)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.gui.highlight.SLEditorTraversalFactory;
            factory=SLEditorTraversalFactory();
        end
    end

end
