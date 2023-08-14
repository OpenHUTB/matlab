classdef RemoveProtectionIndex<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'off','on'};
    end

    properties(Constant,GetAccess=public)
        Name='RemoveProtectionIndex';
        Options={'off','on'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=RemoveProtectionIndex(propVal)

            obj.Value=propVal;
        end
    end

end


