

classdef(Abstract)Tail<handle


    properties
name
        tail_constant=1
    end

    methods(Abstract)
        dim=getDim(obj);
        deg=getDegree(obj);
        nbasis=getDimBasis(obj);
        vals=eval(obj,Y);
        Jac=deval(obj,y);
        d2vals=d2eval(obj,D);
    end
end