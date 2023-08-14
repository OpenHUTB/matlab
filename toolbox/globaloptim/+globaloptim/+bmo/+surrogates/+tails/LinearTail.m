

classdef LinearTail<globaloptim.bmo.surrogates.tails.Tail
    properties(Access=private)
        dim;
    end

    methods
        function obj=LinearTail(problem,~)

            obj.dim=problem.nvar;
            obj.name='lineartail';
        end

        function dim=getDim(obj)
            dim=obj.dim;
        end

        function deg=getDegree(~)
            deg=1;
        end

        function nbasis=getDimBasis(obj)
            nbasis=obj.dim+1;
        end



        function out=eval(obj,Y)
            out=[obj.tail_constant*ones(size(Y,1),1),Y];
        end


        function Jac=deval(obj,y)
            assert(isvector(y));
            Jac=[zeros(1,obj.dim);eye(obj.dim)];
        end
        function d2val=d2eval(obj,~)

            d2val=zeros(obj.dim,obj.dim);
        end
    end
end