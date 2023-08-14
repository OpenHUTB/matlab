function err=checkUniqueValuesOfFieldInStructVector(array,uniqueFieldName)



    err=[];
    if isempty(array)
        return;
    end
    if slvariants.internal.config.utils.is1DArray(array)&&isstruct(array(1))
        array=transpose(array(:));
        fieldVals={array(:).(uniqueFieldName)};
        fieldVals=string(fieldVals);
        uniqueVals=unique(fieldVals);
        ok=length(fieldVals)==length(uniqueVals);
        if~ok
            err=MException(message('Simulink:Variants:NonUniqueFieldValues',uniqueFieldName));
        end
    end
end
