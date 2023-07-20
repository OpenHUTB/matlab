classdef InputsSelectThisObjectFromTable<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={{},{'Column'},{}};
        DefaultValue={'Element'};
    end

    properties(Constant,GetAccess=public)
        Name='InputsSelectThisObjectFromTable';
        Options={'Element','Vector','2-D Matrix'};
        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=InputsSelectThisObjectFromTable(propVal)

            obj.Value=propVal;
        end
    end

end
