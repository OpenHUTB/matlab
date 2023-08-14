



classdef SearchInstanceManager<handle

    methods(Static,Access=public)
        function instanceManager=createSearchInstanceManager(uri)
            import simulink.search.internal.SearchInstanceManager;
            instanceManagerMap=SearchInstanceManager.getSearchInstanceManagerMap();
            if~instanceManagerMap.isKey(uri)
                instanceManager=SearchInstanceManager();
                instanceManagerMap(uri)=instanceManager;
                return;
            end
            instanceManager=instanceManagerMap(uri);
        end

        function instanceManager=getSearchInstanceManager(uri)
            instanceManager=[];
            import simulink.search.internal.SearchInstanceManager;
            instanceManagerMap=SearchInstanceManager.getSearchInstanceManagerMap();
            if~instanceManagerMap.isKey(uri)
                return;
            end
            instanceManager=instanceManagerMap(uri);
        end

        function removeSearchInstanceManager(uri)
            import simulink.search.internal.SearchInstanceManager;
            instanceManagerMap=SearchInstanceManager.getSearchInstanceManagerMap();
            if~instanceManagerMap.isKey(uri)
                return;
            end
            remove(instanceManagerMap,uri);
        end

        function isNotEmpty=hasSearchInstanceManager()
            import simulink.search.internal.SearchInstanceManager;
            instanceManagerMap=SearchInstanceManager.getSearchInstanceManagerMap();
            isNotEmpty=~isempty(instanceManagerMap);
        end
    end

    methods(Access=public)




        function createPreAction(this)
            this.m_searchModel.searchSystems.viewMode='lightView';
        end

        function findPreAction(this)

            this.clearResults();
            this.updateFinderTitle();
            this.m_searchModel.setIsSearchActive(true);
        end

        function findPostAction(this)
            this.m_searchModel.generateSearchRegx();
            this.m_replaceManager.cacheSearchSetting(...
            this.m_searchModel.getSearchRegx(),...
            this.m_searchModel.getIsCaseSensitive()...
            );
        end

        function findAsyncProgressPostAction(this)
            this.m_replaceManager.cacheSearchData(this.m_searchModel);
        end

        function changeViewModePostAction(this)
            viewMode=this.m_searchModel.searchSystems.viewMode;
            this.m_replaceManager.viewModeChanged(viewMode);
        end

        function resetFindPreAction(this)
            this.m_searchModel.setIsSearchActive(false);
        end




        function updateReplaceRegx(this,replaceRegx)
            this.m_searchModel.updateReplaceRegx(replaceRegx);
            this.m_replaceManager.cacheReplaceSetting(replaceRegx);
        end

        function clearResults(this)
            this.m_searchModel.clearSearch();
            this.m_replaceManager.clearSearch();
        end

        function updateFinderTitle(this)
            import simulink.search.SearchActions;

            [finderTitle,activeStudio]=SearchActions.getFinderComponentInfoBySearchModel(...
            this.getSearchModel()...
            );
            SearchActions.updateFinderTitle(activeStudio,finderTitle);
        end

        function openSearch(this)
        end

        function closeSearch(this)

            this.removeSearchModel();
            this.m_replaceManager.clearSearch();
        end

        function replaceManager=getReplaceManager(this)
            replaceManager=this.m_replaceManager;
        end

        function searchModel=createSearchModel(this)
            import simulink.search.internal.model.SearchModel;
            this.m_searchModel=SearchModel();
            searchModel=this.m_searchModel;
        end

        function searchModel=getSearchModel(this)
            searchModel=this.m_searchModel;
        end

        function removeSearchModel(this)
            this.m_searchModel.reset();
        end

        function replaceProperties(this,propsToReplace,timeStamp,replacedInfo,errorManager)
            this.m_replaceManager.replaceProperties(...
            strcmp(this.m_searchModel.searchSystems.viewMode,'lightView'),...
            propsToReplace,...
            timeStamp,...
            replacedInfo,...
errorManager...
            );
        end

        function stopReplace(this)
            this.m_replaceManager.stopReplace();
        end
    end
    methods(Static,Access=protected)
        function instanceManagerMap=getSearchInstanceManagerMap()
            persistent s_searchInstanceMap;
            if isempty(s_searchInstanceMap)
                s_searchInstanceMap=containers.Map();
            end
            instanceManagerMap=s_searchInstanceMap;
        end
    end
    properties(Access=protected)
        m_replaceManager=[];
        m_searchModel=[];
    end

    methods(Static,Access=protected)
        function token=subscribeStudioService(studio,serviceName,oldToken,cbFunc)
            if isempty(oldToken)
                c=studio.getService(serviceName);
                token=c.registerServiceCallback(cbFunc);
                return;
            end
            token=oldToken;
        end

        function token=unSubscribeStudioService(studio,serviceName,oldToken)
            token=[];
            if~isempty(oldToken)
                c=studio.getService(serviceName);
                c.unRegisterServiceCallback(oldToken);
            end
        end
    end

    methods(Access=protected)
        function obj=SearchInstanceManager()
            import simulink.search.internal.ReplaceManager;
            obj.m_replaceManager=ReplaceManager();
            obj.m_searchModel=[];
        end
    end
end
