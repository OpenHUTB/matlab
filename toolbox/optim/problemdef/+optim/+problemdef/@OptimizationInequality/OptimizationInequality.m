classdef(Sealed)OptimizationInequality<optim.problemdef.OptimizationConstraint
























    properties(Hidden,SetAccess=private,GetAccess=public)
        OptimizationInequalityVersion=1;
    end

    methods(Hidden)


        function ineq=OptimizationInequality(varargin)

































            ineq=ineq@optim.problemdef.OptimizationConstraint(varargin{:});

        end

    end



    methods(Hidden)
        c=upcast(ineq)
        ineq=downcast(ineq)
    end



    methods(Hidden,Access=protected)
        newcon=createConstraint(~,varargin)
        con=setRelation(con,relation)
        checkConcat(~,relation,con2cat)
    end


    methods(Hidden,Static)


        function cName=className()
            cName="OptimizationInequality";
        end
        ineq=empty(varargin)
    end
end
