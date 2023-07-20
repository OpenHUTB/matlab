classdef(Abstract)FunctionWrapper<handle




    properties(Hidden=true)

        Func=[];

        FunName="";

        Inputs={};

        NumArgOut=0;


        Value={};

        FunStr="";

        OptimInputs=[];



        Reuse=false;
    end

    properties

        FuncID=0;
    end

    properties(Hidden,SetAccess=private,GetAccess=public)
        FunctionWrapperVersion=1;
    end

    methods


        function delete(obj)
            obj.getOrReturnFuncID(obj.FuncID);
        end

    end

    methods




        function funName=getCompiledWithReuseName(obj)




            funName="generatedFunction_"+obj.FunName+obj.FuncID+"_withReuse";
            if strlength(funName)>50


                funName="generatedFunction"+obj.FuncID+"_withReuse";
            end
        end



        function funIdx=getSubfunHandle(~,visitor)


            funIdx=visitor.NumExtraParams;
        end

    end

    methods(Access=protected)


        function obj=FunctionWrapper(func,funName,inputs,numArgOut,reuse)
            obj.FuncID=optim.internal.problemdef.FunctionWrapper.getOrReturnFuncID();
            obj.Func=func;
            obj.FunName=funName;
            obj.NumArgOut=numArgOut;
            [obj.Inputs,isOptimInputs]=parseInputs(obj,inputs);
            obj.OptimInputs=find(isOptimInputs);
            obj.Reuse=reuse;
        end



        function[variables,depth]=getVariablesAndDepth(obj)

            inputs=obj.Inputs;
            nInputs=numel(inputs);

            if nInputs==0
                depth=1;
                variables=struct;
            else

                varsList=cell(nInputs,1);
                inputi=inputs{1};
                varsList{1}=inputi.Variables;

                depth=getDepth(inputi);
                if nInputs>1

                    for i=2:nInputs
                        inputi=inputs{i};

                        depth=max(depth,getDepth(inputi));

                        varsList{i}=inputi.Variables;
                    end

                    variables=optim.internal.problemdef.HashMapFunctions.arrayunion(varsList,'OptimizationExpression');
                else
                    variables=varsList{1};
                end



                depth=depth+1;
            end
        end

        function[inputs,isOptimInput]=parseInputs(~,inputs)

            nInputs=numel(inputs);

            isOptimInput=false(nInputs,1);

            for i=1:nInputs

                [inputs{i},isOptimInput(i)]=wrapInputs(inputs{i});
            end
        end

    end

    methods(Access=protected)



        function funName=createUniqueName(obj)

            funName="generatedFunction_"+obj.FunName;



            if strlength(funName)>50


                funName="generatedFunction"+obj.FuncID;
            end
        end

    end

    methods(Abstract)

        [Funh,funCallBody]=compileFunctionCall(obj,inputStr,visitor);


        funName=getCompiledName(obj);


        inputStr=getCompiledRepeatedFunInputs(obj,inputStr,extraParamsName);
    end

    methods(Static=true)


        function[obj,vars,depth]=createFunctionWrapper(func,inputs,numArgOut,reuse)
            functionHandleStruct=functions(func);
            functionType=functionHandleStruct.type;
            functionName=functionHandleStruct.function;

            switch functionType
            case{'anonymous'}

                obj=optim.internal.problemdef.AnonymousFunctionWrapper(func,functionName,inputs,numArgOut,reuse);
            case{'scopedfunction'}

                obj=optim.internal.problemdef.LocalFunctionWrapper(func,functionName,inputs,numArgOut,reuse);
            case{'nested'}


                functionName=split(functionName,"/");
                functionName=functionName{end};
                obj=optim.internal.problemdef.LocalFunctionWrapper(func,functionName,inputs,numArgOut,reuse);
            otherwise

                obj=optim.internal.problemdef.NamedFunctionWrapper(func,functionName,inputs,numArgOut,reuse);
            end

            [vars,depth]=getVariablesAndDepth(obj);
        end



        function out=getOrReturnFuncID(releaseID)




            persistent IDMap


            deleteCase=nargin>0;
            out=0;
            if isempty(IDMap)


                IDMap=false(20,1);
            end
            if deleteCase

                IDMap(releaseID)=false;
            else


                out=find(IDMap==false,1);
                if isempty(out)


                    out=numel(IDMap)+1;
                    IDMap(end+20)=false;
                end
                IDMap(out)=true;
            end
        end

        function obj=loadobj(obj)


            obj.FuncID=optim.internal.problemdef.FunctionWrapper.getOrReturnFuncID();
        end

    end

end



function[input,isOptimInput]=wrapInputs(input)
    if isa(input,'optim.problemdef.OptimizationExpression')

        input=getExprImpl(input);
        isOptimInput=true;
    else



        newInput=optim.internal.problemdef.ExpressionForest;
        createNumeric(newInput,input);
        input=newInput;
        isOptimInput=false;
    end
end
