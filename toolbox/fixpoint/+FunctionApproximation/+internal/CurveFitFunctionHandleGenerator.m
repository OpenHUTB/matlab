classdef(Sealed)CurveFitFunctionHandleGenerator






    properties(SetAccess=private)
        CurveFitObj=['cfitObj_',datestr(now,'yyyymmddTHHMMSSFFF')];
        FunctionHandle;
    end

    methods

        function this=CurveFitFunctionHandleGenerator(functionHandle)
            this.FunctionHandle=getCurveFitFunctionHandle(this,functionHandle);
        end

        function functionHandle=getCurveFitFunctionHandle(this,functionHandle)
            functionCategory=category(functionHandle);

            if(strcmp(functionCategory,'library')||strcmp(functionCategory,'custom'))
                formulaString=formula(functionHandle);
                values=coeffvalues(functionHandle);
                coeffs=coeffnames(functionHandle);

                for i=1:numel(coeffs)
                    formulaString=strrep(formulaString,coeffs{i},num2str(values(i)));
                end
                formulaString=['@(x)',formulaString];
                curveFitHandle=str2func(formulaString);

            else
                curveFitHandle=eval(['@(x)feval(',this.CurveFitObj,',x)']);
            end
            functionHandle=FunctionApproximation.internal.StandardFunctionHandleGenerator(curveFitHandle);
        end
    end
end
