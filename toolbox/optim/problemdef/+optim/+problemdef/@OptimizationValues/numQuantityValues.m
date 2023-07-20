function[numVals,fnames]=numQuantityValues(valueData,p)



















    fnames=fieldnames(valueData);
    numQuantities=numel(fnames);
    numVals=zeros(1,numQuantities);
    [variableNames,objectiveNames]=getQuantityNames(p);

    for i=1:numQuantities


        quantityName=fnames{i};
        propertyName=optim.problemdef.OptimizationProblem.getPropertyFromQuantityName(...
        quantityName,variableNames,objectiveNames);
        propertyValue=p.(propertyName);
        if isstruct(propertyValue)&&~isempty(propertyValue)
            Quantity=propertyValue.(quantityName);
        else
            Quantity=propertyValue;
        end

        if~isempty(Quantity)

            Values=valueData.(quantityName);


            numVals(i)=numel(Values)/numel(Quantity);
        end

    end

end