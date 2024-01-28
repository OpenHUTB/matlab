classdef Highlighter<handle

    properties(Access=private)
HighlightableContentIDs
WindowManager
    end


    methods(Static)
        function highlighter=forTwoWay(windowView)
            import sldiff.internal.highlight.window.*

            reportFactory=ReportWindowFactory(windowView);
            highlighter=makeTwoWayHighlighter(reportFactory);
        end


        function highlighter=forTesting(reportFactory)
            highlighter=makeTwoWayHighlighter(reportFactory);
        end
    end


    methods
        function obj=Highlighter(reportFactory,layout,highlightableContentIDs)

            obj.HighlightableContentIDs=highlightableContentIDs;

            factories=createSideWindowGroupFactories();

            factories(end+1)=reportFactory;

            import comparisons.internal.highlight.*
            obj.WindowManager=WindowManager(layout,factories);
        end


        function highlight(obj,locations)
            assert(length(obj.HighlightableContentIDs)==length(locations));

            for idx=1:length(locations)
                contentId=obj.HighlightableContentIDs(idx);
                location=locations(idx);

                window=obj.WindowManager.getWindow(contentId);
                window.applyAttentionStyle(location);
                window.zoomToShow(location);
            end
        end
    end
end


function factories=createSideWindowGroupFactories()
    import comparisons.internal.highlight.*

    factories=comparisons.internal.highlight.ContentWindowFactory.empty();
    for contentId=ContentId.AllSides
        factories(end+1)=createSideWindowGroupFactory(...
        contentId);%#ok<AGROW>
    end
end


function factory=createSideWindowGroupFactory(contentId)

    import systemcomposer.internal.highlight.window.SLXEditorWindowFactory

    sideFactories=SLXEditorWindowFactory(contentId);

    import comparisons.internal.highlight.*
    factory=WindowGroupFactory(sideFactories,contentId);
end

function highlighter=makeTwoWayHighlighter(reportFactory)
    import sldiff.internal.highlight.layout.*
    import systemcomposer.internal.highlight.Highlighter
    import comparisons.internal.highlight.*

    layout=makeTwoSystemLayout(ContentId.Left,ContentId.Right);
    highlightableContentIDs=[ContentId.Left,ContentId.Right];

    highlighter=Highlighter(reportFactory,layout,highlightableContentIDs);
end
