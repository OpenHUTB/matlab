classdef TrigInterpMethod<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'Linear point-slope','Flat'};
    end

    properties(Constant,GetAccess=public)
        Name='InterpMethod'
        Options={'Linear point-slope','Flat'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=TrigInterpMethod(propVal)

            obj.Value=propVal;
        end
    end

end
