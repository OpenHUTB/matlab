classdef StaticSubsasgn<optim.internal.problemdef.operator.StaticIndexingOperator




    properties



LhsSize

NumIndex
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        StaticSubsasgnVersion=1;
    end

    properties(Hidden,Constant)
        OperatorStr="subsasgn";
    end

    methods


        function op=StaticSubsasgn(lhs,index,PtiesVisitor)
            lhsSize=size(lhs);
            op=op@optim.internal.problemdef.operator.StaticIndexingOperator(...
            index,lhsSize);
            op.LhsSize=lhsSize;
            linIdx=getLinIndex(op,lhsSize,PtiesVisitor);
            op.NumIndex=numel(linIdx);
        end


        function[outSize,outSubSize]=getOutputSize(op,lsz,rsz,evalVisitor)
            if nargin<4


                evalVisitor=optim.internal.problemdef.visitor.StaticEvaluate;
            end
            sub=getSubStruct(op,lsz,evalVisitor);
            lidxNames=repmat({{}},1,numel(lsz));
            [outSize,~,~,outSubSize]=...
            optim.internal.problemdef.indexing.getSubsasgnOutputs(...
            sub,lsz,lidxNames);

            isLinearIndexing=numel(op.Index)==1;
            optim.internal.problemdef.indexing.checkValidRHSForSubsasgn(...
            outSubSize,rsz,isLinearIndexing);
        end


        function outType=getOutputType(~,LeftType,RightType,~)
            outType=optim.internal.problemdef.ImplType.typeSubsasgn([LeftType,RightType]);
        end


        function oldIdx=getOldLinIndex(op,evalVisitor)
            sub=getSubStruct(op,evalVisitor);
            outSize=optim.internal.problemdef.indexing.getSubsasgnOutputs(...
            sub,op.LhsSize,{{},{}});
            oldIdx=cell(1,numel(op.LhsSize));
            [oldIdx{:}]=ind2sub(op.LhsSize,1:prod(op.LhsSize));
            oldIdx=sub2ind(outSize,oldIdx{:});
        end


        function outVal=evaluate(op,LeftVal,RightVal,evalVisitor)
            sub=getSubStruct(op,size(LeftVal),evalVisitor);
            outVal=subsasgn(LeftVal,sub,RightVal);
        end


        function acceptVisitor(op,visitor,Node)
            visitOperatorStaticSubsasgn(visitor,op,Node);
        end

    end

    methods(Access=protected)

        function ok=checkIsValid(~,~,~)
            ok=true;
        end



        function ok=checkNumRHS(~,index,lhsSize,indexNames,rhs)

            sub=substruct('()',index);
            [~,~,~,subOutSize]=...
            optim.internal.problemdef.indexing.getSubsasgnOutputs(sub,lhsSize,indexNames);


            linearIndexing=numel(index)==1;


            try
                optim.internal.problemdef.indexing.checkValidRHSForSubsasgn(subOutSize,size(rhs),linearIndexing);
            catch ME
                throwAsCaller(ME);
            end

            ok=true;
        end
    end
end

