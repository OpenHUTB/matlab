classdef ApplyFullPrecisionForLinearInterpolation<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'off','on'};
    end

    properties(Constant,GetAccess=public)
        Name='ApplyFullPrecisionForLinearInterpolation'
        Options={'off','on'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)
    end

    methods
        function obj=ApplyFullPrecisionForLinearInterpolation(propVal)
            obj.Value=propVal;
        end
    end

end