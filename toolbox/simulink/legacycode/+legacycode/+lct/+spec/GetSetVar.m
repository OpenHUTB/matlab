classdef GetSetVar<legacycode.lct.spec.GlobalSigOrParam





    properties(SetAccess=private)
        ReadExpression char
        WriteExpression char
        WorkspaceName char
    end

    properties(SetAccess=private,Dependent)
IsReadOnly
    end

    methods(Access=public)
        function obj=GetSetVar(varSpec,readExpr,writeExpr,specElement,workspaceName)
            isExtern=true;
            isPointer=false;
            obj@legacycode.lct.spec.GlobalSigOrParam(varSpec,isExtern,isPointer,specElement);
            obj.ReadExpression=readExpr;
            obj.WriteExpression=writeExpr;
            obj.WorkspaceName=workspaceName;
            obj.IsGetSet=true;
        end
    end

    methods
        function isReadOnly=get.IsReadOnly(obj)

            isReadOnly=isempty(obj.WriteExpression);
        end
    end

end