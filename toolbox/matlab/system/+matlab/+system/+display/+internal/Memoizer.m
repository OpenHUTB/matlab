classdef(Sealed,Hidden)Memoizer











    properties(Constant,Access=private)
        Cache=containers.Map;
    end

    methods(Static)
        function header=getHeader(systemName)
            matlab.system.display.internal.Memoizer.removeFromCacheIfClassUpdated(systemName);

            cache=matlab.system.display.internal.Memoizer.Cache;
            cacheHasKey=isKey(cache,systemName);
            if cacheHasKey&&isfield(cache(systemName),'Header')
                cachedEntry=cache(systemName);
                header=cachedEntry.Header;
            else

                header=eval([systemName,'.getDisplayHeader(''',systemName,''');']);


                if cacheHasKey
                    cachedEntry=cache(systemName);
                else
                    cachedEntry=struct('MetaClass',matlab.system.internal.MetaClass(systemName));
                end
                cachedEntry.Header=header;
                cache(systemName)=cachedEntry;%#ok<NASGU>
            end
        end

        function memoizedGroups=getPropertyGroups(systemName,varargin)


            p=inputParser;
            p.addParameter('PropertyGroupsArgument',[]);
            p.parse(varargin{:});
            inputs=p.Results;

            systemKey=systemName;
            hasPropertyGroupsArgument=~isempty(inputs.PropertyGroupsArgument);
            if hasPropertyGroupsArgument


                systemKey=[systemKey,':',matlab.system.internal.toExpression(inputs.PropertyGroupsArgument)];
            end
            matlab.system.display.internal.Memoizer.removeFromCacheIfClassUpdated(systemKey);

            cache=matlab.system.display.internal.Memoizer.Cache;
            cacheHasKey=isKey(cache,systemKey);
            if cacheHasKey&&isfield(cache(systemKey),'PropertyGroups')
                cachedEntry=cache(systemKey);
                memoizedGroups=cachedEntry.PropertyGroups;
            else

                if hasPropertyGroupsArgument
                    groups=feval([systemName,'.getDisplayPropertyGroups'],systemName,inputs.PropertyGroupsArgument);
                else
                    groups=eval([systemName,'.getDisplayPropertyGroups(''',systemName,''');']);
                end
                memoizedGroups=matlab.system.display.internal.Memoizer.memoize(groups);


                if cacheHasKey
                    cachedEntry=cache(systemKey);
                else
                    cachedEntry=struct('MetaClass',matlab.system.internal.MetaClass(systemName));
                end
                cachedEntry.PropertyGroups=memoizedGroups;
                cache(systemKey)=cachedEntry;%#ok<NASGU>
            end
        end

        function[memoizedGroups,filteredProperties]=getBlockPropertyGroups(systemName,varargin)


            p=inputParser;
            p.addParameter('DefaultIfError',false);
            p.addParameter('PropertyGroupsArgument',[]);
            p.parse(varargin{:});
            inputs=p.Results;

            systemKey=systemName;
            if~isempty(inputs.PropertyGroupsArgument)


                systemKey=[systemKey,':',matlab.system.internal.toExpression(inputs.PropertyGroupsArgument)];
            end
            matlab.system.display.internal.Memoizer.removeFromCacheIfClassUpdated(systemKey);



            cache=matlab.system.display.internal.Memoizer.Cache;
            if isKey(cache,systemKey)
                systemKeyData=cache(systemKey);
                if isfield(systemKeyData,'SimulinkLoaded')&&...
                    ~systemKeyData.SimulinkLoaded&&is_simulink_loaded


                    systemKeyData=rmfield(systemKeyData,...
                    {'BlockPropertyGroups','BlockFilteredProperties','SimulinkLoaded'});
                    cache(systemKey)=systemKeyData;
                end
            end

            cacheHasKey=isKey(cache,systemKey);
            if cacheHasKey&&isfield(cache(systemKey),'BlockPropertyGroups')
                cachedEntry=cache(systemKey);
                memoizedGroups=cachedEntry.BlockPropertyGroups;
                filteredProperties=cachedEntry.BlockFilteredProperties;
            else

                [groups,filteredProperties,errorOccurred]=matlab.system.ui.getBlockPropertyGroups(systemName,inputs);
                memoizedGroups=matlab.system.display.internal.Memoizer.memoize(groups);


                if errorOccurred
                    return;
                end


                if cacheHasKey
                    cachedEntry=cache(systemKey);
                else
                    cachedEntry=struct('MetaClass',matlab.system.internal.MetaClass(systemName));
                end
                cachedEntry.BlockPropertyGroups=memoizedGroups;
                cachedEntry.BlockFilteredProperties=filteredProperties;
                cachedEntry.SimulinkLoaded=is_simulink_loaded;
                cache(systemKey)=cachedEntry;%#ok<NASGU>
            end
        end

        function memoizedGroups=memoize(groups)
            memoizedGroups=matlab.system.display.internal.MemoizedPropertyGroup.empty;
            for group=groups
                memoizedGroups(end+1)=matlab.system.display.internal.MemoizedPropertyGroup(group);%#ok<AGROW>
            end
        end

        function clear(systemName)
            cache=matlab.system.display.internal.Memoizer.Cache;
            if nargin<1
                keys=cache.keys;
                for k=1:numel(keys)
                    cache.remove(keys{k});
                end
            elseif isKey(cache,systemName)
                cache.remove(systemName);
            end
        end
    end

    methods(Access=private,Static)
        function removeFromCacheIfClassUpdated(systemKey)
            cache=matlab.system.display.internal.Memoizer.Cache;
            if isKey(cache,systemKey)
                systemKeyData=cache(systemKey);
                mc=systemKeyData.MetaClass;
                if isempty(mc)||~iscurrent(mc)
                    cache.remove(systemKey);
                end
            end
        end
    end
end
