classdef(Hidden,Sealed)Cache<handle





    properties
FileGenConfig
StartDir
    end

    methods(Access=private)
        function this=Cache

        end
    end

    methods(Static)
        function cache=getInstance
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=coder.parallel.worker.Cache;
            end
            cache=instance;
        end
    end
end

