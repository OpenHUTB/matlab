classdef InstanceCache<handle








    methods(Static)
        function instance=getInstance
            instance=dfs.analysis.InstanceCache.manageInstance(false);
        end

        function clearCache
            dfs.analysis.InstanceCache.manageInstance(true);
        end
    end

    methods(Static,Access=private)
        function instance=manageInstance(destroy)
            persistent cache
            if destroy
                munlock;
                cache=dfs.analysis.InstanceCache.empty;
            else
                if isempty(cache)
                    cache=dfs.analysis.InstanceCache;
                    mlock;
                end
            end
            instance=cache;
        end
    end

    properties(Access=private)
        GlobalCache containers.Map
    end

    methods
        function remove(obj,subsystemHandle)
            if isKey(obj.GlobalCache,subsystemHandle)
                app=obj.GlobalCache(subsystemHandle);
                remove(obj.GlobalCache,subsystemHandle);
                clear(app);
                delete(app);
            end

            if isempty(obj.GlobalCache)
                dfs.analysis.InstanceCache.clearCache();
            end
        end

        function open(obj,subsystemHandle)
            appData=getOrCreateInstance(obj,subsystemHandle);
            open(appData);
        end

        function update(obj,subsystemHandle)
            appData=getOrCreateInstance(obj,subsystemHandle);
            update(appData);
        end

        function refreshData(obj,subsystemHandle)
            appData=getOrCreateInstance(obj,subsystemHandle);
            refreshData(appData)
        end

        function replace(obj,oldHandle,newHandle)
            assert(isKey(obj.GlobalCache,oldHandle));



            if isKey(obj.GlobalCache,newHandle)
                oldData=obj.GlobalCache(newHandle);
                remove(obj.GlobalCache,newHandle);
                delete(oldData);
            end

            appData=obj.GlobalCache(oldHandle);
            remove(obj.GlobalCache,oldHandle);

            obj.GlobalCache(newHandle)=appData;
        end

        function num=numEntries(obj)
            num=length(obj.GlobalCache);
        end
    end

    methods(Access=private)
        function obj=InstanceCache
            obj.GlobalCache=containers.Map('KeyType','double','ValueType','any');
        end

        function appData=getOrCreateInstance(obj,subsystemHandle)
            if~isKey(obj.GlobalCache,subsystemHandle)
                appData=dfs.analysis.MultithreadingAnalysis(subsystemHandle);
                obj.GlobalCache(subsystemHandle)=appData;
            else
                appData=obj.GlobalCache(subsystemHandle);
                if~isvalid(appData)||~isvalid(appData.AppHandle)
                    appData=dfs.analysis.MultithreadingAnalysis(subsystemHandle);
                    obj.GlobalCache(subsystemHandle)=appData;
                end
            end
        end
    end
end


