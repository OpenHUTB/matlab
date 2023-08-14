classdef OutputPackagerUtilities




    properties(Constant)
        STRUCT_EVAL_VARIABLE_TYPE='VariableDisplay'
        STRUCT_EVAL_ERROR_TYPE='UncaughtException'
        STRUCT_EVAL_WARNING_TYPE='IssuedWarning'
        STRUCT_EVAL_STDOUT_TYPE='stdout'
        STRUCT_EVAL_STDERR_TYPE='stderr'
        FIGURE_PLACEHOLDER_TYPE='figure.placeholder'
        FIGURE_TYPE='Figure'



        CONVERT_OUTPUT='convert'


        MAX_STRING_LENGTH=60000
    end

    methods(Static)
        function converted=formatForJson2dArray(value)










            if isscalar(value)
                converted={{}};
            elseif isvector(value)
                converted={value};
            else
                converted=value;
            end
        end

        function converted=formatForJsonArray(value)












            if isscalar(value)&&~iscell(value)
                converted={value};
            else
                converted=value;
            end
        end
    end
end

