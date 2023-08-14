classdef RemoveProtectionInput<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'off','on'};
    end

    properties(Constant,GetAccess=public)
        Name='RemoveProtectionInput'
        Options={'off','on'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=RemoveProtectionInput(propVal)

            obj.Value=propVal;
        end
    end

end
