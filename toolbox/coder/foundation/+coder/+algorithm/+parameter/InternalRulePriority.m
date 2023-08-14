classdef InternalRulePriority<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'Precision','Speed'};
    end

    properties(Constant,GetAccess=public)
        Name='InternalRulePriority';
        Options={'Precision','Speed'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=InternalRulePriority(propVal)

            obj.Value=propVal;
        end
    end

end

