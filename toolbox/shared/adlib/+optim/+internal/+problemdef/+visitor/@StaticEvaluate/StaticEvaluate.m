classdef StaticEvaluate<optim.internal.problemdef.visitor.Evaluate






    methods


        function visitor=StaticEvaluate()
            visitor@optim.internal.problemdef.visitor.Evaluate(struct,struct);
        end

    end


    methods

        function visitLHSExpressionImpl(visitor,LHS)

            val=LHS.Value;


            push(visitor,val);
        end

        function visitVariableExpressionImpl(visitor,Node)



            val=zeros(Node.Size);
            push(visitor,val);
        end


        visitOperatorStaticAssign(visitor,Op,Node);

        visitOperatorStaticSubsasgn(visitor,Op,Node);

    end

end
