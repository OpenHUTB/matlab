classdef(Abstract)DLCodegenErrorHandler<handle




    methods(Abstract)
        handleLayerError(obj);

        handleNetworkError(obj);
    end

end
