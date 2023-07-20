function unionizedContainer=unionizeFixedPointTypes(fixedPointContainers)
















    allSigns=arrayfun(@(x)(x.evaluatedNumericType.SignednessBool),fixedPointContainers,'UniformOutput',false);
    groupSignedness=any([allSigns{:}]);



    allWordlengths=arrayfun(@(x)(x.evaluatedNumericType.WordLength),fixedPointContainers,'UniformOutput',false);
    groupWordlength=max([allWordlengths{:}]);



    allFractionLengths=arrayfun(@(x)(x.evaluatedNumericType.FractionLength),fixedPointContainers,'UniformOutput',false);
    groupFractionLength=max([allFractionLengths{:}]);


    allDTO=arrayfun(@(x)(x.evaluatedNumericType.DataTypeOverride),fixedPointContainers,'UniformOutput',false);
    groupHasDTODisabled=any(strcmp(allDTO,'Off'));


    unionizedContainer=fixdt(groupSignedness,groupWordlength,groupFractionLength);



    if groupHasDTODisabled
        unionizedContainer.DataTypeOverride='Off';
    end
end
