classdef AlertCache<handle





    properties
        Map;
    end

    methods(Static)
        function cache=getInstance()
            mlock;
            persistent alertCache;
            if isempty(alertCache)
                alertCache=UpgradeAdvisor.AlertCache();
            end
            cache=alertCache;
        end
    end

    methods(Access=private)
        function cache=AlertCache()
            cache.Map=containers.Map;
        end
    end

    methods(Access=public)

        function shown=getAndSet(cache,model,id)
            filename=get_param(model,'FileName');
            if cache.Map.isKey(filename)
                ids=cache.Map(filename);
                shown=ismember(id,ids);
                if~shown
                    ids{end+1}=id;
                    cache.Map(filename)=ids;
                end
            else
                cache.Map(filename)={id};
                shown=false;
            end
        end

        function clear(cache)
            cache.Map.remove(cache.Map.keys);
        end

    end

end
