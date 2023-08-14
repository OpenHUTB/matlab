classdef Mtimes<optim.internal.problemdef.MatrixOperator




    properties(Hidden,Constant)
        OperatorStr="*";
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        MtimesVersion=2;
    end

    methods

        function op=Mtimes(Left,Right)

            op=op@optim.internal.problemdef.MatrixOperator(Left,Right);
        end


        function outSize=getOutputSize(op,~,~,~)

            outSize=[op.LeftSize(1),op.RightSize(2)];
        end

        function acceptVisitor(op,visitor,Node)
            visitOperatorMtimes(visitor,op,Node);
        end


        function val=evaluate(~,Left,Right,~)
            val=Left*Right;
        end


        function outType=getOutputType(~,LeftType,RightType,~)
            outType=optim.internal.problemdef.ImplType.typeTimes(LeftType,RightType);
        end
    end

    methods(Access=protected)

        function ok=checkIsValid(op,~,~)


            if((numel(op.LeftSize)>2)||(numel(op.RightSize)>2))
                throwAsCaller(MException(message('shared_adlib:operators:InputsMustBe2D')));
            end

            if any(op.LeftSize(2)~=op.RightSize(1))
                throwAsCaller(MException('shared_adlib:operators:InnerDim',getString(message('MATLAB:innerdim'))));
            end
            ok=true;
        end
    end


    methods(Static)
        function objout=loadobj(objin)
            if objin.MtimesVersion==1
                objout=reloadv1tov2(objin);
            else
                objout=objin;
            end
        end
    end

    methods(Hidden)
        function obj=reloadv1tov2(obj)


            if all(obj.LeftSize==1)||all(obj.RightSize==1)


                obj=optim.internal.problemdef.Times.getTimesOperatorNoCheck;
            else
                obj.MtimesVersion=2;
            end
        end
    end

end

