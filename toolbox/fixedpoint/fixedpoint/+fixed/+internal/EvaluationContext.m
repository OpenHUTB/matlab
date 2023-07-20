classdef EvaluationContext








%#codegen

    properties


        Env(1,1)fixed.internal.ExecutionEnvironment=fixed.internal.ExecutionEnvironment.MATLAB;
        AbsTol=0;
        TrimToMaximumWordLength(1,1)logical=true;
    end

    methods
        function wl=MaximumWordLength(obj)

            switch obj.Env
            case{"MATLAB"}
                wl=2^16-1;
            otherwise
                wl=128;
            end
        end
    end

    methods(Static,Hidden)
        function props=matlabCodegenNontunableProperties(~)


            props={'Environment','Tolerance','TrimToMaximumWordLength'};
        end
    end

    methods(Static)
        function ctx=makeDefaultEvaluationContext()
            ctx=fixed.internal.EvaluationContext();
            ctx.Env=fixed.internal.ExecutionEnvironment.MATLAB;
            ctx.AbsTol=0;
            ctx.TrimToMaximumWordLength=true;
        end
    end

    methods(Access=protected)
        function obj=EvaluationContext
            coder.allowpcode('plain');
        end
    end

end