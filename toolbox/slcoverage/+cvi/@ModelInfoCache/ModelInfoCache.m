



classdef ModelInfoCache<handle

    properties
    end
    methods
    end
    methods(Static)

        function info=topModelInfoCache(topModel,excludeTopModel,modelRefEnable,modelRefExcludeList)
            persistent TopModel;
            persistent ExcludeTopModel;
            persistent ModelRefEnable;
            persistent ModelRefExcludeList;
            if(nargin>0)
                TopModel=topModel;
                ExcludeTopModel=excludeTopModel;
                ModelRefEnable=modelRefEnable;
                ModelRefExcludeList=modelRefExcludeList;
            end

            if(nargout==1)
                info.topModel=TopModel;
                info.excludeTopModel=ExcludeTopModel;
                info.modelRefEnable=ModelRefEnable;
                info.modelRefExcludeList=ModelRefExcludeList;
            end
        end

        function[covEnabledMdlrefs,covDisabledMdlrefs]=modelRefCache(covEnabledMdlrefs,covDisabledMdlrefs)
            persistent CachedCovEnabledMdlrefs;
            persistent CachedCovDisabledMdlrefs;

            if(nargin==2)
                CachedCovEnabledMdlrefs=covEnabledMdlrefs;
                CachedCovDisabledMdlrefs=covDisabledMdlrefs;
            else
                if isempty(CachedCovEnabledMdlrefs)
                    CachedCovEnabledMdlrefs={};
                end
                if isempty(CachedCovDisabledMdlrefs)
                    CachedCovDisabledMdlrefs={};
                end
            end

            covEnabledMdlrefs=CachedCovEnabledMdlrefs;
            covDisabledMdlrefs=CachedCovDisabledMdlrefs;
        end

        function info=getTopModelInfo()
            info=cvi.ModelInfoCache.topModelInfoCache();
        end

        function cacheTopModelInfo(topModel,excludeTopModel,modelRefEnable,modelRefExcludeList)
            cvi.ModelInfoCache.topModelInfoCache(topModel,...
            excludeTopModel,...
            modelRefEnable,...
            modelRefExcludeList);
        end

        function reset()
            cvi.ModelInfoCache.cacheTopModelInfo([],[],[],[])
            cvi.ModelInfoCache.resetModelRefCache();
        end

        function resetModelRefCache()
            cvi.ModelInfoCache.modelRefCache({},{});
        end

        function cacheModelRef(refModelName,isEnabled)
            [covEnabledMdlrefs,covDisabledMdlrefs]=cvi.ModelInfoCache.modelRefCache();
            if isEnabled
                covEnabledMdlrefs{end+1}=refModelName;
            else
                covDisabledMdlrefs{end+1}=refModelName;
            end
            cvi.ModelInfoCache.modelRefCache(covEnabledMdlrefs,covDisabledMdlrefs);
        end

        function isEnabled=checkMdlRefEnabled(modelName)
            [covEnabledMdlrefs,covDisabledMdlrefs]=cvi.ModelInfoCache.modelRefCache();
            if~isempty(covEnabledMdlrefs)&&any(strcmp(covEnabledMdlrefs,modelName))
                isEnabled=1;
            elseif~isempty(covDisabledMdlrefs)&&any(strcmp(covDisabledMdlrefs,modelName))
                isEnabled=0;
            else


                isEnabled=-1;
            end
        end

        function allMdlRefs=getAllCachedMdlRefs()
            [covEnabledMdlrefs,covDisabledMdlrefs]=cvi.ModelInfoCache.modelRefCache();
            allMdlRefs=[covEnabledMdlrefs,covDisabledMdlrefs];
        end

    end
end
