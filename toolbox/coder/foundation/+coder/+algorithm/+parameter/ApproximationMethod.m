classdef ApproximationMethod<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'None'};
    end

    properties(Constant,GetAccess=public)
        Name='ApproximationMethod'
        Options={'None','CORDIC'}
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=ApproximationMethod(propVal)

            obj.Value=propVal;
        end
    end

end
