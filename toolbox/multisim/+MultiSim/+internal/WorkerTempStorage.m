







classdef(Sealed)WorkerTempStorage<handle
    properties
Storage
    end

    methods(Access=private)
        function obj=WorkerTempStorage





            obj.Storage=struct('slssConnectionIdsMap',containers.Map('KeyType','uint32','ValueType','uint32'),...
            'parsimProject',[]);
        end
    end

    methods
        function store(obj,name,value)
            validateattributes(name,{'char'},{'vector'});
            obj.Storage.(name)=value;
        end

        function value=get(obj,name)
            validateattributes(name,{'char'},{'vector'});
            value=obj.Storage.(name);
        end
    end

    methods(Static)
        function singleObj=getInstance
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=MultiSim.internal.WorkerTempStorage;
            end
            singleObj=localObj;
        end

        function reset
            instance=MultiSim.internal.WorkerTempStorage.getInstance;
            delete(instance);
        end
    end
end