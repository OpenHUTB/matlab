classdef Highlighter<handle




    properties(Access=private)
WindowManager
    end

    methods(Static)
        function highlighter=forTwoWay(reportWindow,layout)
            if nargin<2
                layout=defaultTwoLayout();
            end

            import sldiff.internal.highlight.window.ReportWindowFactory
            reportFactory=ReportWindowFactory(reportWindow);
            import sldiff.internal.highlight.Highlighter
            highlighter=Highlighter(reportFactory,layout);
        end

        function highlighter=forTesting(reportFactory)
            highlighter=sldiff.internal.highlight.Highlighter(...
            reportFactory,defaultTwoLayout());
        end
    end

    methods
        function obj=Highlighter(reportFactory,layout)

            factories=createSideWindowGroupFactories();

            factories(end+1)=reportFactory;

            import comparisons.internal.highlight.WindowManager
            obj.WindowManager=WindowManager(layout,factories);


        end

        function highlight(obj,locations,contentIDs)
            assert(length(locations)==length(contentIDs));
            for idx=1:length(locations)
                contentId=contentIDs(idx);
                location=locations(idx);

                window=obj.WindowManager.getWindow(contentId);
                window.applyAttentionStyle(location);
                window.zoomToShow(location);
            end

        end

        function changeLayout(obj,layout)
            obj.WindowManager.changeLayout(layout);
        end

    end

end

function factories=createSideWindowGroupFactories()
    import comparisons.internal.highlight.ContentId

    factories=comparisons.internal.highlight.ContentWindowFactory.empty();
    for contentId=ContentId.AllSides
        factories(end+1)=createSideWindowGroupFactory(...
        contentId);%#ok<AGROW>
    end
end

function factory=createSideWindowGroupFactory(contentId)

    import sldiff.internal.highlight.window.SLEditorWindowFactory

    sideFactories=[SLEditorWindowFactory(contentId)];

    import comparisons.internal.highlight.WindowGroupFactory
    factory=WindowGroupFactory(sideFactories,contentId);
end

function layout=defaultTwoLayout()
    import sldiff.internal.highlight.layout.makeTwoSystemLayout
    import comparisons.internal.highlight.ContentId
    layout=makeTwoSystemLayout(ContentId.Left,ContentId.Right);
end
