



















classdef ModelRefCompileInterface<handle

    properties(Access=private)



        mf0Root=[];
    end

    methods
        function h=ModelRefCompileInterface(block)


            h.mf0Root=get_param(block,'ModelRefCompileInterface');
        end

        function fcnInfo=requiredAndProvidedFunctions(h)




            fcnInfo=struct('RequiredFunctions',[],...
            'ProvidedFunctions',[]);

            simulinkFunctions=h.mf0Root.simulinkFunctions;
            compFunctions=simulinkFunctions.compFunctions.toArray();
            for i=1:length(compFunctions)
                compFunction=compFunctions(i);
                if isempty(compFunction.functionBlock)
                    fcn=iConvertMf0CompFunctionToArray(compFunction);
                    fcnInfo.RequiredFunctions=[fcnInfo.RequiredFunctions,fcn];
                elseif any(strcmp({'Global','Scoped Export'},compFunction.visibility))
                    fcn=iConvertMf0CompFunctionToArray(compFunction);
                    fcnInfo.ProvidedFunctions=[fcnInfo.ProvidedFunctions,fcn];
                end
            end
        end
    end
end


function compFcn=iConvertMf0CompFunctionToArray(mf0CompFcn)
    compFcn=struct('FunctionName',mf0CompFcn.functionName,...
    'ScopeName',mf0CompFcn.scopeName,...
    'Visibility',mf0CompFcn.visibility,...
    'FcnArgs',mf0CompFcn.fcnArgs);
end


