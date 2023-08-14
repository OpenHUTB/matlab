classdef NamedFunctionWrapper<optim.internal.problemdef.FunctionWrapper




    properties(Hidden,SetAccess=private,GetAccess=public)
        NamedFunctionWrapperVersion=1;
    end

    methods


        function obj=NamedFunctionWrapper(func,functionName,inputs,numArgOut,reuse)
            obj=obj@optim.internal.problemdef.FunctionWrapper(func,functionName,inputs,numArgOut,reuse);
        end

    end

    methods



        function[Funh,funBody]=compileFunctionCall(obj,inputStr,~)
            Funh=obj.FunName+"("+strjoin(inputStr,", ")+")";
            funBody="";
        end



        function funName=getCompiledName(obj)
            funName=createUniqueName(obj);
        end



        function inputStr=getCompiledRepeatedFunInputs(~,inputStr,~)

        end

    end

end
