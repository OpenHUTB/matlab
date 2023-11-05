classdef WindowGroup<comparisons.internal.highlight.HighlightWindow

    properties(Access=private)
ActiveWindow
AllWindows
WindowFactories
Position
ContentId
ComparisonResult
    end


    methods(Access=public)
        function obj=WindowGroup(windowFactories,contentId)
            obj.WindowFactories=windowFactories;
            obj.ContentId=contentId;
            obj.AllWindows=comparisons.internal.highlight.HighlightWindow.empty();
        end

        function applyAttentionStyle(obj,location)

            previousActiveWindow=obj.ActiveWindow;

            obj.setActiveWindow(location);
            obj.ActiveWindow.clearAttentionStyle();
            obj.ActiveWindow.applyAttentionStyle(location);

            if~isempty(previousActiveWindow)&&~isequal(previousActiveWindow,obj.ActiveWindow)
                previousActiveWindow.clearAttentionStyle();
            end
        end

        function clearAttentionStyle(obj)
            if~isempty(obj.ActiveWindow)
                obj.ActiveWindow.clearAttentionStyle();
            end
        end

        function zoomToShow(obj,location)

            obj.setActiveWindow(location);
            obj.ActiveWindow.zoomToShow(location);

        end

        function setPosition(obj,position)
            for window=obj.AllWindows
                window.setPosition(position);
            end
            obj.Position=position;
        end

        function canDisplay(~,~)

        end

        function show(obj)
            if~isempty(obj.ActiveWindow)
                obj.ActiveWindow.show();
            end
        end

        function hide(obj)
            for window=obj.AllWindows
                window.hide();
            end
        end

        function bool=isVisible(obj)
            bool=false;
            if~isempty(obj.ActiveWindow)
                bool=obj.ActiveWindow.isVisible();
            end
        end

        function delete(obj)


            delete(obj.AllWindows);
        end
    end

    methods(Access=private)

        function setActiveWindow(obj,location)



            isSameWindow=false;

            if~isempty(obj.ActiveWindow)
                isSameWindow=obj.ActiveWindow.isVisible()&&obj.ActiveWindow.canDisplay(location);

                if~isSameWindow
                    obj.ActiveWindow.hide();
                end
            end



            if~isSameWindow
                matchingWindow=obj.getWindowFor(location);

                if isempty(matchingWindow)

                    windowFactory=obj.getWindowFactory(location);
                    newWindow=windowFactory.create(location);


                    newWindow.setPosition(obj.Position);
                    newWindow.show();


                    obj.ActiveWindow=newWindow;
                    obj.AllWindows(end+1)=newWindow;
                else

                    matchingWindow.show();
                    obj.ActiveWindow=matchingWindow;
                end
            end
        end

        function foundWindow=getWindowFor(obj,location)
            foundWindow=[];

            for window=obj.AllWindows
                if window.canDisplay(location)
                    foundWindow=window;
                    return
                end
            end
        end


        function foundFactory=getWindowFactory(obj,location)
            foundFactory=[];
            for factory=obj.WindowFactories
                if factory.canDisplay(location)
                    foundFactory=factory;
                    break
                end
            end

            if isempty(foundFactory)
                error(...
                "comparisons:highlight:factorynotfound","Window factory not found for "...
                +location.Type+" : "+location.Location...
                );
            end
        end
    end

end
