classdef(Abstract)ExceptionHandler<handle&matlab.mixin.Heterogeneous




    methods(Abstract,Access=public)




        bool=canHandle(this,exception);





        result=handleException(this,exception);

    end

end