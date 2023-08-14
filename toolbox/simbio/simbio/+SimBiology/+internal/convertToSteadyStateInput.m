function[variants,doses]=convertToSteadyStateInput(modelObj,scenariosTable,n)































    scenarioTable=scenariosTable(n,:);
    numEntries=width(scenarioTable);

    tfDose=arrayfun(@(i)isa(scenarioTable{1,i},'SimBiology.Dose'),1:numEntries);
    tfVariant=arrayfun(@(i)isa(scenarioTable{1,i},'SimBiology.Variant'),1:numEntries);
    idxQuantity=find(~(tfDose|tfVariant));


    if~isempty(idxQuantity)
        quantityNames=scenarioTable.Properties.VariableDescriptions(idxQuantity);
        quantityObjs=SimBiology.internal.getObjectFromPQN(modelObj,quantityNames);
        quantityTypes=cellfun(@(x)x.Type,quantityObjs,'UniformOutput',false);
        propertyNames=SimBiology.internal.getQuantityPropertyName([quantityObjs{:}]);
        variants=sbiovariant('quantity samples');
        cellfun(@(type,name,propName,propValue)variants.addcontent(...
        {type,name,propName,propValue}),quantityTypes,quantityNames,...
        propertyNames,num2cell(scenarioTable{1,idxQuantity}));
    else
        variants=[];
    end


    if any(tfVariant)
        if isempty(variants)
            variants=scenarioTable{1,tfVariant};
        else
            variants=[variants,scenarioTable{1,tfVariant}];
        end
    end


    if any(tfDose)
        doses=scenarioTable{1,tfDose};
    else
        doses=[];
    end

end
