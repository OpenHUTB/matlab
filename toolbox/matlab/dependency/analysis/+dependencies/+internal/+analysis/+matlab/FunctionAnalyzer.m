classdef(Abstract)FunctionAnalyzer<handle&matlab.mixin.Heterogeneous




    properties(Abstract,SetAccess=immutable)

        Functions(1,:)string;

        MinimumArguments(1,1)double;

        StringArguments(1,:)double;

        AllowedArguments(1,:)string;
    end

    methods(Abstract)


        refs=analyze(this,analyzer,reference,dependencyFactory);

    end

end
