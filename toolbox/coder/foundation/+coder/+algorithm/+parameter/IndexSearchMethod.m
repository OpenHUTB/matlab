classdef IndexSearchMethod<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'Binary search','Evenly spaced points','Linear search'};
    end

    properties(Constant,GetAccess=public)
        Name='IndexSearchMethod'
        Options={'Linear search','Binary search','Evenly spaced points'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=IndexSearchMethod(propVal)

            obj.Value=propVal;
        end
    end

end

