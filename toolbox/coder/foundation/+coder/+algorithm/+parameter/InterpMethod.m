classdef InterpMethod<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={{'Linear'},{},{},{}};
        DefaultValue={'Linear point-slope'};
    end

    properties(Constant,GetAccess=public)
        Name='InterpMethod'
        Options={'Linear point-slope','Linear Lagrange','Flat','Nearest'}
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=InterpMethod(propVal)

            obj.Value=propVal;
        end
    end

end
