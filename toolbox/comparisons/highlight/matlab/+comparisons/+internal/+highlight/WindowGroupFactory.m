classdef WindowGroupFactory<comparisons.internal.highlight.ContentWindowFactory




    properties(Access=private)
WindowFactories
SupportedContent
    end

    methods(Access=public)
        function obj=WindowGroupFactory(windowFactories,supportedContent)
            obj.WindowFactories=windowFactories;
            obj.SupportedContent=supportedContent;
        end

        function bool=canDisplay(obj,contentId)
            bool=ismember(contentId,obj.SupportedContent);
        end

        function window=create(obj,contentId)
            import comparisons.internal.highlight.WindowGroup
            window=WindowGroup(obj.WindowFactories,contentId);
        end

    end

end
