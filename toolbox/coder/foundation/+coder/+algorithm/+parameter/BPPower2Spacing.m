classdef BPPower2Spacing<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'off','on'};
    end

    properties(Constant,GetAccess=public)
        Name='BPPower2Spacing';
        Options={'off','on'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=BPPower2Spacing(propVal)

            obj.Value=propVal;
        end
    end

end


