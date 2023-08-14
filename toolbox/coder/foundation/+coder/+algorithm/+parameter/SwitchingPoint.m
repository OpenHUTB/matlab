classdef SwitchingPoint<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'LeftRight'};
    end

    properties(Constant,GetAccess=public)
        Name='SwitchingPoint';
        Options={'LeftRight','LeftDelta','DeltaRight'};
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=SwitchingPoint(propVal)

            obj.Value=propVal;
        end
    end

end

