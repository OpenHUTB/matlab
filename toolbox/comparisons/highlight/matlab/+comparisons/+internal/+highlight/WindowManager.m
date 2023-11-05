classdef WindowManager<handle

    properties(Access=private)
Layout
ContentWindowFactories
AllWindows
    end

    methods(Access=public)
        function obj=WindowManager(layout,contentWindowFactories)
            obj.Layout=comparisons.internal.highlight.EmptyLayout();
            obj.ContentWindowFactories=contentWindowFactories;
            obj.AllWindows=struct();
            obj.changeLayout(layout);
        end

        function changeLayout(obj,newLayout)
            if isequal(newLayout,obj.Layout)
                return
            end



            oldLayout=obj.Layout;

            for contentId=oldLayout.ContentIds
                window=oldLayout.getWindow(contentId);

                if ismember(contentId,newLayout.ContentIds)
                    newLayout.addWindow(window,contentId);
                else
                    window.hide();
                end

                obj.AllWindows.(contentId)=window;
            end



            for contentId=newLayout.ContentIds
                if ismember(contentId,oldLayout.ContentIds)

                    continue
                end



                if isfield(obj.AllWindows,contentId)
                    window=obj.AllWindows.(contentId);
                    newLayout.addWindow(window,contentId);
                else
                    newWindow=obj.getWindowFactory(contentId).create(contentId);
                    newLayout.addWindow(newWindow,contentId)
                    obj.AllWindows.(contentId)=newWindow;
                end
            end

            newLayout.layout();
            obj.Layout=newLayout;



            for window=obj.getActiveWindows()
                window.show();
            end
        end

        function activeWindows=getActiveWindows(obj)
            activeWindows=comparisons.internal.highlight.HighlightWindow.empty;

            for contentId=obj.Layout.ContentIds
                window=obj.Layout.getWindow(contentId);
                activeWindows(end+1)=window;%#ok<AGROW>
            end
        end

        function window=getWindow(obj,contentId)
            window=obj.Layout.getWindow(contentId);
        end

        function delete(obj)


            delete(obj.Layout)
            import comparisons.internal.highlight.deleteStructValues
            deleteStructValues(obj.AllWindows);
        end
    end

    methods(Access=private)
        function foundFactory=getWindowFactory(obj,contentId)
            for factory=obj.ContentWindowFactories
                if factory.canDisplay(contentId)
                    foundFactory=factory;
                    return
                end
            end
            error("Factory not found for contentId: "+contentId);
        end
    end

end
