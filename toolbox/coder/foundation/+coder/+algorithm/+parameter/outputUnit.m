classdef outputUnit<coder.algorithm.parameter.AlgorithmParameter



    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'Radians'};
    end

    properties(Constant,GetAccess=public)
        Name='outputUnit';
        Options={'Radians','PerUnit'};
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=outputUnit(propVal)

            obj.Value=propVal;
        end
    end

end

