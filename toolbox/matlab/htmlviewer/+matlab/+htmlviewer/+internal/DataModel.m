classdef DataModel<handle

    properties(GetAccess=public,SetAccess=private,Hidden)
IsHTMLTextReceived
IsTitleReceived
IsCloseCompleted
    end

    properties(Access=private,Hidden,Transient,NonCopyable)
LastActiveViewerID
ViewerIDHandleMap
OpenRequestQueue
HTMLPageStaticPathMap
RouteNamesList
CurrentHTMLText
CurrentTitle
    end

    methods(Hidden)
        function obj=DataModel()
            obj.resetDataCache();
        end

        function storeViewerHandle(obj,viewerHandle,viewerID)
            obj.ViewerIDHandleMap(viewerID)=viewerHandle;
        end

        function viewerHandle=getViewerHandle(obj,viewerID)
            viewerHandle=[];
            if isKey(obj.ViewerIDHandleMap,viewerID)
                viewerHandle=obj.ViewerIDHandleMap(viewerID);
            end
        end

        function removeViewerHandle(obj,viewerID)
            if isKey(obj.ViewerIDHandleMap,viewerID)
                obj.ViewerIDHandleMap.remove(viewerID);
            end
        end

        function viewerHandle=getLastActiveViewerHandle(obj)
            viewerHandle=[];
            activeViewerID=obj.LastActiveViewerID;
            if~isempty(activeViewerID)
                viewerHandle=obj.getViewerHandle(activeViewerID);
            end
        end

        function setLastActiveViewerID(obj,viewerID)
            obj.LastActiveViewerID=viewerID;
        end

        function addToOpenRequestQueue(obj,request)
            obj.OpenRequestQueue{end+1}=request;
        end

        function request=getOpenRequestQueue(obj)
            request=obj.OpenRequestQueue;
            obj.resetOpenRequestQueue();
        end

        function storeHTMLPageStaticPath(obj,fileLocation,staticPath)
            obj.HTMLPageStaticPathMap(fileLocation)=staticPath;
        end

        function staticPath=getHTMLPageStaticPath(obj,fileLocation)
            staticPath=strings(0);
            if isKey(obj.HTMLPageStaticPathMap,fileLocation)
                staticPath=obj.HTMLPageStaticPathMap(fileLocation);
            end
        end

        function storeRouteName(obj,routeName)
            obj.RouteNamesList(end+1)={routeName};
        end

        function setActiveHTMLText(obj,htmlText)
            obj.CurrentHTMLText=htmlText;
            obj.IsHTMLTextReceived=true;
        end

        function activeHTMLText=getActiveHTMLText(obj)
            activeHTMLText=obj.CurrentHTMLText;
        end

        function resetHTMLTextCache(obj)
            obj.IsHTMLTextReceived=false;
            obj.CurrentHTMLText="";
        end

        function setActiveTitle(obj,title)
            obj.CurrentTitle=title;
            obj.IsTitleReceived=true;
        end

        function activeTitle=getActiveTitle(obj)
            activeTitle=obj.CurrentTitle;
        end

        function resetTitleCache(obj)
            obj.IsTitleReceived=false;
            obj.CurrentTitle="";
        end

        function setCloseCompletion(obj,status)
            obj.IsCloseCompleted=status;
        end

        function resetDataCache(obj)
            obj.resetViewerIDHandleMap();
            obj.resetHTMLPageStaticPathMap();
            obj.resetRouteNamesList();
            obj.resetOpenRequestQueue();
            obj.LastActiveViewerID=[];
            obj.resetHTMLTextCache();
            obj.resetTitleCache();
            obj.IsCloseCompleted=false;
        end

        function cleanupOnHTMLViewerClose(obj)
            for route=obj.RouteNamesList



                connector.removeStaticContentOnPath(route{:});
            end
            obj.resetDataCache();
        end
    end

    methods(Access=private)
        function resetOpenRequestQueue(obj)
            obj.OpenRequestQueue={};
        end

        function resetViewerIDHandleMap(obj)
            obj.ViewerIDHandleMap=containers.Map();
        end

        function resetHTMLPageStaticPathMap(obj)
            obj.HTMLPageStaticPathMap=containers.Map();
        end

        function resetRouteNamesList(obj)
            obj.RouteNamesList={};
        end
    end

end