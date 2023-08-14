





classdef ThreadPoolManager<handle
    properties(Dependent)
ThreadPool
    end

    properties(Access=private,Transient=true)
        ThreadPoolPrivate parallel.ThreadPool
    end

    methods
        function p=get.ThreadPool(obj)
            p=obj.ThreadPoolPrivate;
            if isempty(p)
                p=gcp('nocreate');
                if isempty(p)
                    obj.ThreadPoolPrivate=parpool('threads');
                    p=obj.ThreadPoolPrivate;
                elseif(~isa(p,'parallel.ThreadPool'))
                    p=parallel.ThreadPool.empty;
                end
            end
        end

        function delete(obj)
            delete(obj.ThreadPoolPrivate)
        end

    end
end