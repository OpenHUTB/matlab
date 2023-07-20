classdef LocalFunctionWrapper<optim.internal.problemdef.HandleFunctionWrapper




    properties(Hidden,SetAccess=private,GetAccess=public)
        LocalFunctionWrapperVersion=1;
    end

    methods


        function obj=LocalFunctionWrapper(func,functionName,inputs,numArgOut,reuse)
            obj=obj@optim.internal.problemdef.HandleFunctionWrapper(func,functionName,inputs,numArgOut,reuse);
        end



        function funName=getCompiledName(obj)
            funName=createUniqueName(obj);
        end

    end

    methods(Access=protected)


        function funName=getDisplayName(obj)

            funName=obj.FunName;
        end



        function commentBody=getCommentForCompiledCall(~,~)


            commentBody="";
        end



        function compiledCode=defineFunctionInLocalVar(~,~)


            compiledCode="";
        end

    end

end
