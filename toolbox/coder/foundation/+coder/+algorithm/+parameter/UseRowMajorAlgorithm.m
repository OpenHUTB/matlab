classdef UseRowMajorAlgorithm<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'off'};
    end

    properties(Constant,GetAccess=public)
        Name='UseRowMajorAlgorithm'
        Options={'off','on'};
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=UseRowMajorAlgorithm(propVal)

            obj.Value=propVal;
        end
    end

end

