classdef ApproximateLUTFloatingPointDecisionVariableSetFactory






    methods
        function decisionVariableSets=getApproximateLUTDecisionVariableSet(~,problemObject,storageTypes)
            typeMap=containers.Map('KeyType','char','ValueType','double');
            newTypes=[problemObject.InputTypes,problemObject.OutputType];
            allowedWLs=problemObject.Options.WordLengths;
            for iType=1:numel(newTypes)
                if fixed.internal.type.isAnyFloat(newTypes(iType))
                    allowedWLs(end+1)=newTypes(iType).WordLength;%#ok<AGROW>
                end
            end

            floatingPointWLs=FunctionApproximation.internal.ApproximateGeneratorEngine.getFloatingPointWLs(problemObject.Options);
            floatingPointTypeStrings=FunctionApproximation.internal.ApproximateGeneratorEngine.getFloatingPointStrings(problemObject.Options);
            floatingPointTypeStrings=floatingPointTypeStrings(ismember(floatingPointWLs,allowedWLs));
            [~,indicesWithoutConstraints]=...
            FunctionApproximation.internal.solvers.getIndicesForWLConstraints(...
            problemObject.NumberOfInputs,...
            problemObject.Options);
            combinations=FunctionApproximation.internal.CoordinateSetCreator(repmat({1:numel(floatingPointTypeStrings)},1,numel(storageTypes))).CoordinateSets;
            decisionVariableSets=FunctionApproximation.internal.solvers.ApproximateLUTDecisionVariableSet.empty();
            for iRow=1:size(combinations,1)
                for iType=1:numel(storageTypes)
                    if ismember(iType,indicesWithoutConstraints)
                        newTypes(iType)=numerictype(floatingPointTypeStrings(combinations(iRow,iType)));
                        if newTypes(iType).WordLength>storageTypes(iType).WordLength
                            newTypes(iType)=storageTypes(iType);
                        end
                    end
                    areTypesFloat=arrayfun(@(x)fixed.internal.type.isAnyFloat(x),newTypes);
                    if any(areTypesFloat)
                        key=arrayfun(@(x)sprintf('%s',tostring(x)),newTypes,'UniformOutput',false);
                        key=[key{:}];
                        if~typeMap.isKey(key)
                            typeMap(key)=1;
                            decisionVariableSets(end+1)=FunctionApproximation.internal.solvers.ApproximateLUTDecisionVariableSet();%#ok<AGROW>
                            decisionVariableSets(end)=setStorageTypes(decisionVariableSets(end),newTypes);
                        end
                    end
                end
            end
        end
    end
end