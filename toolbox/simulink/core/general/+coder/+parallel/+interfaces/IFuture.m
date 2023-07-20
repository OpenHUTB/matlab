classdef(Abstract)IFuture<handle&matlab.mixin.Heterogeneous




    methods(Abstract)
        fetchNext(objOrObjs);
        cancel(objOrObjs);
    end
end
