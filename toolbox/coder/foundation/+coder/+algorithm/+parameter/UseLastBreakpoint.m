classdef UseLastBreakpoint<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant)
        AliasNames={};
        AliasValues={};
        DefaultValue={'off','on'};
    end

    properties(Constant,GetAccess=public)
        Name='UseLastBreakpoint'
        Options={'off','on'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=UseLastBreakpoint(propVal)

            obj.Value=propVal;
        end
    end

end


