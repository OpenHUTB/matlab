classdef AnonymousFunctionWrapper<optim.internal.problemdef.HandleFunctionWrapper




    properties(Hidden,SetAccess=private,GetAccess=public)
        AnonymousFunctionWrapperVersion=1;
    end

    methods


        function obj=AnonymousFunctionWrapper(func,functionName,inputs,numArgOut,reuse)
            obj=obj@optim.internal.problemdef.HandleFunctionWrapper(func,functionName,inputs,numArgOut,reuse);
        end



        function funName=getCompiledWithReuseName(obj)

            funName=getCompiledName(obj)+"_withReuse";
        end




        function funName=getCompiledName(obj)

            funName="generatedFunction"+obj.FuncID;
        end

    end

    methods(Access=protected)


        function funName=getDisplayName(obj)

            funName="anonymousFunction"+obj.FuncID;
        end




        function commentBody=getCommentForCompiledCall(obj,funVarName)


            commentBody="% "+defineFunctionInLocalVar(obj,funVarName);
        end



        function compiledCode=defineFunctionInLocalVar(obj,funVarName)


            compiledCode=funVarName+" = "+obj.FunName+";"+newline;
        end

    end

end
