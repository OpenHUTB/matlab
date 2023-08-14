classdef RndMeth<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'};
    end

    properties(Constant,GetAccess=public)
        Name='RndMeth'
        Options={'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'};
        Primary=false;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=RndMeth(propVal)
            obj.Value=propVal;
        end
    end

end
