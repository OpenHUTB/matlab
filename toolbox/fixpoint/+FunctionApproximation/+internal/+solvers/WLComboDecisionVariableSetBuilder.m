classdef WLComboDecisionVariableSetBuilder<FunctionApproximation.internal.solvers.LUTDecisionVariableSetBuilder







    methods
        function build(this,wlCombinations,problemObject,matchInterfaceType)
            nSets=size(wlCombinations,1);
            decisionVariableSets=initializeDVSets(this,nSets);
            nDimensions=problemObject.NumberOfInputs;
            interfaceTypes=[problemObject.InputTypes,problemObject.OutputType];
            interfaceWLs=arrayfun(@(x)x.WordLength,interfaceTypes);
            storageTypes=interfaceTypes;
            for iSet=1:nSets
                isMatch=@(x)matchInterfaceType(x)||...
                (wlCombinations(iSet,x)==interfaceWLs(x)&&~interfaceTypes(x).isfloat());
                for iDim=1:nDimensions
                    if isMatch(iDim)
                        storageTypes(iDim)=interfaceTypes(iDim);
                    else
                        minValue=problemObject.InputLowerBounds(iDim);
                        maxValue=problemObject.InputUpperBounds(iDim);
                        rangeOfValues=[minValue,maxValue];
                        storageTypes(iDim)=...
                        FunctionApproximation.internal.scaleDataType(...
                        numerictype([],wlCombinations(iSet,iDim)),...
                        rangeOfValues,problemObject.InputTypes(iDim));
                    end
                end
                iDim=nDimensions+1;
                if isMatch(iDim)
                    storageTypes(iDim)=interfaceTypes(iDim);
                else
                    storageTypes(iDim)=numerictype([],wlCombinations(iSet,iDim));
                end
                decisionVariableSets(iSet)=setStorageTypes(decisionVariableSets(iSet),storageTypes);
            end
            this.DecisionVariableSets=decisionVariableSets;
        end
    end
end
