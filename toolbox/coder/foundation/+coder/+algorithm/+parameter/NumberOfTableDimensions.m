classdef NumberOfTableDimensions<coder.algorithm.parameter.AlgorithmParameter

    properties(Hidden,Constant,GetAccess=public)
        AliasNames={};
        AliasValues={};
        DefaultValue={'1'};
    end

    properties(Constant,GetAccess=public)
        Name='NumberOfTableDimensions'
        Options=strsplit(num2str(1:30));



        Primary=true;
    end

    properties(SetAccess=public,GetAccess=public)

    end

    methods
        function obj=NumberOfTableDimensions(propVal)

            obj.Value=propVal;
        end
    end

end
