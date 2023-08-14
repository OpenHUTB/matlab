classdef(Sealed)VariableExpressionImpl<optim.internal.problemdef.ExpressionImpl





    properties(Hidden)



        Name char='undefined'
        VariableType char='continuous'
        LowerBound double=-Inf
        UpperBound double=Inf



        Offset=1;

        SupportsAD=true;
    end

    properties(Hidden,Access=private)





        NumVar=0;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        VariableExpressionImplVersion=1;
    end

    methods




        function obj=VariableExpressionImpl(name,size)


            obj=obj@optim.internal.problemdef.ExpressionImpl();


            obj.NumVar=prod(size);
            obj.Name=name;
            obj.Size=size;

        end


        function[jach,jacNumParens]=getJacobianMemory(var)
            jach=var.JacStr;
            jacNumParens=var.JacNumParens;
        end























        function deallocateJacobianMemory(~)



        end




        function idxNames=getIndexNames(~)



            idxNames={};
        end


        function s=getSize(obj)
            s=obj.Size;
        end

    end

    methods(Hidden)
        function acceptVisitor(Node,visitor)
            visitVariableExpressionImpl(visitor,Node);
        end
    end



    methods

        function val=get.LowerBound(obj)

            if isscalar(obj.LowerBound)
                val=repmat(obj.LowerBound,obj.Size);
            else
                val=obj.LowerBound;
            end

        end

        function val=get.UpperBound(obj)

            if isscalar(obj.UpperBound)
                val=repmat(obj.UpperBound,obj.Size);
            else
                val=obj.UpperBound;
            end

        end

    end




















end
