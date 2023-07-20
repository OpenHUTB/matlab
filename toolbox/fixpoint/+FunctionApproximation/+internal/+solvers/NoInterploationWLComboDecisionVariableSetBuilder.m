classdef NoInterploationWLComboDecisionVariableSetBuilder<FunctionApproximation.internal.solvers.LUTDecisionVariableSetBuilder








    methods
        function build(this,wlCombinations,problemObject)
            rangeObject=FunctionApproximation.internal.Range(problemObject.InputLowerBounds,problemObject.InputUpperBounds);
            decisionVariableSets=initializeDVSets(this,size(wlCombinations,1));
            nDimensions=(size(wlCombinations,2)-1);
            storageTypes=repmat(numerictype(),1,nDimensions+1);
            ranges=zeros(nDimensions,2);
            minSI=zeros(nDimensions,1);
            maxSI=zeros(nDimensions,1);
            for iDim=1:nDimensions
                [ranges(iDim,1),ranges(iDim,2)]=getMinMaxForDimension(rangeObject,iDim);
                minSI(iDim)=storedIntegerToDouble(fi(ranges(iDim,1),problemObject.InputTypes(iDim)));
                maxSI(iDim)=storedIntegerToDouble(fi(ranges(iDim,2),problemObject.InputTypes(iDim)));
            end
            for iSet=1:numel(decisionVariableSets)
                for iDim=1:nDimensions
                    wl=wlCombinations(iSet,iDim);
                    inputType=problemObject.InputTypes(iDim);
                    vectorStepSize=ceil((maxSI(iDim)-minSI(iDim)+1)/(2^wl-1));
                    storedIntegerVector=minSI(iDim):vectorStepSize:maxSI(iDim);
                    if numel(storedIntegerVector)<2
                        storedIntegerVector=[minSI(iDim),maxSI(iDim)];
                    end
                    value=fi([],inputType,'int',storedIntegerVector);
                    storageTypes(iDim)=fixed.internal.type.tightFixedPointType(value,wl);
                    storageTypes(iDim).WordLength=wl;
                end
                storageTypes(end)=numerictype([],wlCombinations(iSet,end));
                decisionVariableSets(iSet)=setStorageTypes(decisionVariableSets(iSet),storageTypes);
            end
            this.DecisionVariableSets=decisionVariableSets;
        end
    end
end
