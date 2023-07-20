classdef(Abstract)HandleFunctionWrapper<optim.internal.problemdef.FunctionWrapper






    properties(Hidden,SetAccess=private,GetAccess=public)
        HandleFunctionWrapperVersion=1;
    end

    methods


        function obj=HandleFunctionWrapper(func,functionName,inputs,numArgOut,reuse)
            obj=obj@optim.internal.problemdef.FunctionWrapper(func,functionName,inputs,numArgOut,reuse);
        end

    end

    methods




        function[Funh,funBody]=compileFunctionCall(obj,inputStr,visitor)

            if visitor.ForDisplay

                funVarName=getDisplayName(obj);


                funBody=defineFunctionInLocalVar(obj,funVarName);


                Funh=funVarName+"("+strjoin(inputStr,", ")+")";

            else


                paramIdx=pushExtraParam(visitor,obj.Func);



                funVarName=getCompiledName(obj);


                funBody=getCommentForCompiledCall(obj,funVarName);



                funBody=funBody+funVarName+" = "+visitor.ExtraParamsName+"{"+paramIdx+"};"+newline;


                Funh=funVarName+"("+strjoin(inputStr,", ")+")";
            end
        end



        function funIdx=getSubfunHandle(obj,visitor)
            funIdx=pushExtraParam(visitor,obj.Func);
        end



        function inputStr=getCompiledRepeatedFunInputs(~,inputStr,extraParamsName)



            inputStr=[inputStr;extraParamsName];
        end

    end

    methods(Abstract,Access=protected)

        funName=getDisplayName(obj);


        commentBody=getCommentForCompiledCall(obj,funVarName);


        compiledCode=defineFunctionInLocalVar(obj,funVarName);
    end

end
