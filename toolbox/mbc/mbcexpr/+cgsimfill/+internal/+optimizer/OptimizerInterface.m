classdef OptimizerInterface<handle&matlab.mixin.Copyable




    properties

Bounds

LinearConstraints

        Name='';

        Description='';

        Cost=Inf;
    end

    properties(Abstract,Dependent,SetAccess=private)

NormGradient
    end

    properties(Dependent,SetAccess=private)
HasConstraints
    end

    methods
        function setupConstraints(obj,items)



            [~,~,Bnds,Aineq,Cineq]=getOptimValues(items);

            obj.Bounds=Bnds;
            if~isempty(Aineq)
                [lb,ub,Aineq,Cineq]=cgsimfill.internal.optimizer.presolve(Bnds(:,1),Bnds(:,2),Aineq,Cineq);
                obj.Bounds=[lb,ub];
            end
            if~isempty(Aineq)||any(isfinite(Bnds),'all')
                obj.LinearConstraints={Aineq,Cineq};
            else
                obj.LinearConstraints=[];
            end
        end

        function ok=get.HasConstraints(obj)

            ok=(~isempty(obj.Bounds)&&any(isfinite(obj.Bounds),'all'))||...
            ~isempty(obj.LinearConstraints);
        end

        function clearMemory(obj)%#ok<MANU>


        end

        function ok=hasMemory(obj)%#ok<MANU> 


            ok=0;
        end

    end

    methods(Abstract)
        reset(obj)
        leastSquaresGradients(optimizer,varargin)
        accumulate(obj,varargin)
        [b,converged]=solve(obj,b,smoothingMatrix,previousOptimizer,previousValues)
        initialize(obj,LS)

    end


end
