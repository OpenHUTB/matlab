classdef AngleUnit<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'radian','revolution'};
    end

    properties(Constant,GetAccess=public)
        Name='AngleUnit'
        Options={'radian','revolution'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=AngleUnit(propVal)

            obj.Value=propVal;
        end
    end

end
