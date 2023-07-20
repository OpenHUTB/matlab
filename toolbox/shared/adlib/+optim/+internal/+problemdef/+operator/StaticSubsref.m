classdef StaticSubsref<optim.internal.problemdef.operator.StaticIndexingOperator




    properties



LhsSize
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        StaticSubsrefVersion=1;
    end

    properties(Hidden,Constant)
        OperatorStr="subsref";
    end

    methods


        function op=StaticSubsref(expr,index)
            inSize=size(expr);
            op=op@optim.internal.problemdef.operator.StaticIndexingOperator(...
            index,inSize);
            op.LhsSize=inSize;
        end


        function outSize=getOutputSize(op,sz,~,evalVisitor)
            if nargin<4


                evalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
            end
            sub=getSubStruct(op,sz,evalVisitor);
            idxNames=repmat({{}},1,numel(sz));
            outSize=optim.internal.problemdef.indexing.getSubsrefOutputs(...
            sub,sz,idxNames);
        end


        function outVal=evaluate(op,LeftVal,~,evalVisitor)
            sub=getSubStruct(op,size(LeftVal),evalVisitor);
            outVal=subsref(LeftVal,sub);
        end


        function acceptVisitor(op,visitor,Node)
            visitOperatorStaticSubsref(visitor,op,Node);
        end

    end

end

