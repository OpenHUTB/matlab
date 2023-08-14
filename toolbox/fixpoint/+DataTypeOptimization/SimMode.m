classdef SimMode<double









    enumeration
        Normal(0)
        Accelerator(1)
        Rapid(2)
    end

    methods(Static)
        function str=tostring(en)
            switch(en)
            case DataTypeOptimization.SimMode.Normal
                str="Normal";
            case DataTypeOptimization.SimMode.Accelerator
                str="Accelerator";
            case DataTypeOptimization.SimMode.Rapid
                str="Rapid-Accelerator";
            end
        end

    end
end
