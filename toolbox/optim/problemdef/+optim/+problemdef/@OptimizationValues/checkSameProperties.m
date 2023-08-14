function checkSameProperties(obj,varargin)









    valueObjs=[{obj},varargin];
    quantities=cellfun(@(x)fieldnames(x.Values)',valueObjs,'UniformOutput',false);
    numQuantities=cellfun(@numel,quantities);
    if numel(unique(numQuantities))>1
        error(message('optim_problemdef:OptimizationValues:indexing:AllObjectsMustHaveSameQuantities'));
    end
    uniqueQuantities=unique([quantities{:}]);
    if numel(uniqueQuantities)~=numQuantities(1)
        error(message('optim_problemdef:OptimizationValues:indexing:AllObjectsMustHaveSameQuantities'));
    end


    iCheckSameSize(obj,valueObjs,"VariableSize");
    iCheckSameSize(obj,valueObjs,"ObjectiveSize");
    iCheckSameSize(obj,valueObjs,"ConstraintSize");

end

function iCheckSameSize(obj,valueObjs,SizeProperty)

    varNames=fieldnames(obj.(SizeProperty));
    for i=1:numel(varNames)
        allSizes=cellfun(@(x)x.(SizeProperty).(varNames{i}),valueObjs,'UniformOutput',false);
        for j=1:numel(allSizes)-1
            if~isequal(allSizes{j},allSizes{j+1})
                error(message('optim_problemdef:OptimizationValues:indexing:AllPropertiesMustHaveSameSize'));
            end
        end
    end

end
