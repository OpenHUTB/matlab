classdef ExpressionImpl<handle




    properties(Hidden=true)

        Size=[1,1];



        ChildrenPosition=[];

        StackLength=1;


        Value=[];
    end

    properties(Abstract,Hidden)
SupportsAD
    end

    properties(Transient,Hidden)

VisitorIndex
    end





    properties(Hidden,SetAccess=protected,GetAccess=public)

Id
    end

    properties(Access=private,Constant)

        IdFactory=optim.internal.problemdef.UniqueIdFactory;
    end


    properties(Hidden,SetAccess=private,GetAccess=public)
        ExpressionImplVersion=4;
    end



    properties(Hidden=true,Transient=true)

        H=[];

        A=[];

        b=[];





        NeedToComputeCoeffs=true;

        FunStr="";

        NumParens=0;

        JacStr="";

        JacNumParens=0;

        Tape=string.empty;


        JacRADStr="";

        JacRADNumParens=0;

        HessStr="";

        HessNumParens=0;
    end

    methods


        function obj=ExpressionImpl()
            obj.Id=char(nextId(obj.IdFactory));
        end


        function setId(obj,id)
            obj.Id=id;
        end




        function sz=size(obj)
            sz=obj.Size;
        end


        function len=length(expr)
            len=max(size(expr));
        end


        function val=isscalar(obj)
            val=all(obj.Size==1);
        end


        function out=numel(obj)
            out=prod(obj.Size);
        end
















        function initializeJacobianMemory(obj,initJacStr,initNumParens)









            obj.JacStr=initJacStr;
            obj.JacNumParens=initNumParens;
        end




























    end

    methods(Hidden,Abstract)
        acceptVisitor(Node,visitor);
    end

end
