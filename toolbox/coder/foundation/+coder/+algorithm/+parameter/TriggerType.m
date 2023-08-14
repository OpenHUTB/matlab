classdef TriggerType<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'rising'};
    end

    properties(Constant,GetAccess=public)
        Name='TriggerType';
        Options={'rising','falling','either'};
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=TriggerType(propVal)

            obj.Value=propVal;
        end
    end

end

