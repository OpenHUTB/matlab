classdef CachedObjectFactory




    properties(SetAccess=immutable,GetAccess=private)
        pPrototypeCache;
        pKeyGenerator;
        pCtor;
        pCopyFun;
    end

    methods
        function obj=CachedObjectFactory(keyGenerator,ctor,copyFun)

            obj.pKeyGenerator=keyGenerator;
            obj.pCtor=ctor;
            obj.pCopyFun=copyFun;
            obj.pPrototypeCache=containers.Map();
        end

        function newObj=getObject(obj,varargin)

            key=obj.pKeyGenerator(varargin{:});
            if isKey(obj.pPrototypeCache,key)
                newObj=obj.retrieveObjFromCache(key);
            else
                newObj=obj.pCtor(varargin{:});
                obj.updateCache(key,newObj);
            end
        end
    end

    methods(Access=private)
        function newObj=retrieveObjFromCache(obj,key)

            prototype=obj.pPrototypeCache(key);
            newObj=obj.pCopyFun(prototype);
        end

        function updateCache(obj,key,prototype)

            obj.pPrototypeCache(key)=obj.pCopyFun(prototype);
        end
    end
end