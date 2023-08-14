classdef AxisAlignment<coder.algorithm.parameter.AlgorithmParameter



    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'dAxis'};
    end

    properties(Constant,GetAccess=public)
        Name='AxisAlignment';
        Options={'dAxis','qAxis'};
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=AxisAlignment(propVal)

            obj.Value=propVal;
        end
    end

end

