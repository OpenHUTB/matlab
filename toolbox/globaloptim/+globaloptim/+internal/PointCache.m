classdef PointCache<handle









    properties(Access=private)
cachePtr
    end

    methods
        function cacheObj=PointCache(cacheSize)
            cacheObj.cachePtr=globaloptim.internal.mexfiles.mx_handleCache('setup',cacheSize);
        end
        function foundInCache=lookup(cacheObj,X,cachetol)
            if(~isempty(cacheObj.cachePtr))
                foundInCache=globaloptim.internal.mexfiles.mx_handleCache('lookup',X,cacheObj.cachePtr,cachetol);
            end
        end
        function store(cacheObj,pointsToStore)
            if(~isempty(cacheObj.cachePtr))
                globaloptim.internal.mexfiles.mx_handleCache('store',pointsToStore,cacheObj.cachePtr);
            end
        end
        function clear(cacheObj)
            if(~isempty(cacheObj.cachePtr))
                globaloptim.internal.mexfiles.mx_handleCache('clear',cacheObj.cachePtr);
                cacheObj.cachePtr=[];
            end
        end
        function cache=getCache(cacheObj)
            if(~isempty(cacheObj.cachePtr))
                cache=globaloptim.internal.mexfiles.mx_handleCache('getCache',cacheObj.cachePtr);
            end
        end
        function delete(cacheObj)
            if(~isempty(cacheObj.cachePtr))
                globaloptim.internal.mexfiles.mx_handleCache('clear',cacheObj.cachePtr);
            end
        end
    end

end

