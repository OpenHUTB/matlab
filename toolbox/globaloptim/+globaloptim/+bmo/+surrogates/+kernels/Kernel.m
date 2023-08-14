

classdef(Abstract)Kernel<handle


    properties
name
    end

    methods(Abstract)
        dim=getOrder(obj);
        vals=eval(obj,D);
        dvals=deval(obj,D);
        d2vals=d2eval(obj,D);
    end
end