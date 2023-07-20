classdef StaticIndexingOperator<optim.internal.problemdef.Operator




    properties


Index

OptimIndex

ColonIndex
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        StaticIndexingOperatorVersion=1;
    end

    methods


        function op=StaticIndexingOperator(index,inSize)
            [op.Index,op.OptimIndex,op.ColonIndex]=op.checkAndWrapNumeric(index,inSize);
        end



        function linIdx=getLinIndex(op,inSize,extractCoeffVisitor)

            sub=getSubStruct(op,inSize,extractCoeffVisitor);

            indexNames={{},{}};
            [~,linIdx]=optim.internal.problemdef.indexing.getSubsrefOutputs(sub,inSize,indexNames);
        end


        function idxVal=getIndices(op,sz,evalVisitor)
            idxVal=op.Index;
            optimIdx=op.OptimIndex;


            if any(optimIdx)



                head=evalVisitor.Head;
                oldParentHead=evalVisitor.ParentHead;
                evalVisitor.ParentHead=head+1;
                numIndex=numel(idxVal);
                if numIndex==1


                    endIndexVal=prod(sz);
                else


                    endIndexVal=sz;
                end
                for i=1:numIndex
                    if optimIdx(i)
                        idxVal{i}=getIndexValue(idxVal{i},endIndexVal,i,evalVisitor);
                    end
                end

                evalVisitor.ParentHead=oldParentHead;
            end

            function val=getIndexValue(index,endIndexVal,i,visitor)



                pushValue(visitor,endIndexVal(i));
                acceptVisitor(index,visitor);
                val=getValue(visitor);
                visitor.Head=visitor.Head-1;
            end

        end


        function sub=getSubStruct(op,sz,evalVisitor)

            indexVal=getIndices(op,sz,evalVisitor);
            sub=substruct('()',indexVal);
        end

    end

    methods(Access=protected)

        function ok=checkIsValid(~,~,~)


            ok=true;
        end

        function[index,optimIndex,colonIndex]=checkAndWrapNumeric(~,index,inSize)


            Nindex=numel(index);
            optimIndex=false(1,Nindex);
            colonIndex=false(1,Nindex);
            for i=1:Nindex
                thisIndex=index{i};
                isExpression=isa(thisIndex,'optim.problemdef.OptimizationExpression');
                if isExpression


                    if~(getExprType(thisIndex)==optim.internal.problemdef.ImplType.Numeric)
                        throwAsCaller(MException(message('shared_adlib:operators:BadSubscript')));
                    end

                    index{i}=getExprImpl(thisIndex);
                    optimIndex(i)=true;
                else


                    indexNames=repmat({{}},1,numel(inSize));
                    index{i}=optim.internal.problemdef.indexing.checkValidSubsrefIndex(thisIndex,i,Nindex,inSize,indexNames);
                    colonIndex(i)=strcmp(index{i},':');
                end
            end
        end

    end
end
