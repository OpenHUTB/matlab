classdef SaturateOnIntegerOverflow<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant)
        AliasNames={};
        AliasValues={};
        DefaultValue={'off','on'};
    end

    properties(Constant,GetAccess=public)
        Name='SaturateOnIntegerOverflow'
        Options={'off','on'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=SaturateOnIntegerOverflow(propVal)

            obj.Value=propVal;
        end
    end

end


