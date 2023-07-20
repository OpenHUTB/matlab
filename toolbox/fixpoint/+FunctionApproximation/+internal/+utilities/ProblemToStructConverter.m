classdef ProblemToStructConverter<handle





    properties(Constant)
        StructTemplate=struct('FunctionToApproximate','',...
        'InputTypes','',...
        'InputLowerBounds','',...
        'InputUpperBounds','',...
        'OutputType','',...
        'Options','');
    end

    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=ProblemToStructConverter()
        end
    end

    methods
        function structFromProblem=convert(this,problemDefinition)
            structFromProblem=this.StructTemplate;
            functionToApproximate=problemDefinition.FunctionToApproximate;
            if~ischar(functionToApproximate)&&~isa(functionToApproximate,'cfit')
                functionToApproximate=func2str(functionToApproximate);
            end
            structFromProblem.FunctionToApproximate=functionToApproximate;
            structFromProblem.InputTypes=arrayfun(@(x)string(tostring(x)),problemDefinition.InputTypes);
            structFromProblem.InputLowerBounds=fixed.internal.compactButAccurateMat2Str(problemDefinition.InputLowerBounds);
            structFromProblem.InputUpperBounds=fixed.internal.compactButAccurateMat2Str(problemDefinition.InputUpperBounds);
            structFromProblem.OutputType=string(tostring(problemDefinition.OutputType));
            structFromProblem.Options=FunctionApproximation.internal.Utils.getStructFromOptions(problemDefinition.Options);
            structFromProblem.FunctionToReplace=problemDefinition.FunctionToReplace;
            structFromProblem.InputFunctionType=problemDefinition.InputFunctionType;
            structFromProblem.StorageTypes=[];
            if problemDefinition.InputFunctionType=="LUTBlock"
                serializableData=problemDefinition.InputFunctionWrapper.Data;
                structFromProblem.StorageTypes=arrayfun(@(x)string(tostring(x)),serializableData.StorageTypes);
            end
        end
    end
end
