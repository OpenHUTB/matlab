classdef Cache<handle




    methods(Access=public)
        function obj=Cache(cacheName,defaultCacheValue,updateFunction)
            obj.Name=cacheName;
            obj.DefaultCacheValue=defaultCacheValue;
            obj.UpdateFunction=updateFunction;
        end
    end

    properties
        DefaultCacheValue=[]
        UpdateFunction=[]
        Name(1,1)string
    end

end
