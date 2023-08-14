classdef ExtrapMethod<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'Linear'};
    end

    properties(Constant,GetAccess=public)
        Name='ExtrapMethod';
        Options={'Linear','Clip'};
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=ExtrapMethod(propVal)

            obj.Value=propVal;
        end
    end

end

