classdef ApproximateDirectLUDecisionVariableSetFactory





    methods
        function decisionVariableSets=getApproximateLUTDecisionVariableSet(this,problemObject,options)
            wordlengthUpperBounds=arrayfun(@(x)x.WordLength,[problemObject.InputTypes,problemObject.OutputType]);
            constraintGenerator=FunctionApproximation.internal.solvers.WLConstraintGeneratorFactory.getConstraintGenerator(options);
            constraints=constraintGenerator.getConstraints(problemObject,options);
            wlCombinationGenerator=FunctionApproximation.internal.solvers.WLCombinationGeneratorFactory.getGenerator(options);
            validCombinations=wlCombinationGenerator.getCombinations(options.WordLengths,constraints,wordlengthUpperBounds);
            tableData=problemObject.SampledTableData;





            nCombinations=size(validCombinations,1);
            removeEntryIndices=false(nCombinations,1);
            outputType=problemObject.OutputType;
            for ii=1:nCombinations
                tableTypeWL=validCombinations(ii,end);
                templateType=numerictype(1,tableTypeWL,4);
                dataType=FunctionApproximation.internal.scaleDataType(...
                templateType,...
                tableData,...
                outputType);
                if~FunctionApproximation.internal.Utils.canDataTypeMeetTolerance(dataType,options.AbsTol*2)
                    removeEntryIndices(ii)=true;
                end
            end
            validCombinations=validCombinations(~removeEntryIndices,:);



            interfaceTypes=[problemObject.InputTypes,problemObject.OutputType];
            interfaceTypeWLs=arrayfun(@(x)x.WordLength,interfaceTypes);


            absTableData=abs(tableData(:));
            maxAbsTableData=max(absTableData);
            minAbsTableData=min(absTableData);
            meanAbsTableData=mean(absTableData);
            tableDataCondition=log2((maxAbsTableData-minAbsTableData)/meanAbsTableData);

            validCombinations=this.reOrderWLCombinationsUsingUpperBounds(validCombinations,interfaceTypeWLs,tableDataCondition);


            dvSetBuilder=FunctionApproximation.internal.solvers.LUTDecisionVariableSetBuilderFactory.getBuilder(options);
            dvSetBuilder.build(validCombinations,problemObject);
            decisionVariableSets=dvSetBuilder.DecisionVariableSets;



            interfaceTypesDVSet=FunctionApproximation.internal.solvers.ApproximateLUTDecisionVariableSet().setStorageTypes(interfaceTypes);
            decisionVariableSets=[interfaceTypesDVSet,decisionVariableSets];
        end
    end

    methods(Static)
        function validCombinations=reOrderWLCombinationsUsingUpperBounds(validCombinations,interfaceTypeWLs,tableDataCondition)








            distanceFromInterfaceTypes=sum(abs(validCombinations-interfaceTypeWLs),2);
            sizeOfOutputWL=sort(validCombinations(:,end));
            weightDistanceFromInterfaceTypes=0.5+0.25*(-1)^(tableDataCondition<=2);
            weightSizeOfOutputWL=(1-weightDistanceFromInterfaceTypes);
            normalizedDistanceFromInterfaceTypes=distanceFromInterfaceTypes/max(distanceFromInterfaceTypes(:));
            normalizedSizeOfOutputWL=sizeOfOutputWL/max(sizeOfOutputWL(:));
            cost=weightDistanceFromInterfaceTypes*normalizedDistanceFromInterfaceTypes+weightSizeOfOutputWL*normalizedSizeOfOutputWL;
            [~,indices]=sort(cost);
            validCombinations=validCombinations(indices,:);
        end
    end
end


